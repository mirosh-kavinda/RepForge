class LoggedSet {
  const LoggedSet({required this.kg, required this.reps, this.warmup = false});

  final double kg;
  final int reps;
  final bool warmup;

  bool get isWorking => !warmup && kg > 0 && reps > 0;
}

const epleyMaxReps = 12;

// Epley; a single is its own 1RM; warm-ups and > 12 reps give none (AC6).
double? e1rm(LoggedSet set) {
  if (!set.isWorking || set.reps > epleyMaxReps) return null;
  return set.reps == 1 ? set.kg : set.kg * (1 + set.reps / 30);
}

double? bestE1rm(Iterable<LoggedSet> sets) {
  double? best;
  for (final value in sets.map(e1rm).nonNulls) {
    if (best == null || value > best) best = value;
  }
  return best;
}

double volume(Iterable<LoggedSet> sets) =>
    sets.where((s) => s.isWorking).fold(0.0, (sum, s) => sum + s.kg * s.reps);
