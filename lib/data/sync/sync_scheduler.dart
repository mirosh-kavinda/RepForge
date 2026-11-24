import 'dart:async';

import 'remote_store.dart';
import 'sync_engine.dart';

// Who may back up: a signed-in account with a verified email (AC6, AC8).
typedef SyncUser = ({String uid, bool canBackUp});

// SYN-01 AC1, AC2, AC4, AC10: when to push and pull. Never blocks the UI;
// every trigger only starts a run.
class SyncScheduler {
  SyncScheduler({
    required SyncRunner engine,
    required Stream<SyncUser?> users,
    required Stream<int> waiting,
    required Stream<bool> online,
    required Stream<void> resumes,
    required Future<bool> Function() bodyBackup,
    this.debounce = const Duration(seconds: 5),
    this.pullEvery = const Duration(hours: 6),
    this.firstRetry = const Duration(seconds: 30),
    this.maxRetry = const Duration(hours: 1),
  }) : _engine = engine,
       _bodyBackup = bodyBackup {
    _subs = [
      users.listen(_onUser),
      waiting.listen((n) {
        if (n > 0) _soon();
      }),
      online.listen((on) {
        _online = on;
        if (on) _run(pull: false);
      }),
      resumes.listen((_) => _run(pull: true)),
    ];
  }

  final SyncRunner _engine;
  final Future<bool> Function() _bodyBackup;
  final Duration debounce;
  final Duration pullEvery;
  final Duration firstRetry;
  final Duration maxRetry;

  late final List<StreamSubscription<Object?>> _subs;
  String? _uid;
  bool _online = true;
  Timer? _debounce;
  Timer? _retry;
  Timer? _periodic;
  late Duration _backoff = firstRetry;
  Future<void>? _running;
  bool _again = false;
  bool _againPull = false;

  void _onUser(SyncUser? u) {
    _uid = u != null && u.canBackUp ? u.uid : null;
    _periodic?.cancel();
    if (_uid == null) {
      _retry?.cancel();
      _engine.recordError(u == null ? SyncErrorKind.signedOut : null);
      return;
    }
    _periodic = Timer.periodic(pullEvery, (_) => _run(pull: true));
    _run(pull: true);
  }

  void _soon() {
    _debounce?.cancel();
    _debounce = Timer(debounce, () => _run(pull: false));
  }

  // AC9: Back up now; also resets the wait after failures.
  Future<void> backUpNow() {
    _backoff = firstRetry;
    _retry?.cancel();
    return _run(pull: true);
  }

  Future<void> _run({required bool pull}) {
    if (_running != null) {
      _again = true;
      _againPull = _againPull || pull;
      return _running!;
    }
    return _running = _attempt(pull: pull).whenComplete(() {
      _running = null;
      if (_again) {
        final p = _againPull;
        _again = _againPull = false;
        _run(pull: p);
      }
    });
  }

  Future<void> _attempt({required bool pull}) async {
    final uid = _uid;
    if (uid == null) return;
    if (!_online) {
      await _engine.recordError(SyncErrorKind.offline);
      return;
    }
    // Edge: signed out or switched account mid-run: stop writing.
    bool current() => _uid == uid;
    SyncErrorKind? pullFailed;
    try {
      // A failed pull never holds up the backup (push still runs).
      if (pull) {
        try {
          await _engine.pull(uid, current: current);
        } on SyncFailure catch (e) {
          pullFailed = e.kind;
        } on Object {
          pullFailed = SyncErrorKind.server;
        }
      }
      await _engine.push(uid, withBody: await _bodyBackup(), current: current);
      if (pullFailed != null) {
        await _failed(pullFailed);
        return;
      }
      _backoff = firstRetry;
      _retry?.cancel();
    } on SyncFailure catch (e) {
      await _failed(e.kind);
    } on Object {
      await _failed(SyncErrorKind.server);
    }
  }

  Future<void> _failed(SyncErrorKind kind) async {
    await _engine.recordError(kind);
    _retry?.cancel();
    _retry = Timer(_backoff, () => _run(pull: true));
    final next = _backoff * 2;
    _backoff = next > maxRetry ? maxRetry : next;
  }

  void dispose() {
    for (final s in _subs) {
      s.cancel().ignore();
    }
    _debounce?.cancel();
    _retry?.cancel();
    _periodic?.cancel();
  }
}
