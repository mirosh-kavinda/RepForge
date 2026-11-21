import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clock.g.dart';

// The phone's current time; tests override it to pin "today".
@Riverpod(keepAlive: true)
DateTime Function() clock(Ref ref) => DateTime.now;
