import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../app/widgets/rf_button.dart';
import '../../../app/widgets/rf_segmented.dart';
import '../../../core/clock.dart';
import '../../../core/ids.dart';
import '../../../core/metrics/units.dart';
import '../../onboarding/data/providers.dart';
import '../data/providers.dart';
import '../domain/goal.dart';
import '../domain/goal_rules.dart';
import 'goal_text.dart';

// Screen 19 (AC2, AC3, AC8, AC11): a new goal, or [id]'s target and deadline.
class GoalFormScreen extends ConsumerStatefulWidget {
  const GoalFormScreen({this.id, super.key});

  final String? id;

  static const liftKey = ValueKey('goalForm.lift');
  static const targetKey = ValueKey('goalForm.target');
  static const deadlineKey = ValueKey('goalForm.deadline');
  static const clearDeadlineKey = ValueKey('goalForm.clearDeadline');
  static const saveKey = ValueKey('goalForm.save');

  @override
  ConsumerState<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends ConsumerState<GoalFormScreen> {
  final _target = TextEditingController();
  var _type = GoalType.strength;
  String? _lift;
  DateTime? _deadline;
  Goal? _editing;
  var _saving = false;

  @override
  void dispose() {
    _target.dispose();
    super.dispose();
  }

  UnitSystem get _units =>
      ref.read(unitSystemProvider).value ?? UnitSystem.metric;

  double? _targetKg() {
    final v = double.tryParse(_target.text.trim().replaceAll(',', '.'));
    if (v == null) return null;
    return _units == UnitSystem.metric ? v : lbToKg(v);
  }

  // Edit: load once, with the target shown in the display unit (AC8, AC11).
  void _load(Goal g) {
    if (_editing != null) return;
    _editing = g;
    _type = g.type;
    _lift = g.exerciseId;
    _deadline = g.deadline;
    final v = _units == UnitSystem.metric ? g.target : kgToLb(g.target);
    _target.text = v.toStringAsFixed(1);
  }

  Future<void> _pickLift(
    List<({String id, String name, double current})> lifts,
  ) async {
    final l10n = AppLocalizations.of(context);
    final t = RfTextStyles.of(context);
    final id = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: RfSpace.s20),
              child: Text(l10n.goalPickLift, style: t.heading),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final l in lifts)
                    ListTile(
                      minTileHeight: RfSize.minTarget,
                      title: Text(l.name, style: t.body),
                      onTap: () => Navigator.of(context).pop(l.id),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (id != null) setState(() => _lift = id);
  }

  Future<void> _pickDeadline() async {
    final today = ref.read(todayProvider);
    final picked = await showDatePicker(
      context: context,
      // A passed deadline can't be the picker's start (firstDate is today).
      initialDate: _deadline == null || _deadline!.isBefore(today)
          ? today.add(const Duration(days: 56))
          : _deadline,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(
        () => _deadline = DateTime.utc(picked.year, picked.month, picked.day),
      );
    }
  }

