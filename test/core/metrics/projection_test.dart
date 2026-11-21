import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/core/metrics/projection.dart';

void main() {
  final today = DateTime.utc(2026, 11, 21);
  DateTime ago(int days) => today.subtract(Duration(days: days));

  List<Measurement> line(
    double start,
    double perWeek, {
    int weeks = 6,
    int everyDays = 7,
  }) => [
    for (var d = weeks * 7; d >= 0; d -= everyDays)
      Measurement(ago(d), start + perWeek * (weeks * 7 - d) / 7),
  ];

  group('FND-04 goal projection', () {
    test('AC9 a rising lift reaches its target on the projected date', () {
      // 100 → 106 kg over 6 weeks; target 110 is 4 weeks past today.
      final p = projectGoal(history: line(100, 1), target: 110, today: today);
      expect(p, OnTrack(today.add(const Duration(days: 28))));
    });

    test('AC9 a falling body weight works the same way', () {
      final p = projectGoal(history: line(90, -0.5), target: 85, today: today);
      expect(p, OnTrack(today.add(const Duration(days: 28))));
    });

    test('AC9 only the last 8 weeks count', () {
      final history = [
        Measurement(ago(200), 50),
        Measurement(ago(150), 300),
        ...line(100, 1),
      ];
      expect(
        projectGoal(history: history, target: 110, today: today),
        OnTrack(today.add(const Duration(days: 28))),
      );
    });

    test('AC9 under 3 points or 14 days is not enough data', () {
      expect(
        projectGoal(
          history: [Measurement(ago(30), 100), Measurement(today, 102)],
          target: 110,
          today: today,
        ),
        isA<NotEnoughData>(),
      );
      expect(
        projectGoal(
          history: line(100, 1, weeks: 1, everyDays: 2),
          target: 110,
          today: today,
        ),
        isA<NotEnoughData>(),
      );
    });

    test('AC9 trend moving away or flat is not on track', () {
      expect(
        projectGoal(history: line(100, -1), target: 110, today: today),
        isA<NotOnTrack>(),
      );
      expect(
        projectGoal(history: line(100, 0), target: 110, today: today),
        isA<NotOnTrack>(),
      );
    });

    test('AC5 AC9 near-flat irregular data is not on track, never a crash', () {
      final history = [
        Measurement(ago(40).add(const Duration(hours: 7)), 80.1),
        Measurement(ago(33).add(const Duration(hours: 13)), 80.1),
        Measurement(ago(19).add(const Duration(hours: 2)), 80.1),
        Measurement(ago(3).add(const Duration(hours: 21)), 80.1),
      ];
      expect(
        projectGoal(history: history, target: 75, today: today),
        isA<NotOnTrack>(),
      );
      final drifting = [
        Measurement(ago(40), 80),
        Measurement(ago(20), 80 - 1e-7),
        Measurement(ago(1), 80 - 2e-7),
      ];
      expect(
        projectGoal(history: drifting, target: 70, today: today),
        isA<NotOnTrack>(),
      );
    });

    test('AC9 a date more than 2 years out is not on track', () {
      expect(
        projectGoal(history: line(100, 0.05), target: 200, today: today),
        isA<NotOnTrack>(),
      );
    });

    test('edge: a target already reached is on track today', () {
      expect(
        projectGoal(history: line(100, 1), target: 104, today: today),
        OnTrack(today),
      );
    });

    test('edge: a noisy trend whose line already passed the target', () {
      final history = [
        Measurement(ago(28), 100),
        Measurement(ago(21), 112),
        Measurement(ago(14), 113),
        Measurement(ago(0), 108),
      ];
      expect(
        projectGoal(history: history, target: 109, today: today),
        OnTrack(today),
      );
    });

    test('OnTrack value semantics', () {
      expect(OnTrack(today).hashCode, OnTrack(today).hashCode);
      expect('${OnTrack(today)}', contains('2026-11-21'));
    });
  });
}
