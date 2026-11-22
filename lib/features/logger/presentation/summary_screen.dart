import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/router.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../app/widgets/rf_button.dart';
import '../../../core/metrics/units.dart';
import '../../onboarding/data/providers.dart';
import '../data/providers.dart';
import '../domain/summary.dart';
import 'set_row.dart';
import 'summary_format.dart';

Future<Uint8List> _capture(RenderRepaintBoundary b) async {
  final image = await b.toImage(pixelRatio: 3);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return data!.buffer.asUint8List();
}

// Screen 16 (LOG-05). [afterFinish]: opened by Finish, so leaving goes Home
// and never back into the logger (AC1); otherwise it pops (AC8).
class SummaryScreen extends ConsumerStatefulWidget {
  const SummaryScreen({
    required this.sessionId,
    this.afterFinish = false,
    super.key,
  });

  static const doneKey = ValueKey('summary.done');
  static const shareKey = ValueKey('summary.share');
  static const noteKey = ValueKey('summary.note');
  static const cardKey = ValueKey('summary.card');

  static const Future<Uint8List> Function(RenderRepaintBoundary)
  defaultCapture = _capture;

  // Swapped in tests, where rendering to an image needs real async.
  @visibleForTesting
  static Future<Uint8List> Function(RenderRepaintBoundary) capture = _capture;

