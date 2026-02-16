import '../../../core/utils/result.dart';

/// Abstract interface for authentication operations
/// Manages master password, PIN, and biometric authentication
abstract class AuthService {
  /// Sets up the master password for the first time
  /// [password] - The master password to set
  /// Returns Success(true) if setup is successful
  Future<Result<bool>> setupMasterPassword(String password);

  /// Sets up the master PIN for the first time
  /// [pin] - The master PIN to set (numeric string)
  /// Returns Success(true) if setup is successful
  Future<Result<bool>> setupMasterPin(String pin);

  /// Authenticates user with master password
  /// [password] - The password to verify
  /// Returns Success(true) if authentication is successful
  /// Increments failed attempt counter on failure
  Future<Result<bool>> authenticateWithPassword(String password);

  /// Authenticates user with master PIN
  /// [pin] - The PIN to verify
  /// Returns Success(true) if authentication is successful
  /// Increments failed attempt counter on failure
  Future<Result<bool>> authenticateWithPin(String pin);

  /// Authenticates user with biometric authentication
  /// Returns Success(true) if authentication is successful
  Future<Result<bool>> authenticateWithBiometrics();

  /// Checks if biometric authentication is available on the device
  /// Returns true if biometrics are available and can be used
  Future<bool> isBiometricsAvailable();

  /// Enables biometric authentication for the user
  /// Requires prior authentication with password or PIN
  Future<Result<void>> enableBiometrics();

  /// Disables biometric authentication for the user
  Future<Result<void>> disableBiometrics();

  /// Checks if the user is currently authenticated
  /// Returns true if there's an active session
  Future<bool> isAuthenticated();

  /// Checks if master password or PIN has been set up
  /// Returns true if the user has completed initial setup
  Future<bool> hasSetup();

  /// Logs out the user and clears the session
  Future<void> logout();

  /// Checks if the account is temporarily locked due to failed attempts
  /// Returns true if locked, false otherwise
  Future<bool> isLocked();

  /// Gets the remaining lock time in seconds
  /// Returns 0 if not locked
  Future<int> getRemainingLockTime();
}
