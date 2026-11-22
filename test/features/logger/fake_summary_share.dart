import 'dart:typed_data';

import 'package:repforge/features/logger/domain/summary_share.dart';

class FakeSummaryShare implements SummaryShare {
  final shared = <({Uint8List png, String fileName, String text})>[];
  Object? failWith;

  @override
  Future<void> shareImage(
    Uint8List png, {
    required String fileName,
    required String text,
  }) async {
    if (failWith case final e?) throw e;
    shared.add((png: png, fileName: fileName, text: text));
  }
}
