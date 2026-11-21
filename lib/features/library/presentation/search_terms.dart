import '../../../app/l10n/generated/app_localizations.dart';
import '../domain/exercise.dart';
import 'muscle_groups.dart';

typedef SearchTerms = ({
  String text,
  Set<Muscle> muscles,
  Set<Equipment> equipment,
});

// WKT-01 AC3: whole words naming a muscle, group or equipment become
// filters; the rest is searched in names. "cable chest" = cable + chest.
SearchTerms parseSearchTerms(String raw, AppLocalizations l10n) {
  final words = raw
      .toLowerCase()
      .split(RegExp(r'[^\p{L}\p{N}]+', unicode: true))
      .where((w) => w.isNotEmpty)
      .toList();

  final muscleNames = <String, Set<Muscle>>{
    for (final m in Muscle.values) ...{
      m.key: {m},
      muscleLabel(l10n, m).toLowerCase(): {m},
    },
    for (final g in MuscleGroup.values)
      muscleGroupLabel(l10n, g).toLowerCase(): g.muscles,
  };
  final equipmentNames = <String, Equipment>{
    for (final e in Equipment.values) ...{
      e.key.toLowerCase(): e,
      equipmentLabel(l10n, e).toLowerCase(): e,
    },
  };

  final muscles = <Muscle>{};
  final equipment = <Equipment>{};
  final rest = <String>[];
  for (var i = 0; i < words.length; i++) {
    // Two-word names first: "middle back", "body only", "smith machine".
    if (i + 1 < words.length) {
      final pair = '${words[i]} ${words[i + 1]}';
      if (muscleNames[pair] case final m?) {
        muscles.addAll(m);
        i++;
        continue;
      }
      if (equipmentNames[pair] case final e?) {
        equipment.add(e);
        i++;
        continue;
      }
    }
    if (muscleNames[words[i]] case final m?) {
      muscles.addAll(m);
    } else if (equipmentNames[words[i]] case final e?) {
      equipment.add(e);
    } else {
      rest.add(words[i]);
    }
  }
  return (text: rest.join(' '), muscles: muscles, equipment: equipment);
}

// A typed filter narrows a chosen one; null means they do not overlap, so
// nothing can match.
Set<T>? narrow<T>(Set<T> chosen, Set<T> typed) {
  if (typed.isEmpty) return chosen;
  if (chosen.isEmpty) return typed;
  final both = chosen.intersection(typed);
  return both.isEmpty ? null : both;
}
