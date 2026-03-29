import 'package:flutter_test/flutter_test.dart';
import 'package:district_direct/utils/validators.dart';
import 'package:district_direct/constants/validation_constants.dart';

void main() {
  // ─────────────────────────── validateRwandaPhone ────────────────────────────

  group('Validators.validateRwandaPhone', () {
    test('accepts a bare 9-digit number starting with 78', () {
      expect(Validators.validateRwandaPhone('781234567'), isNull);
    });

    test('accepts a bare 9-digit number starting with 79', () {
      expect(Validators.validateRwandaPhone('791234567'), isNull);
    });

    test('accepts the full +250 international format', () {
      expect(Validators.validateRwandaPhone('+250781234567'), isNull);
    });

    test('accepts the 250 country code without the plus sign', () {
      expect(Validators.validateRwandaPhone('250781234567'), isNull);
    });

    test('accepts the local 0 prefix format', () {
      expect(Validators.validateRwandaPhone('0781234567'), isNull);
    });

    test('accepts a phone number that has spaces in it', () {
      expect(Validators.validateRwandaPhone('78 123 4567'), isNull);
    });

    test('rejects an empty string and returns the required field message', () {
      expect(
        Validators.validateRwandaPhone(''),
        equals(ValidationConstants.requiredFieldMessage),
      );
    });

    test('rejects null and returns the required field message', () {
      expect(
        Validators.validateRwandaPhone(null),
        equals(ValidationConstants.requiredFieldMessage),
      );
    });

    test('rejects a number that starts with 77 (not a valid Rwanda prefix)', () {
      expect(Validators.validateRwandaPhone('771234567'), isNotNull);
    });

    test('rejects a number that is too short', () {
      expect(Validators.validateRwandaPhone('7812345'), isNotNull);
    });

    test('rejects a number that contains letters', () {
      expect(Validators.validateRwandaPhone('78abc4567'), isNotNull);
    });

    test('rejects a number that is one digit too long', () {
      expect(Validators.validateRwandaPhone('7812345678'), isNotNull);
    });
  });

  // ─────────────────────────── validatePassword ───────────────────────────────

  group('Validators.validatePassword', () {
    test('accepts a password that meets all requirements', () {
      expect(Validators.validatePassword('Secure@1'), isNull);
    });

    test('accepts another valid strong password', () {
      expect(Validators.validatePassword('StrongP@ss9'), isNull);
    });

    test('rejects an empty password', () {
      expect(
        Validators.validatePassword(''),
        equals(ValidationConstants.requiredFieldMessage),
      );
    });

    test('rejects null', () {
      expect(
        Validators.validatePassword(null),
        equals(ValidationConstants.requiredFieldMessage),
      );
    });

    test('rejects a password that is only 4 characters', () {
      expect(Validators.validatePassword('Ab1@'), isNotNull);
    });

    test('rejects a password with no uppercase letter', () {
      expect(Validators.validatePassword('secure@1'), isNotNull);
    });

    test('rejects a password with no lowercase letter', () {
      expect(Validators.validatePassword('SECURE@1'), isNotNull);
    });

    test('rejects a password with no digit', () {
      expect(Validators.validatePassword('Secure@Ab'), isNotNull);
    });

    test('rejects a password with no special character', () {
      expect(Validators.validatePassword('SecurePass1'), isNotNull);
    });

    test('accepts each of the allowed special characters', () {
      for (final char in ['@', r'$', '!', '%', '*', '?', '&', '#']) {
        expect(
          Validators.validatePassword('Secure${char}1'),
          isNull,
          reason: 'should accept special character: $char',
        );
      }
    });
  });

  // ─────────────────────────── validateEmail ──────────────────────────────────

  group('Validators.validateEmail', () {
    test('accepts a standard email address', () {
      expect(Validators.validateEmail('user@example.com'), isNull);
    });

    test('accepts an email with a subdomain', () {
      expect(Validators.validateEmail('user@mail.example.com'), isNull);
    });

    test('rejects an empty string', () {
      expect(
        Validators.validateEmail(''),
        equals(ValidationConstants.requiredFieldMessage),
      );
    });

    test('rejects an address with no @ symbol', () {
      expect(Validators.validateEmail('userexample.com'), isNotNull);
    });

    test('rejects an address with no domain after @', () {
      expect(Validators.validateEmail('user@'), isNotNull);
    });

    test('rejects null', () {
      expect(
        Validators.validateEmail(null),
        equals(ValidationConstants.requiredFieldMessage),
      );
    });
  });

  // ─────────────────────────── validateNationalID ─────────────────────────────

  group('Validators.validateNationalID', () {
    // A valid citizen NID: status=1, year=1990, gender=7, rest=digits
    const validCitizenNid = '1199078123456789';
    // A valid refugee NID: status=2
    const validRefugeeNid = '2199078123456789';

    test('accepts a valid citizen NID (starts with 1)', () {
      expect(Validators.validateNationalID(validCitizenNid), isNull);
    });

    test('accepts a valid refugee NID (starts with 2)', () {
      expect(Validators.validateNationalID(validRefugeeNid), isNull);
    });

    test('returns null for an empty value when the field is optional', () {
      expect(
        Validators.validateNationalID('', isOptional: true),
        isNull,
      );
    });

    test('returns null for null when the field is optional', () {
      expect(
        Validators.validateNationalID(null, isOptional: true),
        isNull,
      );
    });

    test('rejects an empty string when the field is required', () {
      expect(Validators.validateNationalID(''), isNotNull);
    });

    test('rejects an ID that has fewer than 16 digits', () {
      expect(Validators.validateNationalID('119907812345678'), isNotNull);
    });

    test('rejects an ID that has more than 16 digits', () {
      expect(Validators.validateNationalID('11990781234567890'), isNotNull);
    });

    test('rejects an ID that starts with 4 (invalid status digit)', () {
      expect(Validators.validateNationalID('4199078123456789'), isNotNull);
    });

    test('rejects an ID that contains letters', () {
      expect(Validators.validateNationalID('119907812345678A'), isNotNull);
    });

    test('rejects an ID with an invalid gender digit (not 7 or 8)', () {
      // Position 5 (index 5) is the gender digit; use 6 which is invalid.
      expect(Validators.validateNationalID('1199068123456789'), isNotNull);
    });
  });

  // ─────────────────────────── formatPhoneNumber ──────────────────────────────

  group('Validators.formatPhoneNumber', () {
    test('formats a bare 9-digit number to the full display format', () {
      expect(
        Validators.formatPhoneNumber('781234567'),
        equals('+250 78 123 4567'),
      );
    });

    test('formats a number that already has the +250 prefix', () {
      expect(
        Validators.formatPhoneNumber('+250781234567'),
        equals('+250 78 123 4567'),
      );
    });

    test('formats a number with a leading 0', () {
      expect(
        Validators.formatPhoneNumber('0781234567'),
        equals('+250 78 123 4567'),
      );
    });

    test('returns the original string when the format is unexpected', () {
      const weird = 'not-a-phone';
      expect(Validators.formatPhoneNumber(weird), equals(weird));
    });
  });

  // ─────────────────────────── formatNationalID ───────────────────────────────

  group('Validators.formatNationalID', () {
    test('splits a 16-digit ID into the correct display groups', () {
      expect(
        Validators.formatNationalID('1199078123456789'),
        equals('1 1990 7 8123456 7 89'),
      );
    });

    test('returns the original string when the input is not 16 digits', () {
      const short = '12345';
      expect(Validators.formatNationalID(short), equals(short));
    });
  });
}
