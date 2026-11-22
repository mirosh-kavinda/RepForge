import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

import '../domain/summary_share.dart';

class SharePlusSummaryShare implements SummaryShare {
  @override
  Future<void> shareImage(
    Uint8List png, {
    required String fileName,
    required String text,
  }) => SharePlus.instance.share(
    ShareParams(
      text: text,
      files: [XFile.fromData(png, mimeType: 'image/png', name: fileName)],
      fileNameOverrides: [fileName],
    ),
  );
}
