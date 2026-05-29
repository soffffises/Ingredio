import 'package:flutter_test/flutter_test.dart';
import 'package:ingredio/core/utils/validators.dart';

void main() {
  group('validateName', () {
    test('returns error for null or empty values', () {
      expect(validateName(null), 'Name is required');
      expect(validateName(''), 'Name is required');
      expect(validateName('   '), 'Name is required');
    });

    test('returns null for valid names', () {
      expect(validateName('Alex'), isNull);
      expect(validateName('  Alex  '), isNull);
    });
  });
}
