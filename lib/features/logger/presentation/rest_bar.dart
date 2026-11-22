import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../core/clock.dart';
import '../data/providers.dart';
import '../domain/rest_timer.dart';
import '../domain/workout_session.dart';

String mmss(Duration d) {
  final s = (d.inMilliseconds / 1000).ceil();
  return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
}

String _nextText(AppLocalizations l10n, WorkoutSession s, Rest r) {
  final n = r.next;
  if (n == null) return l10n.restLastSet;
  final row = s.exercises.where((e) => e.id == n.rowId);
  return row.isEmpty
      ? l10n.restLastSet
      : l10n.restNext(row.first.name, n.setNo);
}

// LOG-03: every change to the rest goes through here, so the stored rest and
// the one pending alert always agree (AC2, AC4, AC8).
class RestActions {
  RestActions(this.ref, this.l10n);

  final WidgetRef ref;
  final AppLocalizations l10n;
  static var _asked = false;

  DateTime get _now => ref.read(clockProvider)().toUtc();

  Future<void> _write(WorkoutSession s, Rest? rest) async {
    try {
      await ref.read(sessionRepositoryProvider).setRest(s.id, rest);
    } on Object {
      // The set is saved; only this rest is lost (plan: errors).
    }
  }

  Future<void> _schedule(WorkoutSession s, Rest? rest) async {
    final alarm = ref.read(restAlarmProvider);
    try {
      await alarm.cancel();
      if (rest?.endsAt case final at? when !isOver(rest!, _now)) {
        await alarm.schedule(
          at,
          title: l10n.restOver,
          body: _nextText(l10n, s, rest),
        );
      }
    } on Object {
      // No alert; the in-app countdown still runs.
    }
  }

  Future<void> _apply(WorkoutSession s, Rest? rest) async {
    await _write(s, rest);
    await _schedule(s, rest);
  }

  // AC1–AC3, AC7: after a set of [rowId] is logged; [s] includes it.
  Future<void> afterLog(WorkoutSession s, String rowId) async {
    final now = _now;
    final next = nextUp(s, rowId);
    if (restsLater(s.exercises, rowId)) return _apply(s, nextOnly(next));
    final secs = restAfterLog(s.exercises, rowId);
    if (secs == null) return _apply(s, null);
    final rest = startRest(now, secs, next);
    if (_asked) return _apply(s, rest);
    _asked = true;
    // The countdown starts at the log, not when the permission dialog closes.
    await _write(s, rest);
    try {
      final alarm = ref.read(restAlarmProvider);
      if (!await alarm.allowed()) await alarm.request();
    } on Object {
      // Permission UI failed; the in-app timer still works.
    }
    await _schedule(s, rest);
  }

  Future<void> adjust(WorkoutSession s, int seconds) =>
      _apply(s, adjustRest(s.rest!, seconds, _now));

  Future<void> pause(WorkoutSession s) => _apply(s, pauseRest(s.rest!, _now));

  Future<void> resume(WorkoutSession s) => _apply(s, resumeRest(s.rest!, _now));

  // Skip and Dismiss both end the rest with no alert.
  Future<void> clear(WorkoutSession s) => _apply(s, null);

  // AC8: Finish and Discard leave no alert behind.
  Future<void> cancelAlarm() async {
    try {
      await ref.read(restAlarmProvider).cancel();
    } on Object {
      // Nothing to cancel.
    }
  }

  @visibleForTesting
  static void resetAsked() => _asked = false;
}

// Screen 02's rest bar (AC1, AC4–AC7, NFR-06).
class RestBar extends ConsumerStatefulWidget {
  const RestBar({required this.session, super.key});

  static const minusKey = ValueKey('rest.minus');
  static const plusKey = ValueKey('rest.plus');
  static const pauseKey = ValueKey('rest.pause');
  static const skipKey = ValueKey('rest.skip');
  static const dismissKey = ValueKey('rest.dismiss');
  static const settingsKey = ValueKey('rest.settings');

  final WorkoutSession session;

  @override
  ConsumerState<RestBar> createState() => _RestBarState();
}

