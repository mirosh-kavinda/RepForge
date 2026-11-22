import 'logger_rules.dart';
import 'workout_session.dart';

typedef NextSet = ({String rowId, int setNo});

extension RestNext on Rest {
  NextSet? get next => nextRowId == null || nextSetNo == null
      ? null
      : (rowId: nextRowId!, setNo: nextSetNo!);

  // AC3: false between superset members, where only "Next" is shown.
  bool get counting => endsAt != null || pausedLeftMs != null;
}

// AC3: a superset member that isn't the group's last.
bool restsLater(List<SessionExercise> rows, String rowId) {
  final row = rows.firstWhere((r) => r.id == rowId);
  final g = row.superset;
  return g != null && rows.lastWhere((r) => r.superset == g).id != rowId;
}

// AC1, AC3, edge: the rest after logging a set of [rowId], or null for none
// (a superset member that isn't the group's last, or a rest time of 0).
int? restAfterLog(List<SessionExercise> rows, String rowId) {
  if (restsLater(rows, rowId)) return null;
  final row = rows.firstWhere((r) => r.id == rowId);
  return row.restSec > 0 ? row.restSec : null;
}

List<int> _open(WorkoutSession s, SessionExercise row) {
  final logged = s.setsOf(row.id);
  final done = {for (final x in logged) x.setNo};
  return [
    for (var n = 1; n <= setCount(row, logged); n++)
      if (!done.contains(n)) n,
  ];
}

// AC1, AC3: the next set to do after logging one of [rowId]. In a superset,
// the next member, cycling back to the first; otherwise the same exercise,
// then the ones after it, then any left earlier.
NextSet? nextUp(WorkoutSession s, String rowId) {
  final rows = s.exercises;
  final i = rows.indexWhere((r) => r.id == rowId);
  if (i < 0) return null;
  final order = <SessionExercise>[];
  if (rows[i].superset case final g?) {
    final group = rows.where((r) => r.superset == g).toList();
    final k = group.indexWhere((r) => r.id == rowId);
    order.addAll([...group.sublist(k + 1), ...group.sublist(0, k + 1)]);
  } else {
    order.add(rows[i]);
  }
  order.addAll([...rows.sublist(i + 1), ...rows.sublist(0, i)]);
  for (final r in order) {
    final open = _open(s, r);
    if (open.isNotEmpty) return (rowId: r.id, setNo: open.first);
  }
  return null;
}

Rest startRest(DateTime now, int seconds, NextSet? next) => Rest(
  endsAt: now.add(Duration(seconds: seconds)),
  nextRowId: next?.rowId,
  nextSetNo: next?.setNo,
);

// AC3: "Next" only, no countdown.
Rest nextOnly(NextSet? next) =>
    Rest(nextRowId: next?.rowId, nextSetNo: next?.setNo);

Duration left(Rest r, DateTime now) {
  if (r.pausedLeftMs case final ms?) return Duration(milliseconds: ms);
  final end = r.endsAt;
  if (end == null) return Duration.zero;
  final d = end.difference(now);
  return d.isNegative ? Duration.zero : d;
}

bool isOver(Rest r, DateTime now) =>
    r.endsAt != null && r.pausedLeftMs == null && !now.isBefore(r.endsAt!);

// AC4: this rest only; past zero it ends at once (edge).
Rest adjustRest(Rest r, int seconds, DateTime now) {
  final delta = Duration(seconds: seconds);
  if (r.pausedLeftMs case final ms?) {
    final next = Duration(milliseconds: ms) + delta;
    return r.copyWith(pausedLeftMs: next.isNegative ? 0 : next.inMilliseconds);
  }
  final end = r.endsAt!.add(delta);
  return r.copyWith(endsAt: end.isBefore(now) ? now : end);
}

Rest pauseRest(Rest r, DateTime now) =>
    r.copyWith(endsAt: null, pausedLeftMs: left(r, now).inMilliseconds);

Rest resumeRest(Rest r, DateTime now) => r.copyWith(
  endsAt: now.add(Duration(milliseconds: r.pausedLeftMs ?? 0)),
  pausedLeftMs: null,
);
