import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../app/widgets/rf_button.dart';
import '../../../core/metrics/units.dart';
import '../../logger/data/providers.dart';
import '../../logger/domain/session_repository.dart';
import '../../logger/domain/workout_session.dart';
import '../../logger/presentation/set_row.dart';
import '../../onboarding/data/providers.dart';
import '../data/exercise_images.dart';
import '../data/providers.dart';
import '../domain/exercise.dart';
import 'add_to_workout_sheet.dart';
import 'muscle_groups.dart';

// Screen 14 (EXL-02).
class ExerciseDetailScreen extends ConsumerWidget {
  const ExerciseDetailScreen({required this.id, super.key});

  static const addKey = ValueKey('exercise.add');

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(exerciseByIdProvider(id));
    final e = async.value;
    if (e == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: async.isLoading
              ? const CircularProgressIndicator()
              : Text(
                  l10n.exerciseNotFound,
                  style: RfTextStyles.of(context).body,
                ),
        ),
      );
    }
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);

    Widget fact(String label, String value) => Padding(
      padding: const EdgeInsets.only(top: RfSpace.s8),
      child: MergeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: t.overline.copyWith(color: c.textSecondary)),
            Text(value, style: t.body.copyWith(color: c.textPrimary)),
          ],
        ),
      ),
    );

    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: RfSpace.s24, bottom: RfSpace.s8),
      child: Semantics(
        header: true,
        child: Text(text, style: t.heading.copyWith(color: c.textPrimary)),
      ),
    );

    String muscles(List<Muscle> m) =>
        m.map((x) => muscleLabel(l10n, x)).join(', ');

    return Scaffold(
      appBar: AppBar(),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(RfSpace.s16),
          child: RfButton(
            key: addKey,
            label: l10n.exerciseAdd,
            onPressed: () => showAddToWorkout(context, ref, e),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(RfSpace.s16),
          children: [
            // In the body, not the app bar, so long names wrap (edge, NFR-06).
            Semantics(
              header: true,
              child: Text(
                e.name,
                style: t.title.copyWith(color: c.textPrimary),
              ),
            ),
            const SizedBox(height: RfSpace.s12),
            if (e.images.isNotEmpty) _Pictures(exercise: e),
            if (e.primaryMuscles.isNotEmpty)
              fact(l10n.exerciseMain, muscles(e.primaryMuscles)),
            if (e.secondaryMuscles.isNotEmpty)
              fact(l10n.exerciseOther, muscles(e.secondaryMuscles)),
            fact(l10n.exerciseEquipment, equipmentLabel(l10n, e.equipment)),
            fact(l10n.exerciseLevel, levelLabel(l10n, e.level)),
            fact(l10n.exerciseType, categoryLabel(l10n, e.category)),
            if (e.instructions.isNotEmpty) ...[
              heading(l10n.exerciseSteps),
              for (final (i, step) in e.instructions.indexed)
                Semantics(
                  label: l10n.exerciseStep(i + 1, step),
                  excludeSemantics: true,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: RfSpace.s8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: RfSpace.s24,
                          child: Text(
                            '${i + 1}.',
                            style: t.labelStrong.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            step,
                            style: t.body.copyWith(color: c.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
            heading(l10n.exerciseHistory),
            _History(exercise: e),
          ],
        ),
      ),
    );
  }
}

// AC6: kept on the phone after the first load; a placeholder until then.
class _Pictures extends ConsumerWidget {
  const _Pictures({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final image = ref.watch(exerciseImageProvider);
    final paths = exercise.images;

    Widget placeholder() => Container(
      color: c.surface,
      padding: const EdgeInsets.all(RfSpace.s12),
      alignment: Alignment.center,
      child: Text(
        l10n.exercisePicturesOffline,
        textAlign: TextAlign.center,
        style: t.label.copyWith(color: c.textSecondary),
      ),
    );

    return Row(
      children: [
        for (final (i, path) in paths.indexed) ...[
          if (i > 0) const SizedBox(width: RfSpace.s8),
          Expanded(
            child: Semantics(
              image: true,
              label: l10n.exercisePicture(exercise.name, i + 1, paths.length),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(RfRadius.md),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image(
                    image: image(path),
                    fit: BoxFit.cover,
                    excludeFromSemantics: true,
                    frameBuilder: (context, child, frame, sync) =>
                        frame == null && !sync ? placeholder() : child,
                    errorBuilder: (_, _, _) => placeholder(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// An estimate, so whole kg or lb.
String _e1rmText(AppLocalizations l10n, double kg, UnitSystem units) =>
    units == UnitSystem.metric
    ? l10n.loggerKg('${kg.round()}')
    : l10n.loggerLb('${kgToLb(kg).round()}');

// AC7: best e1RM and the last 5 workouts with their best set.
class _History extends ConsumerWidget {
  const _History({required this.exercise});

  final Exercise exercise;

  static LoggedSet _best(List<LoggedSet> sets) {
    double score(LoggedSet s) {
      final r = s.reps;
      // Epley for ranking only, past the 12-rep cap too, so 60 × 15 beats
      // 20 × 5; bodyweight and timed sets rank by reps or seconds.
      if (r != null && s.kg > 0) return s.kg * (1 + r / 30);
      return (s.reps ?? s.seconds ?? 0) / 1000;
    }

    return sets.reduce((a, b) => score(b) > score(a) ? b : a);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final units = ref.watch(unitSystemProvider).value ?? UnitSystem.metric;
    final log = ref.watch(exerciseLogProvider(exercise.id));
    final best = ref.watch(exerciseBestE1rmProvider(exercise.id)).value;
    final locale = Localizations.localeOf(context).toString();
    final row = SessionExercise(
      id: '',
      exerciseId: exercise.id,
      name: exercise.name,
      bodyweight: exercise.equipment == Equipment.bodyOnly,
    );

    Text line(String s, {bool muted = false}) => Text(
      s,
      style: t.body.copyWith(color: muted ? c.textSecondary : c.textPrimary),
    );

    if (log.hasError) return line(l10n.exerciseHistoryFailed, muted: true);
    final entries = log.value;
    if (entries == null) return const SizedBox.shrink();
    if (entries.isEmpty) return line(l10n.exerciseNotDone, muted: true);

    String setText(ExerciseLogEntry x) {
      final b = _best(x.sets);
      return shortSetText(l10n, row, (
        kg: b.kg,
        reps: b.reps,
        seconds: b.seconds,
      ), units);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (best != null)
          Padding(
            padding: const EdgeInsets.only(bottom: RfSpace.s8),
            child: Text(
              l10n.exerciseBestE1rm(_e1rmText(l10n, best, units)),
              style: t.labelStrong.copyWith(color: c.textPrimary),
            ),
          ),
        for (final x in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: RfSpace.s4),
            child: line(
              l10n.exerciseLogLine(
                DateFormat.MMMEd(locale).format(x.date),
                setText(x),
              ),
            ),
          ),
      ],
    );
  }
}
