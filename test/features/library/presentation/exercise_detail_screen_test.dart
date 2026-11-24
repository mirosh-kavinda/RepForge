import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/app.dart';
import 'package:repforge/app/router.dart';
import 'package:repforge/core/metrics/units.dart';
import 'package:repforge/features/library/data/combined_catalog.dart';
import 'package:repforge/features/library/data/exercise_images.dart';
import 'package:repforge/features/library/data/providers.dart';
import 'package:repforge/features/library/domain/exercise.dart';
import 'package:repforge/features/library/presentation/custom_exercise_form.dart';
import 'package:repforge/features/library/presentation/exercise_detail_screen.dart';
import 'package:repforge/features/logger/data/providers.dart';
import 'package:repforge/features/logger/domain/workout_session.dart';
import 'package:repforge/features/workout/domain/workout_template.dart';
import 'package:repforge/features/workout/presentation/template_editor_screen.dart';

import '../../../helpers/app_overrides.dart';
import '../../logger/fake_session_repository.dart';
import '../../workout/fakes.dart';
import '../fake_custom_exercise_repository.dart';
import '../library_fakes.dart';

LoggedSet squat(String id, double kg, int reps) => LoggedSet(
  id: id,
  rowId: 'r',
  exerciseId: 'Barbell_Squat',
  setNo: 1,
  kg: kg,
  reps: reps,
);

WorkoutSession done(int day, List<LoggedSet> sets) => WorkoutSession(
  id: 'w$day',
  name: 'Legs',
  exercises: const [
    SessionExercise(id: 'r', exerciseId: 'Barbell_Squat', name: 'Squat'),
  ],
  date: DateTime.utc(2026, 11, day),
  startedAt: DateTime.utc(2026, 11, day, 9),
  endedAt: DateTime.utc(2026, 11, day, 10),
  sets: sets,
);

const push = WorkoutTemplate(
  id: 'push',
  name: 'Push',
  exercises: [TemplateExercise(id: 'a', exerciseId: 'Bench_Press')],
);

late FakeSessionRepository sessions;
late FakeTemplateRepository templates;
late List<String> imageCalls;
late FakeCustomExerciseRepository custom;

// A 1x1 PNG, standing in for a picture already kept on the phone.
final onePixel = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

