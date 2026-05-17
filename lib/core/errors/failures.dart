/// Base class for all application errors
abstract class AppError {
  final String message;
  final String? details;

  AppError(this.message, [this.details]);

  @override
  String toString() => details != null ? '$message: $details' : message;
}

/// Authentication related errors
class AuthenticationError extends AppError {
  AuthenticationError(super.message, [super.details]);
}

/// Storage related errors
class StorageError extends AppError {
  StorageError(super.message, [super.details]);
}

/// Encryption/Decryption errors
class EncryptionError extends AppError {
  EncryptionError(super.message, [super.details]);
}

/// Validation errors with field-specific messages
class ValidationError extends AppError {
  final Map<String, String> fieldErrors;

  ValidationError(super.message, this.fieldErrors);

  @override
  String toString() =>
      '$message: ${fieldErrors.entries.map((e) => '${e.key}: ${e.value}').join(', ')}';
}

/// Network related errors
class NetworkError extends AppError {
  NetworkError(super.message, [super.details]);
}

/// Backup and restore related errors
class BackupError extends AppError {
  BackupError(super.message, [super.details]);
}
