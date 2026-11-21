import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/core/ids.dart';

void main() {
  group('FND-03 ids', () {
    test('AC7 v7, unique, time-ordered', () async {
      final ids = <String>[];
      for (var i = 0; i < 200; i++) {
        ids.add(newId());
        if (i % 50 == 0) {
          await Future<void>.delayed(const Duration(milliseconds: 2));
        }
      }
      final v7 = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      );
      expect(ids.every(v7.hasMatch), isTrue);
      expect(ids.toSet(), hasLength(ids.length));
      final first = ids.first;
      final later = ids.last;
      expect(first.compareTo(later), lessThan(0));
    });
  });
}
