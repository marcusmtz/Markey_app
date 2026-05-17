/// Application-wide constants
class AppConstants {
  // Encryption
  static const int pbkdf2Iterations = 100000;
  static const int aesKeyLength = 256;

  // Auto-lock
  static const Duration defaultAutoLockDuration = Duration(minutes: 2);
  static const Duration minAutoLockDuration = Duration(seconds: 30);
  static const Duration maxAutoLockDuration = Duration(minutes: 30);

  // Clipboard
  static const Duration defaultClipboardClearDuration = Duration(seconds: 30);
  static const Duration minClipboardClearDuration = Duration(seconds: 15);
  static const Duration maxClipboardClearDuration = Duration(seconds: 120);

  // Authentication
  static const int maxAuthAttempts = 3;
  static const Duration lockoutDuration = Duration(seconds: 30);

  // Password Generator
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 64;
  static const int defaultPasswordLength = 16;

  // Password History
  static const int maxPasswordHistorySize = 10;

  // File Attachments
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB

  // TOTP
  static const int totpDigits = 6;
  static const int totpPeriod = 30;
  static const int totpExpiryWarning = 5; // seconds

  // Backup
  static const String backupVersion = '1.0';
}
