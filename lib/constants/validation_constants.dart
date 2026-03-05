/// Validation Constants for DistrictDirect App
/// Contains regex patterns, rules, and error messages for form validation

class ValidationConstants {
  // Rwanda Phone Number Validation
  // Format: +250 78/79 followed by 7 digits
  static const String phonePattern = r'^(\+?250)?\s?(78|79)\d{7}$';
  static const String phoneErrorMessage =
      'Please enter a valid Rwandan phone number (+250 78/79 followed by 7 digits)';

  // Rwanda National ID (NID) Validation
  // 16 digits with specific structure:
  // 1st digit: 1 (citizen), 2 (refugee), 3 (foreigner)
  // 2nd-5th: Year of birth
  // 6th: Gender (7=female, 8=male)
  // 7th-13th: Birth order/sequence
  // 14th: Times issued
  // 15th-16th: Checksum
  static const String nidPattern = r'^[123]\d{15}$';
  static const String nidErrorMessage =
      'National ID must be 16 digits starting with 1, 2, or 3';

  // Password Validation Rules
  // Minimum 8 characters
  // At least 1 uppercase letter
  // At least 1 lowercase letter
  // At least 1 number
  // At least 1 special character
  static const String passwordPattern =
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&#])[A-Za-z\d@$!%*?&#]{8,}$';
  static const String passwordErrorMessage =
      'Password must be at least 8 characters with uppercase, lowercase, number, and special character';

  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;

  // Rwanda-specific NID validation helpers
  static const List<String> validNidFirstDigits = ['1', '2', '3'];
  static const List<String> validGenderDigits = ['7', '8'];

  // Phone number formatting
  static const String phoneCountryCode = '+250';
  static const List<String> validPhonePrefixes = ['78', '79'];
  static const int phoneNumberLength = 9; // After +250
  static const int totalPhoneLength = 13; // +250 + 9 digits

  // Generic validation messages
  static const String requiredFieldMessage = 'This field is required';
  static const String invalidFormatMessage = 'Invalid format';
}
