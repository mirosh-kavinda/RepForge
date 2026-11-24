import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/l10n/generated/app_localizations.dart';
import 'package:repforge/features/library/domain/exercise.dart';
import 'package:repforge/features/library/presentation/search_terms.dart';

void expectTerms(
  SearchTerms t, {
  required String text,
  Set<Muscle> muscles = const {},
  Set<Equipment> equipment = const {},
}) {
  expect(t.text, text);
  expect(t.muscles, muscles);
  expect(t.equipment, equipment);
}

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  group('WKT-01 AC3 typed muscle and equipment', () {
    test('a plain name stays a name search', () {
      expectTerms(parseSearchTerms('Leg Press', l10n), text: 'leg press');
    });

    test('muscle keys, labels and groups become muscle filters', () {
      expect(parseSearchTerms('hamstrings', l10n).muscles, {Muscle.hamstrings});
      expect(parseSearchTerms('Quads', l10n).muscles, {Muscle.quadriceps});
      expect(parseSearchTerms('arms', l10n).muscles, {
        Muscle.biceps,
        Muscle.triceps,
        Muscle.forearms,
      });
      expectTerms(
        parseSearchTerms('middle back row', l10n),
        text: 'row',
        muscles: {Muscle.middleBack},
      );
    });

    test('equipment words become equipment filters', () {
      expectTerms(
        parseSearchTerms('cable chest', l10n),
        text: '',
        muscles: {Muscle.chest},
        equipment: {Equipment.cable},
      );
      expectTerms(
        parseSearchTerms('smith machine squat', l10n),
        text: 'squat',
        equipment: {Equipment.smithMachine},
      );
    });

    test('typed filters narrow chosen ones; no overlap is null', () {
      expect(narrow({1, 2}, <int>{}), {1, 2});
      expect(narrow(<int>{}, {3}), {3});
      expect(narrow({1, 2}, {2, 3}), {2});
      expect(narrow({1}, {3}), isNull);
    });
  });
}