  final String sessionId;
  final bool afterFinish;

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen>
    with WidgetsBindingObserver {
  final _note = TextEditingController();
  final _card = GlobalKey();
  String? _saved;
  bool _loaded = false;
  bool _sharing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _note.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) unawaited(_saveNote());
  }

  String? get _text {
    final t = _note.text.trim();
    return t.isEmpty ? null : t;
  }

  Future<bool>? _saving;

  // AC6: only when changed; never per keystroke (NFR-10). One at a time, so a
  // pause and a Done tap can't both write.
  Future<bool> _saveNote() async {
    while (_saving != null) {
      await _saving;
    }
    if (!_loaded || _text == _saved) return true;
    final f = _write();
    _saving = f;
    try {
      return await f;
    } finally {
      _saving = null;
    }
  }

  Future<bool> _write() async {
    final text = _text;
    try {
      await ref.read(sessionRepositoryProvider).setNote(widget.sessionId, text);
      _saved = text;
      return true;
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).summaryNoteFailed),
          ),
        );
      }
      return false;
    }
  }

  Future<void> _leave() async {
    if (!await _saveNote() || !mounted) return;
    if (widget.afterFinish || !context.canPop()) {
      context.go(Routes.home);
    } else {
      context.pop();
    }
  }

  Future<void> _share(WorkoutSummary s, String text) async {
    final boundary =
        _card.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null || _sharing) return;
    setState(() => _sharing = true);
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final png = await SummaryScreen.capture(boundary);
      await ref
          .read(summaryShareProvider)
          .shareImage(png, fileName: 'repforge-workout.png', text: text);
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.summaryShareFailed)));
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(workoutSummaryProvider(widget.sessionId));
    final units = ref.watch(unitSystemProvider).value ?? UnitSystem.metric;
    final summary = async.value;
    if (summary != null && !_loaded) {
      _loaded = true;
      _saved = summary.session.note;
      _note.text = _saved ?? '';
    }
    final locale = Localizations.localeOf(context).toString();

    Widget body;
    String? shareText;
    if (summary != null) {
      final date = DateFormat.yMMMEd(locale).format(summary.session.date);
      shareText = l10n.summaryShareText(
        summary.session.name,
        date,
        durationText(l10n, summary.duration),
        summary.volumeKg == null
            ? l10n.summaryNone
            : volumeText(l10n, summary.volumeKg!, units),
      );
      body = _SummaryBody(
        summary: summary,
        units: units,
        date: date,
        cardKey: _card,
        note: _note,
      );
    } else if (async.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(RfSpace.s24),
          child: Text(l10n.summaryLoadFailed, textAlign: TextAlign.center),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_leave());
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(l10n.summaryTitle),
          actions: [
            if (summary != null)
              IconButton(
                key: SummaryScreen.shareKey,
                tooltip: l10n.summaryShare,
                constraints: const BoxConstraints(
                  minWidth: RfSize.minTarget,
                  minHeight: RfSize.minTarget,
                ),
                icon: const Icon(Icons.ios_share),
                onPressed: _sharing ? null : () => _share(summary, shareText!),
              ),
          ],
        ),
        body: SafeArea(child: body),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(RfSpace.s16),
            child: RfButton(
              key: SummaryScreen.doneKey,
              label: l10n.summaryDone,
              onPressed: _leave,
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryBody extends StatelessWidget {
  const _SummaryBody({
    required this.summary,
    required this.units,
    required this.date,
    required this.cardKey,
    required this.note,
  });

  final WorkoutSummary summary;
  final UnitSystem units;
  final String date;
  final GlobalKey cardKey;
  final TextEditingController note;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final s = summary;
    final prev = s.hasPrevious;

    // Not lazy: the card must stay built for Share after scrolling (AC7).
    return SingleChildScrollView(
      padding: const EdgeInsets.all(RfSpace.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RepaintBoundary(
            key: cardKey,
            child: Container(
              key: SummaryScreen.cardKey,
              padding: const EdgeInsets.all(RfSpace.s16),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(RfRadius.lg),
                border: Border.all(color: c.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.summaryDate(s.session.name, date),
                    style: t.heading.copyWith(color: c.textPrimary),
                  ),
                  const SizedBox(height: RfSpace.s16),
                  Wrap(
                    spacing: RfSpace.s24,
                    runSpacing: RfSpace.s16,
                    children: [
                      _Stat(
                        label: l10n.summaryTime,
                        value: durationText(l10n, s.duration),
                        change: prev
                            ? minutesChange(l10n, s.durationChange!)
                            : null,
                      ),
                      _Stat(
                        label: l10n.summarySets,
                        value: '${s.setCount}',
                        change: prev ? setsChange(l10n, s.setChange!) : null,
                      ),
                      _Stat(
                        label: l10n.summaryVolume,
                        value: s.volumeKg == null
                            ? l10n.summaryNone
                            : volumeText(l10n, s.volumeKg!, units),
                        valueLabel: s.volumeKg == null
                            ? l10n.summaryNoneLabel
                            : null,
                        change: !prev
                            ? null
                            : s.volumeChange == null
                            ? noCompare(l10n)
                            : weightChange(l10n, s.volumeChange!, units),
                      ),
                    ],
                  ),
                  if (s.prs.isNotEmpty) ...[
                    const SizedBox(height: RfSpace.s16),
                    Text(
                      l10n.summaryPrCount(s.prs.length),
                      style: t.labelStrong.copyWith(color: c.textPrimary),
                    ),
                    const SizedBox(height: RfSpace.s4),
                    for (final p in s.prs)
                      Text(
                        l10n.summaryPrLine(
                          p.row.name,
                          shortSetText(l10n, p.row, (
                            kg: p.set.kg,
                            reps: p.set.reps,
                            seconds: p.set.seconds,
                          ), units),
                        ),
                        style: t.body.copyWith(color: c.textPrimary),
                      ),
                  ],
                ],
              ),
            ),
          ),
          if (!prev) ...[
            const SizedBox(height: RfSpace.s12),
            Text(
              l10n.summaryFirstTime,
              style: t.label.copyWith(color: c.textSecondary),
            ),
          ],
          const SizedBox(height: RfSpace.s24),
          Text(
            l10n.summaryExercises,
            style: t.overline.copyWith(color: c.textSecondary),
          ),
          for (final e in s.exercises) _ExerciseLine(e: e, units: units),
          const SizedBox(height: RfSpace.s24),
          TextField(
            key: SummaryScreen.noteKey,
            controller: note,
            minLines: 2,
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: l10n.summaryNote,
              hintText: l10n.summaryNoteHint,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    this.valueLabel,
    this.change,
  });

  final String label;
  final String value;
  final String? valueLabel;
  final ChangeText? change;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final spoken = [
      label,
      valueLabel ?? value,
      if (change case final ch?) l10n.summaryVsLast(ch.label),
    ].join(', ');
    return Semantics(
      container: true,
      label: spoken,
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: t.overline.copyWith(color: c.textSecondary)),
          Text(value, style: t.statXl.copyWith(color: c.textPrimary)),
          if (change case final ch?)
            Text(
              l10n.summaryVsLast(ch.text),
              style: t.label.copyWith(color: c.textSecondary),
            ),
        ],
      ),
    );
  }
}

class _ExerciseLine extends StatelessWidget {
  const _ExerciseLine({required this.e, required this.units});

  final ExerciseSummary e;
  final UnitSystem units;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final sets = [
      for (final x in e.sets)
        shortSetText(l10n, e.row, (
          kg: x.kg,
          reps: x.reps,
          seconds: x.seconds,
        ), units),
    ].join(', ');
    final total = amountText(l10n, e.measure, e.amount, units);
    final change = e.change == null
        ? null
        : amountChange(l10n, e.measure, e.change!, units);
    return Semantics(
      container: true,
      excludeSemantics: true,
      label: [
        e.row.name,
        sets,
        total,
        if (change != null) l10n.summaryVsLast(change.label),
      ].join(', '),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: RfSpace.s8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              e.row.name,
              style: t.labelStrong.copyWith(color: c.textPrimary),
            ),
            Text(sets, style: t.body.copyWith(color: c.textSecondary)),
            Text(
              [
                total,
                if (change != null) l10n.summaryVsLast(change.text),
              ].join(' · '),
              style: t.label.copyWith(color: c.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
