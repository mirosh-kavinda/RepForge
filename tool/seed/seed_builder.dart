import 'dart:convert';

const seedCatalogVersion = 1;
const seedSourceCommit = 'f00c92c7dcf1216a928a52c3706c7ce8e2f71ed5';

const muscles = {
  'chest',
  'shoulders',
  'triceps',
  'biceps',
  'forearms',
  'lats',
  'middle back',
  'lower back',
  'traps',
  'abdominals',
  'quadriceps',
  'hamstrings',
  'glutes',
  'calves',
  'adductors',
  'abductors',
  'neck',
};
const equipment = {
  'barbell',
  'dumbbell',
  'cable',
  'machine',
  'kettlebell',
  'bands',
  'body only',
  'EZ bar',
  'smith machine',
  'other',
};
const _equipmentMapping = {
  'kettlebells': 'kettlebell',
  'e-z curl bar': 'EZ bar',
  'foam roll': 'other',
  'medicine ball': 'other',
  'exercise ball': 'other',
};
const categories = {
  'strength',
  'powerlifting',
  'olympic weightlifting',
  'strongman',
  'plyometrics',
  'stretching',
  'cardio',
};
const levels = {'beginner', 'intermediate', 'expert'};
const mechanics = {'compound', 'isolation'};
const forces = {'push', 'pull', 'static'};

class SeedError implements Exception {
  SeedError(this.exerciseId, this.field, this.value);

  final String exerciseId;
  final String field;
  final Object? value;

  @override
  String toString() => 'SeedError: $exerciseId has $field = "$value"';
}

Map<String, Object?> buildSeed(
  List<Map<String, Object?>> source, {
  required int catalogVersion,
  required String sourceCommit,
}) {
  final byId = <String, Map<String, Object?>>{};
  for (final raw in source) {
    final e = _exercise(raw);
    final id = e['id']! as String;
    if (byId.containsKey(id)) throw SeedError(id, 'id', 'duplicate');
    byId[id] = e;
  }
  final ids = byId.keys.toList()..sort();
  return {
    'catalogVersion': catalogVersion,
    'source': sourceCommit,
    'exercises': [for (final id in ids) byId[id]],
  };
}

// One exercise per line keeps diffs of the committed seed readable.
String encodeSeed(Map<String, Object?> seed) {
  final lines = (seed['exercises']! as List).map(jsonEncode).join(',\n');
  return '{"catalogVersion":${seed['catalogVersion']},'
      '"source":${jsonEncode(seed['source'])},'
      '"exercises":[\n$lines\n]}\n';
}

Map<String, Object?> _exercise(Map<String, Object?> raw) {
  final id = (raw['id'] as String?)?.trim() ?? '';
  if (id.isEmpty) throw SeedError('?', 'id', raw['id']);
  final name = _clean(raw['name'] as String? ?? '');
  if (name.isEmpty) throw SeedError(id, 'name', raw['name']);

  String pick(String field, Set<String> allowed) {
    final value = raw[field];
    if (value is! String || !allowed.contains(value)) {
      throw SeedError(id, field, value);
    }
    return value;
  }

  String? pickOptional(String field, Set<String> allowed) =>
      raw[field] == null ? null : pick(field, allowed);

  List<String> pickMuscles(String field) {
    final values = (raw[field] as List? ?? const []).cast<String>();
    for (final m in values) {
      if (!muscles.contains(m)) throw SeedError(id, field, m);
    }
    return values;
  }

  final primary = pickMuscles('primaryMuscles');
  if (primary.isEmpty) throw SeedError(id, 'primaryMuscles', 'none');
  final secondary = pickMuscles(
    'secondaryMuscles',
  ).where((m) => !primary.contains(m)).toList();

  final exercise = <String, Object?>{
    'id': id,
    'name': name,
    'primaryMuscles': primary,
    'secondaryMuscles': secondary,
    'equipment': _equipment(id, name, raw['equipment']),
    'category': pick('category', categories),
    'level': pick('level', levels),
    'mechanic': pickOptional('mechanic', mechanics),
    'force': pickOptional('force', forces),
    'instructions': [
      for (final line
          in (raw['instructions'] as List? ?? const []).cast<String>())
        if (_clean(line).isNotEmpty) _clean(line),
    ],
    'images': (raw['images'] as List? ?? const []).cast<String>(),
  };
  exercise['hash'] = _fnv1a(jsonEncode(exercise));
  return exercise;
}

String _equipment(String id, String name, Object? value) {
  if (name.toLowerCase().contains('smith')) return 'smith machine';
  if (value == null) return 'body only';
  if (value is! String) throw SeedError(id, 'equipment', value);
  final mapped = _equipmentMapping[value] ?? value;
  if (!equipment.contains(mapped)) throw SeedError(id, 'equipment', value);
  return mapped;
}

String _clean(String s) => s.trim().replaceAll(RegExp(r'\s+'), ' ');

String _fnv1a(String s) {
  var hash = 0x811c9dc5;
  for (final unit in utf8.encode(s)) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash.toRadixString(16).padLeft(8, '0');
}
