import 'dart:typed_data';

// LOG-05 AC7: hands the summary image to the phone's share sheet. Behind a
// port so tests never open the platform sheet.
abstract interface class SummaryShare {
  // Completes when the sheet closes, shared or cancelled.
  Future<void> shareImage(
    Uint8List png, {
    required String fileName,
    required String text,
  });
}