class _RestBarState extends ConsumerState<RestBar> with WidgetsBindingObserver {
  Timer? _tick;
  bool? _allowed;
  late bool _wasOver;
  Rest? _announcedFor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Coming back to a rest that already ended: the alert has been given.
    final rest = widget.session.rest;
    _wasOver = rest != null && isOver(rest, ref.read(clockProvider)().toUtc());
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    _checkAllowed();
  }

  // AC7: back from the phone's settings.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkAllowed();
  }

  @override
  void didUpdateWidget(RestBar old) {
    super.didUpdateWidget(old);
    if (old.session.rest != widget.session.rest) _checkAllowed();
  }

  Future<void> _checkAllowed() async {
    if (!(widget.session.rest?.counting ?? false)) return;
    try {
      final a = await ref.read(restAlarmProvider).allowed();
      if (mounted && a != _allowed) setState(() => _allowed = a);
    } on Object {
      // Unknown: show nothing about it.
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tick?.cancel();
    super.dispose();
  }

  void _announce(String text) {
    final view = View.maybeOf(context);
    if (view == null) return;
    SemanticsService.sendAnnouncement(view, text, Directionality.of(context));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final s = widget.session;
    final rest = s.rest;
    if (rest == null) {
      _wasOver = false;
      return const SizedBox.shrink();
    }
    final now = ref.read(clockProvider)().toUtc();
    final over = isOver(rest, now);
    final paused = rest.pausedLeftMs != null;
    final remaining = mmss(left(rest, now));
    final actions = RestActions(ref, l10n);
    final next = _nextText(l10n, s, rest);

    // Announced at start, on a change and at the end, never every second.
    if (over && !_wasOver) {
      _wasOver = true;
      HapticFeedback.vibrate();
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _announce('${l10n.restOver}. $next'),
      );
    } else if (!over) {
      _wasOver = false;
      if (rest != _announcedFor) {
        _announcedFor = rest;
        final text = !rest.counting
            ? next
            : paused
            ? l10n.restPausedLeft(remaining)
            : l10n.restLeft(remaining);
        WidgetsBinding.instance.addPostFrameCallback((_) => _announce(text));
      }
    }

    if (!rest.counting) {
      return Material(
        color: c.surface,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: RfSpace.s16,
              vertical: RfSpace.s12,
            ),
            child: Text(next, style: t.label.copyWith(color: c.textMuted)),
          ),
        ),
      );
    }

    Widget control(Key key, IconData icon, String tip, VoidCallback onTap) =>
        IconButton(
          key: key,
          tooltip: tip,
          icon: Icon(icon),
          constraints: const BoxConstraints(
            minWidth: RfSize.minTarget,
            minHeight: RfSize.minTarget,
          ),
          onPressed: onTap,
        );

    return Material(
      color: over ? c.tint(RfRole.success) : c.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: RfSpace.s16,
            vertical: RfSpace.s8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: RfSpace.s8,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        over
                            ? l10n.restOver
                            : paused
                            ? l10n.restPausedLeft(remaining)
                            : l10n.restLeft(remaining),
                        style: t.heading,
                      ),
                      Text(next, style: t.label.copyWith(color: c.textMuted)),
                    ],
                  ),
                  if (over)
                    TextButton(
                      key: RestBar.dismissKey,
                      style: TextButton.styleFrom(
                        minimumSize: const Size(
                          RfSize.minTarget,
                          RfSize.minTarget,
                        ),
                      ),
                      onPressed: () => actions.clear(s),
                      child: Text(l10n.restDismiss),
                    )
                  else
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        control(
                          RestBar.minusKey,
                          Icons.remove,
                          l10n.restMinus,
                          () => actions.adjust(s, -15),
                        ),
                        control(
                          RestBar.plusKey,
                          Icons.add,
                          l10n.restPlus,
                          () => actions.adjust(s, 15),
                        ),
                        control(
                          RestBar.pauseKey,
                          paused ? Icons.play_arrow : Icons.pause,
                          paused ? l10n.restResume : l10n.restPause,
                          () => paused ? actions.resume(s) : actions.pause(s),
                        ),
                        control(
                          RestBar.skipKey,
                          Icons.skip_next,
                          l10n.restSkip,
                          () => actions.clear(s),
                        ),
                      ],
                    ),
                ],
              ),
              if (_allowed == false)
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: RfSpace.s8,
                  children: [
                    Text(
                      l10n.restNotificationsOff,
                      style: t.label.copyWith(color: c.textSecondary),
                    ),
                    TextButton(
                      key: RestBar.settingsKey,
                      style: TextButton.styleFrom(
                        minimumSize: const Size(
                          RfSize.minTarget,
                          RfSize.minTarget,
                        ),
                      ),
                      onPressed: () =>
                          ref.read(restAlarmProvider).openSettings(),
                      child: Text(l10n.restOpenSettings),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
