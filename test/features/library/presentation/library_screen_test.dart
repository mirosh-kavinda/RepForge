import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/app.dart';
import 'package:repforge/features/library/data/providers.dart';
import 'package:repforge/features/library/presentation/exercise_detail_screen.dart';
import 'package:repforge/features/library/presentation/library_screen.dart';
import 'package:repforge/features/logger/domain/workout_session.dart';

import '../../../helpers/app_overrides.dart';
import '../../logger/fake_session_repository.dart';
import '../library_fakes.dart';

WorkoutSession done(String id, String exerciseId, DateTime end) =>
    WorkoutSession(
      id: id,
      name: 'W',
      exercises: [
        SessionExercise(id: 'r', exerciseId: exerciseId, name: exerciseId),
      ],
      date: DateTime.utc(end.year, end.month, end.day),
      startedAt: end.subtract(const Duration(hours: 1)),
      endedAt: end,
      sets: [
        LoggedSet(
          id: '$id-1',
          rowId: 'r',
          exerciseId: exerciseId,
          setNo: 1,
          kg: 60,
          reps: 5,
        ),
      ],
    );

late FakeSessionRepository sessions;

Future<void> openLibrary(
  WidgetTester tester, {
  List<WorkoutSession> finished = const [],
  double textScale = 1,
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = const Size(390, 844);
  addTearDown(tester.view.reset);
  sessions = FakeSessionRepository()..finishedList.addAll(finished);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...signedInOverrides(sessions: sessions),
        exerciseCatalogProvider.overrideWith((ref) async => LibraryCatalog()),
      ],
      child: MediaQuery.withClampedTextScaling(
        minScaleFactor: textScale,
        maxScaleFactor: textScale,
        child: const RepForgeApp(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('Library'),
    ),
  );
  await tester.pumpAndSettle();
}

List<String> names(WidgetTester tester) => [
  for (final row in tester.widgetList<ExerciseRow>(find.byType(ExerciseRow)))
    row.exercise.name,
];

Future<void> type(WidgetTester tester, String text) async {
  await tester.enterText(find.byKey(LibraryScreen.searchKey), text);
  await tester.pumpAndSettle();
}

void main() {
  group('EXL-01 library', () {
    testWidgets('AC1 recent first, newest first, then A–Z', (tester) async {
      await openLibrary(
        tester,
        finished: [
          done('a', 'Barbell_Squat', DateTime.utc(2026, 11, 16, 10)),
          done('b', 'Leg_Press', DateTime.utc(2026, 11, 18, 10)),
          done('c', 'Gone_From_Catalog', DateTime.utc(2026, 11, 19, 10)),
        ],
      );
      expect(find.text('RECENT'), findsOneWidget);
      expect(find.text('ALL EXERCISES'), findsOneWidget);
      expect(names(tester), [
        'Leg Press',
        'Barbell Squat',
        'Barbell Squat',
        'Bench Press',
        'Leg Press',
        'Plank',
      ]);
    });

    testWidgets('AC1 with no history only the A–Z list', (tester) async {
      await openLibrary(tester);
      expect(find.text('RECENT'), findsNothing);
      expect(find.text('ALL EXERCISES'), findsNothing);
      expect(names(tester), [
        'Barbell Squat',
        'Bench Press',
        'Leg Press',
        'Plank',
      ]);
    });

    testWidgets('AC1 Recent updates when a workout finishes', (tester) async {
      await openLibrary(tester);
      expect(find.text('RECENT'), findsNothing);
      sessions.finishedList.add(
        done('a', 'Plank', DateTime.utc(2026, 11, 23, 10)),
      );
      sessions.notify();
      await tester.pumpAndSettle();
      expect(find.text('RECENT'), findsOneWidget);
      expect(names(tester).first, 'Plank');
    });

    testWidgets('AC3 a filter alone hides Recent', (tester) async {
      await openLibrary(
        tester,
        finished: [done('a', 'Plank', DateTime.utc(2026, 11, 16, 10))],
      );
      await tester.tap(find.text('Core'));
      await tester.pumpAndSettle();
      expect(find.text('RECENT'), findsNothing);
      expect(names(tester), ['Plank']);
    });

    testWidgets('AC2 search as you type; Recent hides; spaces are empty', (
      tester,
    ) async {
      await openLibrary(
        tester,
        finished: [done('a', 'Plank', DateTime.utc(2026, 11, 16, 10))],
      );
      await type(tester, 'press');
      expect(names(tester), ['Bench Press', 'Leg Press']);
      expect(find.text('RECENT'), findsNothing);
      await type(tester, '   ');
      expect(find.text('RECENT'), findsOneWidget);
      expect(names(tester), hasLength(5));
    });

    testWidgets('AC3 muscle group and equipment filters combine with text', (
      tester,
    ) async {
      await openLibrary(tester);
      await tester.tap(find.text('Legs'));
      await tester.pumpAndSettle();
      expect(names(tester), ['Barbell Squat', 'Leg Press']);
      await tester.tap(find.text('Equipment: All'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Machine'));
      await tester.pumpAndSettle();
      expect(names(tester), ['Leg Press']);
      await type(tester, 'squat');
      expect(find.text('No exercises match'), findsOneWidget);
      await tester.tap(find.byKey(LibraryScreen.clearKey));
      await tester.pumpAndSettle();
      expect(names(tester), hasLength(4));
      expect(find.text('Equipment: All'), findsOneWidget);
    });

    testWidgets('AC4 a row shows equipment and main muscles; opens detail', (
      tester,
    ) async {
      await openLibrary(tester);
      expect(find.text('Barbell · Quads'), findsOneWidget);
      await tester.tap(find.text('Bench Press'));
      await tester.pumpAndSettle();
      expect(find.byType(ExerciseDetailScreen), findsOneWidget);
      expect(find.text('Chest'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(LibraryScreen), findsOneWidget);
    });

    testWidgets('NFR-06 labelled rows; fits at 200 % text', (tester) async {
      final handle = tester.ensureSemantics();
      await openLibrary(tester, textScale: 2);
      expect(tester.takeException(), isNull);
      expect(
        find.bySemanticsLabel('Open Barbell Squat, Barbell · Quads'),
        findsOneWidget,
      );
      expect(
        tester.getSize(find.byType(ExerciseRow).first).height,
        greaterThanOrEqualTo(48),
      );
      handle.dispose();
    });
  });
}
