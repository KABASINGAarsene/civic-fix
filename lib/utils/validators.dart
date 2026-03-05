import '../constants/validation_constants.dart';

/// Validators for DistrictDirect App
/// Provides validation functions for Rwandan phone numbers, National IDs, and passwords

class Validators {
  /// Validates Rwanda phone number
  /// Accepts formats: +250781234567, 250781234567, 0781234567, 781234567
  /// Valid prefixes: 78, 79
  static String? validateRwandaPhone(String? value) {
    if (value == null || value.isEmpty) {
      return ValidationConstants.requiredFieldMessage;
    }

    // Remove spaces and normalize
    String cleaned = value.replaceAll(RegExp(r'\s+'), '');

    // Remove leading + if present
    if (cleaned.startsWith('+')) {
      cleaned = cleaned.substring(1);
    }

    // Remove leading 0 if present (local format)
    if (cleaned.startsWith('0')) {
      cleaned = cleaned.substring(1);
    }

    // If starts with 250, remove it
    if (cleaned.startsWith('250')) {
      cleaned = cleaned.substring(3);
    }

    // Now should have 9 digits starting with 78 or 79
    if (cleaned.length != ValidationConstants.phoneNumberLength) {
      return ValidationConstants.phoneErrorMessage;
    }

    // Check if starts with valid prefix
    if (!ValidationConstants.validPhonePrefixes.any(
      (prefix) => cleaned.startsWith(prefix),
    )) {
      return ValidationConstants.phoneErrorMessage;
    }

    // Check if all characters are digits
    if (!RegExp(r'^\d+$').hasMatch(cleaned)) {
      return ValidationConstants.phoneErrorMessage;
    }

    return null; // Valid
  }

  /// Validates Rwanda National ID (NID)
  /// 16 digits with structure validation
  static String? validateNationalID(String? value, {bool isOptional = false}) {
    if (value == null || value.isEmpty) {
      if (isOptional) {
        return null; // Optional field, no error
      }
      return ValidationConstants.requiredFieldMessage;
    }

    // Remove spaces
    String cleaned = value.replaceAll(RegExp(r'\s+'), '');

    // Check if exactly 16 digits
    if (cleaned.length != 16) {
      return ValidationConstants.nidErrorMessage;
    }

    // Check if all characters are digits
    if (!RegExp(r'^\d+$').hasMatch(cleaned)) {
      return ValidationConstants.nidErrorMessage;
    }

    // Validate first digit (status: 1=citizen, 2=refugee, 3=foreigner)
    if (!ValidationConstants.validNidFirstDigits.contains(cleaned[0])) {
      return 'National ID must start with 1 (citizen), 2 (refugee), or 3 (foreigner)';
    }

    // Validate year of birth (digits 2-5)
    String yearStr = cleaned.substring(1, 5);
    int? year = int.tryParse(yearStr);
    if (year == null || year < 1900 || year > DateTime.now().year) {
      return 'Invalid year of birth in National ID';
    }

    // Validate gender digit (6th digit: 7=female, 8=male)
    if (!ValidationConstants.validGenderDigits.contains(cleaned[5])) {
      return 'Invalid gender code in National ID (must be 7 or 8)';
    }

    return null; // Valid
  }

  /// Validates strong password
  /// Requirements:
  /// - Minimum 8 characters
  /// - At least 1 uppercase letter
  /// - At least 1 lowercase letter
  /// - At least 1 number
  /// - At least 1 special character
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return ValidationConstants.requiredFieldMessage;
    }

    if (value.length < ValidationConstants.minPasswordLength) {
      return 'Password must be at least ${ValidationConstants.minPasswordLength} characters';
    }

    if (value.length > ValidationConstants.maxPasswordLength) {
      return 'Password must not exceed ${ValidationConstants.maxPasswordLength} characters';
    }

    // Check for uppercase
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for lowercase
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for digit
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Password must contain at least one number';
    }

    // Check for special character
    if (!RegExp(r'[@$!%*?&#]').hasMatch(value)) {
      return 'Password must contain at least one special character (@\$!%*?&#)';
    }

    return null; // Valid
  }

  /// Validates email (generic email validation for future use)
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return ValidationConstants.requiredFieldMessage;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Format phone number to display format
  /// Converts various inputs to: +250 78 123 4567
  static String formatPhoneNumber(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'\s+'), '');

    // Remove leading +
    if (cleaned.startsWith('+')) {
      cleaned = cleaned.substring(1);
    }

    // Remove leading 0
    if (cleaned.startsWith('0')) {
      cleaned = cleaned.substring(1);
    }

    // Remove country code if present
    if (cleaned.startsWith('250')) {
      cleaned = cleaned.substring(3);
    }

    // Format: +250 78 123 4567
    if (cleaned.length == 9) {
      return '+250 ${cleaned.substring(0, 2)} ${cleaned.substring(2, 5)} ${cleaned.substring(5)}';
    }

    return phone; // Return original if format unexpected
  }

  /// Format National ID for display
  /// Converts to groups: 1 2023 8 1234567 1 23
  static String formatNationalID(String nid) {
    String cleaned = nid.replaceAll(RegExp(r'\s+'), '');

    if (cleaned.length == 16) {
      return '${cleaned.substring(0, 1)} ${cleaned.substring(1, 5)} ${cleaned.substring(5, 6)} ${cleaned.substring(6, 13)} ${cleaned.substring(13, 14)} ${cleaned.substring(14)}';
    }

    return nid; // Return original if format unexpected
  }
}
