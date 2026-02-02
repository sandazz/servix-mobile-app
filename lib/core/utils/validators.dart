import 'package:servix/core/config/app_config.dart';

/// Validation utilities
class Validators {
  Validators._();

  /// Email validation regex
  static final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  /// Phone number validation (E.164 format)
  static final RegExp _phoneRegex = RegExp(r'^\+[1-9]\d{6,14}$');

  /// Australian phone number validation
  static final RegExp _auPhoneRegex = RegExp(r'^\+61\d{9}$');

  /// ABN validation (11 digits)
  static final RegExp _abnRegex = RegExp(r'^\d{11}$');

  /// Password policy regex
  /// - At least 8 characters
  /// - At least one uppercase letter
  /// - At least one lowercase letter
  /// - At least one number
  /// - At least one special character
  static final RegExp _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
  );

  /// Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validate phone number (Australian)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove spaces and dashes
    final cleanedValue = value.replaceAll(RegExp(r'[\s-]'), '');

    if (!_auPhoneRegex.hasMatch(cleanedValue)) {
      return 'Please enter a valid Australian phone number (+61XXXXXXXXX)';
    }
    return null;
  }

  /// Validate international phone number
  static String? validateInternationalPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final cleanedValue = value.replaceAll(RegExp(r'[\s-]'), '');

    if (!_phoneRegex.hasMatch(cleanedValue)) {
      return 'Please enter a valid phone number in E.164 format';
    }
    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < AppConfig.minPasswordLength) {
      return 'Password must be at least ${AppConfig.minPasswordLength} characters';
    }
    if (!_passwordRegex.hasMatch(value)) {
      return 'Password must contain uppercase, lowercase, number, and special character';
    }
    return null;
  }

  /// Validate confirm password
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validate ABN
  static String? validateAbn(String? value) {
    if (value == null || value.isEmpty) {
      return 'ABN is required';
    }

    // Remove spaces
    final cleanedValue = value.replaceAll(' ', '');

    if (!_abnRegex.hasMatch(cleanedValue)) {
      return 'ABN must be 11 digits';
    }
    return null;
  }

  /// Validate OTP
  static String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }
    if (value.length != AppConfig.otpLength) {
      return 'OTP must be ${AppConfig.otpLength} digits';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'OTP must contain only numbers';
    }
    return null;
  }

  /// Validate required field
  static String? validateRequired(
    String? value, [
    String fieldName = 'This field',
  ]) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate name
  static String? validateName(String? value, [String fieldName = 'Name']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (value.trim().length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    return null;
  }

  /// Format phone number for display
  static String formatPhoneForDisplay(String phone) {
    // Input: +61412345678
    // Output: +61 412 345 678
    if (phone.startsWith('+61') && phone.length == 12) {
      return '${phone.substring(0, 3)} ${phone.substring(3, 6)} ${phone.substring(6, 9)} ${phone.substring(9)}';
    }
    return phone;
  }

  /// Format ABN for display
  static String formatAbnForDisplay(String abn) {
    // Input: 12345678901
    // Output: 12 345 678 901
    final cleaned = abn.replaceAll(' ', '');
    if (cleaned.length == 11) {
      return '${cleaned.substring(0, 2)} ${cleaned.substring(2, 5)} ${cleaned.substring(5, 8)} ${cleaned.substring(8)}';
    }
    return abn;
  }

  /// Clean phone number (remove formatting)
  static String cleanPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[\s-()]'), '');
  }

  /// Clean ABN (remove formatting)
  static String cleanAbn(String abn) {
    return abn.replaceAll(' ', '');
  }
}
