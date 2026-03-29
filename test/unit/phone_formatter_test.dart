import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:district_direct/utils/phone_number_formatter.dart';

/// Helper: run the formatter and return the new [TextEditingValue].
TextEditingValue format(String text) {
  final formatter = PhoneNumberFormatter();
  return formatter.formatEditUpdate(
    TextEditingValue.empty,
    TextEditingValue(text: text),
  );
}

void main() {
  group('PhoneNumberFormatter', () {
    test('returns empty text for an empty input', () {
      final result = format('');
      expect(result.text, isEmpty);
    });

    test('leaves a single digit unchanged', () {
      expect(format('7').text, equals('7'));
    });

    test('leaves exactly two digits unchanged (no space yet)', () {
      expect(format('78').text, equals('78'));
    });

    test('inserts a space after the second digit when a third is added', () {
      expect(format('781').text, equals('78 1'));
    });

    test('formats five digits with one space', () {
      expect(format('78123').text, equals('78 123'));
    });

    test('inserts a second space after the fifth digit', () {
      expect(format('781234').text, equals('78 123 4'));
    });

    test('produces the full XX XXX XXXX pattern for nine digits', () {
      expect(format('781234567').text, equals('78 123 4567'));
    });

    test('formats a 79-prefix number the same way', () {
      expect(format('791234567').text, equals('79 123 4567'));
    });

    test('cursor is placed at the end of the formatted text', () {
      final result = format('781234567');
      expect(result.selection.baseOffset, equals(result.text.length));
      expect(result.selection.extentOffset, equals(result.text.length));
    });

    test('collapses the selection to the end (not a range selection)', () {
      final result = format('78123');
      expect(result.selection.isCollapsed, isTrue);
    });

    test('strips existing spaces before reformatting', () {
      // Simulate text that already has spaces (e.g. from a previous format pass).
      expect(format('78 123').text, equals('78 123'));
    });

    test('handles partial input midway through the number', () {
      // Six digits → XX XXX X
      expect(format('781234').text, equals('78 123 4'));
    });
  });
}
