import 'package:flutter/services.dart';

/// Formats a Rwanda phone number as the user types.
///
/// Input is expected to be digits only (use with [FilteringTextInputFormatter]).
/// Output pattern: XX XXX XXXX  (e.g. 78 123 4567)
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.isEmpty) {
      return newValue;
    }

    // Strip any spaces that were already in the string.
    final digitsOnly = text.replaceAll(' ', '');

    // Build the formatted string, inserting spaces at positions 2 and 5.
    final buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 2 || i == 5) {
        buffer.write(' ');
      }
      buffer.write(digitsOnly[i]);
    }

    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