  Future<void> _save(double start, double target) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    final repo = ref.read(goalRepositoryProvider);
    try {
      if (_editing case final e?) {
        await repo.updateTarget(e.id, target, _deadline);
      } else {
        await repo.save(
          Goal(
            id: newId(),
            type: _type,
            exerciseId: _type == GoalType.strength ? _lift : null,
            startValue: start,
            target: target,
            deadline: _deadline,
            createdAt: ref.read(clockProvider)(),
          ),
        );
      }
    } on Object {
      if (mounted) setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(l10n.goalActionFailed)));
      return;
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final locale = Localizations.localeOf(context).toString();
    final units = ref.watch(unitSystemProvider).value ?? UnitSystem.metric;
    final today = ref.watch(todayProvider);

    if (widget.id case final id?) {
      final g = ref
          .watch(goalsProvider)
          .value
          ?.where((g) => g.id == id)
          .firstOrNull;
      if (g == null) {
        return Scaffold(
          appBar: AppBar(title: Text(l10n.goalEditTitle)),
          body: const Center(child: CircularProgressIndicator()),
        );
      }
      _load(g);
    }

    final lifts = ref.watch(goalLiftsProvider).value ?? const [];
    final liftName = _lift == null
        ? null
        : ref.watch(goalLiftNameProvider(_lift!)).value;
    final history = switch (_type) {
      GoalType.strength when _lift == null => null,
      _ => ref.watch(goalHistoryProvider(_type, _lift)).value,
    };
    final current = history?.lastOrNull?.value;
    final target = _targetKg();
    // Edge: compare as shown (one decimal, display unit), so a target typed
    // as the shown current value is "already there".
    double shown(double kg) {
      final v = units == UnitSystem.metric ? kg : kgToLb(kg);
      return (v * 10).round() / 10;
    }

    final problem = current == null || _target.text.trim().isEmpty
        ? null
        : validateTarget(
            _type,
            shown(current),
            target == null ? -1 : shown(target),
            rising: _editing?.rising,
          );
    final ready =
        current != null && target != null && problem == null && !_saving;
    final start = _editing?.startValue ?? current;
    final preview = ready && history != null
        ? goalStatus(
            Goal(
              id: '',
              type: _type,
              startValue: start!,
              target: target,
              deadline: _deadline,
              createdAt: today,
            ),
            history,
            today,
          )
        : null;
    final unitWord = units == UnitSystem.metric
        ? l10n.unitKilograms
        : l10n.unitPounds;

    Widget note(String text) => Padding(
      padding: const EdgeInsets.only(top: RfSpace.s8),
      child: Text(text, style: t.body.copyWith(color: c.textSecondary)),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_editing == null ? l10n.goalNew : l10n.goalEditTitle),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(RfSpace.s16),
          child: RfButton(
            key: GoalFormScreen.saveKey,
            label: l10n.goalSave,
            loading: _saving,
            onPressed: ready ? () => _save(start!, target) : null,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(RfSpace.s16),
          children: [
            if (_editing == null)
              RfSegmented<GoalType>(
                label: l10n.goalTypeLabel,
                options: {
                  GoalType.strength: l10n.goalStrength,
                  GoalType.bodyWeight: l10n.goalBodyWeight,
                },
                selected: _type,
                onChanged: (v) {
                  if (v != null) setState(() => _type = v);
                },
              )
            else
              Text(
                goalName(l10n, _editing!, liftName),
                style: t.heading.copyWith(color: c.textPrimary),
              ),
            const SizedBox(height: RfSpace.s16),
            if (_type == GoalType.strength && _editing == null)
              if (lifts.isEmpty)
                note(l10n.goalNoLifts)
              else
                ListTile(
                  key: GoalFormScreen.liftKey,
                  minTileHeight: RfSize.minTarget,
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.goalLift, style: t.label),
                  subtitle: Text(
                    liftName ?? l10n.goalPickLift,
                    style: t.body.copyWith(color: c.textPrimary),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _pickLift(lifts),
                ),
            if (_type == GoalType.bodyWeight &&
                history != null &&
                current == null)
              note(l10n.goalNoWeight),
            if (current != null) ...[
              note(l10n.goalNow(goalValue(l10n, current, units))),
              const SizedBox(height: RfSpace.s12),
              Semantics(
                hint: l10n.fieldInUnit(l10n.goalTarget, unitWord),
                child: TextField(
                  key: GoalFormScreen.targetKey,
                  controller: _target,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
                  ],
                  decoration: InputDecoration(
                    labelText: l10n.goalTarget,
                    suffixText: units == UnitSystem.metric
                        ? l10n.unitKg
                        : l10n.unitLb,
                    errorText: targetProblemText(l10n, problem),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(height: RfSpace.s16),
              Text(l10n.goalDeadline, style: t.label),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: RfSpace.s8,
                children: [
                  Text(
                    _deadline == null
                        ? l10n.goalDeadlineNone
                        : goalDate(locale, _deadline!),
                    style: t.body.copyWith(color: c.textPrimary),
                  ),
                  TextButton(
                    key: GoalFormScreen.deadlineKey,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(
                        RfSize.minTarget,
                        RfSize.minTarget,
                      ),
                    ),
                    onPressed: _pickDeadline,
                    child: Text(l10n.goalDeadlineSet),
                  ),
                  if (_deadline != null)
                    TextButton(
                      key: GoalFormScreen.clearDeadlineKey,
                      style: TextButton.styleFrom(
                        minimumSize: const Size(
                          RfSize.minTarget,
                          RfSize.minTarget,
                        ),
                      ),
                      onPressed: () => setState(() => _deadline = null),
                      child: Text(l10n.goalDeadlineClear),
                    ),
                ],
              ),
              if (preview != null) ...[
                note(projectionText(l10n, locale, preview.projection)),
                if (preview.pace case final p?) note(paceText(l10n, p)),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
