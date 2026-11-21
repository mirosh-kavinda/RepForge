import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/local/database_provider.dart';
import '../domain/cycle.dart';
import '../domain/cycle_repository.dart';
import 'drift_cycle_repository.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
CycleRepository cycleRepository(Ref ref) =>
    DriftCycleRepository(ref.watch(appDatabaseProvider));

@riverpod
Stream<List<Cycle>> cycles(Ref ref) =>
    ref.watch(cycleRepositoryProvider).watchAll();

@riverpod
Stream<Cycle?> activeCycle(Ref ref) =>
    ref.watch(cycleRepositoryProvider).watchActive();
