// SET-01 AC6, AC7: which plates to load on each side of the bar. Works in the
// display unit, so 45 lb plates stay exact; plates of each size are unlimited.

sealed class PlateLoad {
  const PlateLoad();
}

final class Loaded extends PlateLoad {
  const Loaded(this.perSide, this.shortBy);

  // Heaviest first.
  final List<double> perSide;
  // 0 when exact; else how much lighter the loaded bar is than asked.
  final double shortBy;
}

final class BelowBar extends PlateLoad {
  const BelowBar();
}

// Hundredths, so 1.25 and 2.5 are whole numbers.
int _c(double v) => (v * 100).round();

PlateLoad loadPlates({
  required double weight,
  required double bar,
  required List<double> plates,
}) {
  final w = _c(weight);
  final b = _c(bar);
  if (w < b) return const BelowBar();
  final target = (w - b) ~/ 2;
  final sizes = {for (final p in plates) _c(p)}.where((p) => p > 0).toList();

  // fewest[x]: fewest plates making exactly x per side; -1 when impossible.
  final fewest = List<int>.filled(target + 1, -1)..[0] = 0;
  final last = List<int>.filled(target + 1, 0);
  for (var x = 1; x <= target; x++) {
    for (final p in sizes) {
      if (p > x || fewest[x - p] < 0) continue;
      final n = fewest[x - p] + 1;
      if (fewest[x] < 0 || n < fewest[x]) {
        fewest[x] = n;
        last[x] = p;
      }
    }
  }
  var x = target;
  while (fewest[x] < 0) {
    x--;
  }
  final side = <double>[];
  for (var y = x; y > 0; y -= last[y]) {
    side.add(last[y] / 100);
  }
  side.sort((a, b) => b.compareTo(a));
  return Loaded(side, (w - b - 2 * x) / 100);
}
