/// Application configuration
class AppConfig {
  AppConfig._();

  // API Configuration
  static const String apiBaseUrl = 'http://16.51.170.185:8080/api';
  static const int apiTimeout = 30000; // 30 seconds

  // App Information
  static const String appName = 'Servix';
  static const String appVersion = '1.0.0';

  // OTP Configuration
  static const int otpLength = 6;
  static const int otpResendTimeout = 60; // seconds

  // ABN Configuration
  static const int abnLength = 11;

  // Password Policy
  static const int minPasswordLength = 8;

  // Phone Number (Australian)
  static const String phonePrefix = '+61';
}
