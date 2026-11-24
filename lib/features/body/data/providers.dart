import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/local/database_provider.dart';
import '../domain/body_repository.dart';
import '../domain/body_snapshot.dart';
import 'drift_body_repository.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
BodyRepository bodyRepository(Ref ref) =>
    DriftBodyRepository(ref.watch(appDatabaseProvider));

@riverpod
Stream<BodyProfile> bodyProfile(Ref ref) =>
    ref.watch(bodyRepositoryProvider).watchProfile();

// BOD-01 AC1, AC7: newest first.
@riverpod
Stream<List<BodySnapshot>> bodySnapshots(Ref ref) =>
    ref.watch(bodyRepositoryProvider).watchAll();

@riverpod
Future<BodySnapshot?> bodySnapshot(Ref ref, String id) =>
    ref.watch(bodyRepositoryProvider).byId(id);
