import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/router.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../app/widgets/rf_button.dart';
import '../../../core/ids.dart';
import '../../../core/metrics/units.dart';
import '../../library/data/providers.dart';
import '../../library/presentation/exercise_picker_screen.dart';
import '../../onboarding/data/providers.dart';
import '../data/providers.dart';
import '../domain/ghost.dart';
import '../domain/logger_rules.dart';
import '../domain/session_repository.dart';
import '../domain/workout_session.dart';
import 'edit_set_sheet.dart';
import 'rest_bar.dart';
import 'set_row.dart';

enum _RowAction { swap }

enum _MenuAction { discard }

// Screen 02 (WKT-02, LOG-01): the workout in progress.
class LoggerScreen extends ConsumerStatefulWidget {
  const LoggerScreen({super.key});

  static const finishKey = ValueKey('logger.finish');
  static const addExerciseKey = ValueKey('logger.addExercise');
  static const menuKey = ValueKey('logger.menu');

  @override
  ConsumerState<LoggerScreen> createState() => _LoggerScreenState();
}

class _LoggerScreenState extends ConsumerState<LoggerScreen> {
  var _finishing = false;

  SessionRepository get _repo => ref.read(sessionRepositoryProvider);

  Future<bool> _guard(Future<void> Function() write) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    try {
      await write();
      return true;
    } on NoSetsLogged {
      messenger.showSnackBar(SnackBar(content: Text(l10n.loggerNeedSet)));
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.editorSaveFailed)));
    }
    return false;
  }

  Future<void> _finish(WorkoutSession s) async {
    setState(() => _finishing = true);
    final ok = await _guard(() => _repo.finish(s.id));
    if (!mounted) return;
    setState(() => _finishing = false);
    if (!ok) return;
    await RestActions(ref, AppLocalizations.of(context)).cancelAlarm();
    if (mounted) context.go(Routes.home);
  }

  Future<void> _discard(WorkoutSession s) async {
    final l10n = AppLocalizations.of(context);
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.loggerDiscardTitle),
        content: Text(l10n.loggerDiscardBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.loggerKeepGoing),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.editorDiscard),
          ),
        ],
      ),
    );
    if (!(yes ?? false) || !mounted) return;
    final actions = RestActions(ref, l10n);
    if (await _guard(() => _repo.discard(s.id)) && mounted) {
      await actions.cancelAlarm();
      if (!mounted) return;
      context.go(Routes.home);
    }
  }

  // AC7: one exercise from the library, by id.
  Future<String?> _pick() async {
    final ids = await Navigator.of(context).push<List<String>>(
      MaterialPageRoute(
        builder: (_) =>
            const ExercisePickerScreen(alreadyAdded: {}, capacity: 1),
      ),
    );
    return ids == null || ids.isEmpty ? null : ids.first;
  }

  Future<void> _addExercise(WorkoutSession s) async {
    final id = await _pick();
    if (id == null) return;
    final e = await (await ref.read(exerciseCatalogProvider.future)).byId(id);
    if (e == null) return;
    await _guard(
      () => _repo.setExercises(s.id, addExercise(s.exercises, e, newId())),
    );
  }

  Future<void> _swap(WorkoutSession s, SessionExercise row) async {
    final id = await _pick();
    if (id == null) return;
    final e = await (await ref.read(exerciseCatalogProvider.future)).byId(id);
    if (e == null) return;
    await _guard(
      () => _repo.setExercises(
        s.id,
        swapExercise(
          s.exercises,
          row.id,
          e,
          // The highest logged set, so a gap stays with the old exercise.
          logged: s.setsOf(row.id).fold(0, (n, x) => x.setNo > n ? x.setNo : n),
          newId: newId(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(activeSessionProvider);
    final units = ref.watch(unitSystemProvider).value ?? UnitSystem.metric;
    final s = async.value;

    if (s == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: async.isLoading
              ? const CircularProgressIndicator()
              : const SizedBox.shrink(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(s.name),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: RfSpace.s4),
            child: RfButton(
              key: LoggerScreen.finishKey,
              label: l10n.loggerFinish,
              size: RfButtonSize.md,
              loading: _finishing,
              onPressed: () => _finish(s),
            ),
          ),
          PopupMenuButton<_MenuAction>(
            key: LoggerScreen.menuKey,
            tooltip: l10n.loggerMenu,
            onSelected: (_) => _discard(s),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: _MenuAction.discard,
                child: Text(l10n.loggerDiscard),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: RestBar(session: s),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(RfSpace.s16),
          children: [
            for (final row in s.exercises)
              _ExerciseCard(
                key: ValueKey(row.id),
                session: s,
                row: row,
                units: units,
                guard: _guard,
                onSwap: () => _swap(s, row),
              ),
            RfButton(
              key: LoggerScreen.addExerciseKey,
              label: l10n.loggerAddExercise,
              variant: RfButtonVariant.secondary,
              onPressed: () => _addExercise(s),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseCard extends ConsumerWidget {
  const _ExerciseCard({
    required this.session,
    required this.row,
    required this.units,
    required this.guard,
    required this.onSwap,
    super.key,
  });

  final WorkoutSession session;
  final SessionExercise row;
  final UnitSystem units;
  final Future<bool> Function(Future<void> Function() write) guard;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final repo = ref.read(sessionRepositoryProvider);
    final last = ref.watch(lastSetsProvider(row.exerciseId)).value ?? const {};
    final logged = session.setsOf(row.id);
    final count = setCount(row, logged);
    // LOG-02: worked out on screen, so edits and deletes re-evaluate (AC7).
    final goals = targets(row, last, units);
    final prs = prSets([
      for (final x in session.sets)
        if (x.exerciseId == row.exerciseId) x,
    ], ref.watch(exerciseHistoryProvider(row.exerciseId)).value ?? const []);
    SetValues? ghostOf(int n) => switch (last[n]) {
      final g? => (kg: g.kg, reps: g.reps, seconds: g.seconds),
      null => null,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: RfSpace.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(row.name, style: t.heading),
                ),
              ),
              PopupMenuButton<_RowAction>(
                tooltip: l10n.loggerExerciseActions(row.name),
                icon: const Icon(Icons.more_vert),
                onSelected: (_) => onSwap(),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: _RowAction.swap,
                    child: Text(l10n.loggerSwapExercise),
                  ),
                ],
              ),
            ],
          ),
          for (var n = 1; n <= count; n++)
            Padding(
              padding: const EdgeInsets.only(top: RfSpace.s8),
              child: () {
                final done = [
                  for (final x in logged)
                    if (x.setNo == n) x,
                ];
                return SetRow(
                  key: ValueKey('${row.id}.$n'),
                  row: row,
                  setNo: n,
                  units: units,
                  logged: done.isEmpty ? null : done.first,
                  ghost: ghostOf(n),
                  target: goals[n],
                  isPr: done.isNotEmpty && prs.contains(done.first.id),
                  prefill: prefill(row, n, loggedInRow: logged, targets: goals),
                  onLog: (v) async {
                    final set = LoggedSet(
                      id: newId(),
                      rowId: row.id,
                      exerciseId: row.exerciseId,
                      setNo: n,
                      kg: v.kg,
                      reps: v.reps,
                      seconds: v.seconds,
                    );
                    if (!await guard(() => repo.logSet(session.id, set))) {
                      return;
                    }
                    // LOG-03: not awaited by Log's spinner (NFR-01).
                    unawaited(
                      RestActions(ref, l10n).afterLog(
                        session.copyWith(sets: [...session.sets, set]),
                        row.id,
                      ),
                    );
                  },
                  onEdit: () async {
                    final edit = await editSet(context, row, done.first, units);
                    switch (edit) {
                      case SetChanged(:final values):
                        await guard(
                          () => repo.updateSet(
                            done.first.id,
                            kg: values.kg,
                            reps: values.reps,
                            seconds: values.seconds,
                          ),
                        );
                      case SetDeleted():
                        await guard(() => repo.deleteSet(done.first.id));
                      case null:
                    }
                  },
                );
              }(),
            ),
          const SizedBox(height: RfSpace.s8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              style: TextButton.styleFrom(
                minimumSize: const Size(RfSize.minTarget, RfSize.minTarget),
                foregroundColor: c.actionInk,
              ),
              onPressed: () => guard(
                () => repo.setExercises(
                  session.id,
                  addSet(session.exercises, row.id),
                ),
              ),
              child: Text(l10n.loggerAddSet),
            ),
          ),
        ],
      ),
    );
  }
}