Future<void> openDetail(
  WidgetTester tester,
  String id, {
  List<WorkoutSession> finished = const [],
  List<WorkoutTemplate> workouts = const [push],
  UnitSystem units = UnitSystem.metric,
  double textScale = 1,
  ImageProvider Function(String path)? images,
  List<Exercise> mine = const [],
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = const Size(390, 844);
  addTearDown(tester.view.reset);
  sessions = FakeSessionRepository()..finishedList.addAll(finished);
  for (final w in finished) {
    for (final x in w.sets) {
      (sessions.historyOf[x.exerciseId] ??= []).add(x);
    }
  }
  templates = FakeTemplateRepository(workouts);
  custom = FakeCustomExerciseRepository(mine);
  imageCalls = [];
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...signedInOverrides(
          sessions: sessions,
          templates: templates,
          units: units,
          custom: custom,
        ),
        exerciseCatalogProvider.overrideWith(
          (ref) async => CombinedCatalog(LibraryCatalog(), custom),
        ),
        // Never loads here, as with no connection: the placeholder shows.
        exerciseImageProvider.overrideWithValue((path) {
          imageCalls.add(path);
          return images?.call(path) ?? MemoryImage(Uint8List(0));
        }),
      ],
      child: MediaQuery.withClampedTextScaling(
        minScaleFactor: textScale,
        maxScaleFactor: textScale,
        child: const RepForgeApp(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  ProviderScope.containerOf(
    tester.element(find.byType(RepForgeApp)),
  ).read(routerProvider).go(Routes.exercise(id));
  await tester.pumpAndSettle();
}

Future<void> scrollTo(WidgetTester tester, Finder f) => tester
    .scrollUntilVisible(f, 200, scrollable: find.byType(Scrollable).first);

void main() {
  group('EXL-02 exercise detail', () {
    testWidgets('AC5 muscles, equipment, level, type and steps', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await openDetail(tester, 'Barbell_Squat');
      expect(find.text('Barbell Squat'), findsOneWidget);
      expect(find.text('Quads'), findsOneWidget);
      expect(find.text('Glutes, Hamstrings'), findsOneWidget);
      expect(find.text('Barbell'), findsOneWidget);
      expect(find.text('Intermediate'), findsOneWidget);
      expect(find.text('Strength'), findsOneWidget);
      await scrollTo(tester, find.text('How to do it'));
      expect(
        find.bySemanticsLabel('Step 2: Squat down, then stand up.'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('AC6 pictures load by path; not yet loaded, a placeholder', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await openDetail(tester, 'Barbell_Squat');
      expect(imageCalls.toSet(), {
        'Barbell_Squat/0.jpg',
        'Barbell_Squat/1.jpg',
      });
      expect(
        find.text('Pictures need a connection the first time'),
        findsNWidgets(2),
      );
      expect(
        find.bySemanticsLabel(RegExp('^Barbell Squat, picture 1 of 2')),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('AC6 a kept picture replaces the placeholder', (tester) async {
      await openDetail(
        tester,
        'Barbell_Squat',
        images: (_) => MemoryImage(onePixel),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Pictures need a connection the first time'),
        findsNothing,
      );
      expect(find.byType(Image), findsNWidgets(2));
    });

    testWidgets('edge a failed picture: placeholder, no dialog', (
      tester,
    ) async {
      await openDetail(tester, 'Barbell_Squat');
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Pictures need a connection the first time'),
        findsNWidgets(2),
      );
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('edge a long name wraps at 200 % text', (tester) async {
      await openDetail(tester, 'Long', textScale: 2);
      expect(tester.takeException(), isNull);
      final name = find.text(
        'Single-Arm Dumbbell Incline Bench Press With Rotation Hold',
      );
      expect(name, findsOneWidget);
      expect(
        tester.renderObject<RenderParagraph>(name).didExceedMaxLines,
        isFalse,
      );
      expect(tester.getSize(name).height, greaterThan(60), reason: 'wraps');
    });

    testWidgets('error history fails: says so, the rest shows', (tester) async {
      await openDetail(tester, 'Barbell_Squat');
      sessions.logFails = Exception('disk');
      ProviderScope.containerOf(
        tester.element(find.byType(RepForgeApp)),
      ).invalidate(exerciseLogProvider('Barbell_Squat'));
      await tester.pumpAndSettle();
      const failed = "Couldn't load your history";
      await scrollTo(tester, find.text(failed));
      expect(find.text(failed), findsOneWidget);
      expect(find.text('Quads'), findsOneWidget, reason: 'the rest shows');
    });

    testWidgets('AC8 a full workout says so; nothing added', (tester) async {
      await openDetail(
        tester,
        'Plank',
        workouts: [
          push.copyWith(
            exercises: [
              for (var i = 0; i < 30; i++)
                TemplateExercise(id: '$i', exerciseId: 'e$i'),
            ],
          ),
        ],
      );
      await tester.tap(find.byKey(ExerciseDetailScreen.addKey));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Push'));
      await tester.pumpAndSettle();
      expect(find.text('Push already has 30 exercises'), findsOneWidget);
      expect(templates.saved, isEmpty);
    });

    testWidgets('edge no pictures in the catalog: no picture area', (
      tester,
    ) async {
      await openDetail(tester, 'Bench_Press');
      expect(find.byType(Image), findsNothing);
      expect(imageCalls, isEmpty);
    });

    testWidgets('AC7 best e1RM and the last 5 times, newest first', (
      tester,
    ) async {
      await openDetail(
        tester,
        'Barbell_Squat',
        finished: [
          for (var d = 10; d <= 15; d++)
            done(d, [squat('a$d', 80.0 + d, 5), squat('b$d', 60, 10)]),
        ],
      );
      await scrollTo(tester, find.text('Your history'));
      await scrollTo(tester, find.textContaining('Best estimated 1RM'));
      expect(find.text('Best estimated 1RM: 111 kg'), findsOneWidget);
      expect(find.textContaining('Nov 15 · 95 kg × 5'), findsOneWidget);
      expect(find.textContaining('Nov 11 · 91 kg × 5'), findsOneWidget);
      expect(find.textContaining('Nov 10'), findsNothing);
    });

    testWidgets('AC7 imperial users see lb', (tester) async {
      await openDetail(
        tester,
        'Barbell_Squat',
        units: UnitSystem.imperial,
        finished: [
          done(15, [squat('a', 100, 5)]),
        ],
      );
      await scrollTo(tester, find.textContaining('Best estimated 1RM'));
      expect(find.text('Best estimated 1RM: 257 lb'), findsOneWidget);
    });

    testWidgets('AC7 never done: Not done yet', (tester) async {
      await openDetail(tester, 'Bench_Press');
      await scrollTo(tester, find.text('Not done yet'));
      expect(find.text('Not done yet'), findsOneWidget);
    });

    testWidgets('AC8 add to a workout; again says already in it', (
      tester,
    ) async {
      await openDetail(tester, 'Plank');
      await tester.tap(find.byKey(ExerciseDetailScreen.addKey));
      await tester.pumpAndSettle();
      expect(find.text('Add to which workout?'), findsOneWidget);
      await tester.tap(find.text('Push'));
      await tester.pumpAndSettle();
      expect(find.text('Added to Push'), findsOneWidget);
      expect(templates.saved.single.exercises.last.exerciseId, 'Plank');

      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ExerciseDetailScreen.addKey));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Push'));
      await tester.pumpAndSettle();
      expect(find.text('Already in Push'), findsOneWidget);
      expect(templates.saved, hasLength(1));
    });

    testWidgets('AC8 a failed save says so', (tester) async {
      await openDetail(tester, 'Plank');
      templates.failSaveWith = Exception('disk');
      await tester.tap(find.byKey(ExerciseDetailScreen.addKey));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Push'));
      await tester.pumpAndSettle();
      expect(find.text("Couldn't add to workout"), findsOneWidget);
    });

    testWidgets('AC8 no workouts: offers a new one', (tester) async {
      await openDetail(tester, 'Plank', workouts: const []);
      await tester.tap(find.byKey(ExerciseDetailScreen.addKey));
      await tester.pumpAndSettle();
      expect(find.text('You have no workouts yet'), findsOneWidget);
      await tester.tap(find.text('New workout'));
      await tester.pumpAndSettle();
      expect(find.byType(TemplateEditorScreen), findsOneWidget);
    });

    testWidgets('EXL-03 AC5 a custom one: Custom, notes, Edit, Delete', (
      tester,
    ) async {
      await openDetail(
        tester,
        'c1',
        mine: [
          ex(
            'c1',
            'Hack Squat',
            [Muscle.quadriceps],
            equipment: Equipment.machine,
          ).copyWith(custom: true, notes: 'Seat 4, pin 7'),
        ],
      );
      expect(find.text('Custom'), findsOneWidget);
      expect(find.text('Machine'), findsOneWidget);
      expect(find.text('Seat 4, pin 7'), findsOneWidget);
      expect(find.text('Level'), findsNothing);
      expect(find.text('How to do it'), findsNothing);
      expect(find.byType(Image), findsNothing);
      expect(find.byKey(ExerciseDetailScreen.editKey), findsOneWidget);
      expect(find.byKey(ExerciseDetailScreen.deleteKey), findsOneWidget);
      expect(find.byKey(ExerciseDetailScreen.addKey), findsOneWidget);
    });

    testWidgets('EXL-03 AC5 a catalog one has no Edit or Delete', (
      tester,
    ) async {
      await openDetail(tester, 'Bench_Press');
      expect(find.byKey(ExerciseDetailScreen.editKey), findsNothing);
      expect(find.byKey(ExerciseDetailScreen.deleteKey), findsNothing);
      expect(find.text('Custom'), findsNothing);
    });

    testWidgets('EXL-03 AC6 Edit saves and the detail shows the change', (
      tester,
    ) async {
      await openDetail(
        tester,
        'c1',
        mine: [
          ex('c1', 'Hack Squat', [Muscle.quadriceps]).copyWith(custom: true),
        ],
      );
      await tester.tap(find.byKey(ExerciseDetailScreen.editKey));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(CustomExerciseForm.nameKey),
        'Hack Squat (Gym 2)',
      );
      await tester.tap(find.byKey(CustomExerciseForm.saveKey));
      await tester.pumpAndSettle();
      expect(find.byType(ExerciseDetailScreen), findsOneWidget);
      expect(find.text('Hack Squat (Gym 2)'), findsOneWidget);
    });

    testWidgets('error an id not in the catalog', (tester) async {
      await openDetail(tester, 'Nope');
      expect(find.text('Exercise not found'), findsOneWidget);
    });

    testWidgets('NFR-06 200 % text; 48 dp action', (tester) async {
      await openDetail(tester, 'Barbell_Squat', textScale: 2);
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byKey(ExerciseDetailScreen.addKey)).height,
        greaterThanOrEqualTo(48),
      );
    });
  });
}
