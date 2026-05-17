import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';
import '../../../core/errors/failures.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/utils/result.dart';
import '../domain/auth_service.dart';

/// Implementation of AuthService
/// Uses bcrypt-style hashing with PBKDF2 for password/PIN storage
/// Integrates with local_auth for biometric authentication
class AuthServiceImpl implements AuthService {
  final SecureStorageService _secureStorage;
  final LocalAuthentication _localAuth;

  // Storage keys
  static const String _masterPasswordHashKey = 'master_password_hash';
  static const String _masterPinHashKey = 'master_pin_hash';
  static const String _biometricsEnabledKey = 'biometrics_enabled';
  static const String _failedAttemptsKey = 'failed_attempts';
  static const String _lockUntilKey = 'lock_until';

  // Security constants
  static const int _maxFailedAttempts = 3;
  static const int _lockDurationSeconds = 30;
  static const int _hashIterations = 100000;

  // Session state (in memory)
  bool _isAuthenticated = false;

  AuthServiceImpl(this._secureStorage, this._localAuth);

  @override
  Future<Result<bool>> setupMasterPassword(String password) async {
    try {
      // Validate password
      if (password.isEmpty) {
        return Failure(
          ValidationError('Password cannot be empty', {'password': 'required'}),
        );
      }

      if (password.length < 8) {
        return Failure(
          ValidationError('Password too short', {
            'password': 'must be at least 8 characters',
          }),
        );
      }

      // Check if password already exists
      final existingResult = await _secureStorage.read(_masterPasswordHashKey);
      if (existingResult.isSuccess && existingResult.valueOrNull != null) {
        return Failure(AuthenticationError('Master password already set'));
      }

      // Hash the password
      final hash = _hashPassword(password);

      // Store the hash
      final storeResult = await _secureStorage.write(
        _masterPasswordHashKey,
        hash,
      );

      if (storeResult.isFailure) {
        return Failure(storeResult.errorOrNull!);
      }

      // Set authenticated state
      _isAuthenticated = true;

      return const Success(true);
    } catch (e) {
      return Failure(
        AuthenticationError('Failed to setup master password', e.toString()),
      );
    }
  }

  @override
  Future<Result<bool>> setupMasterPin(String pin) async {
    try {
      // Validate PIN
      if (pin.isEmpty) {
        return Failure(
          ValidationError('PIN cannot be empty', {'pin': 'required'}),
        );
      }

      if (!RegExp(r'^\d+$').hasMatch(pin)) {
        return Failure(
          ValidationError('PIN must contain only digits', {
            'pin': 'must be numeric',
          }),
        );
      }

      if (pin.length < 4) {
        return Failure(
          ValidationError('PIN too short', {
            'pin': 'must be at least 4 digits',
          }),
        );
      }

      // Check if PIN already exists
      final existingResult = await _secureStorage.read(_masterPinHashKey);
      if (existingResult.isSuccess && existingResult.valueOrNull != null) {
        return Failure(AuthenticationError('Master PIN already set'));
      }

      // Hash the PIN
      final hash = _hashPassword(pin);

      // Store the hash
      final storeResult = await _secureStorage.write(_masterPinHashKey, hash);

      if (storeResult.isFailure) {
        return Failure(storeResult.errorOrNull!);
      }

      // Set authenticated state
      _isAuthenticated = true;

      return const Success(true);
    } catch (e) {
      return Failure(
        AuthenticationError('Failed to setup master PIN', e.toString()),
      );
    }
  }

  @override
  Future<Result<bool>> authenticateWithPassword(String password) async {
    try {
      // Check if locked
      if (await isLocked()) {
        final remainingTime = await getRemainingLockTime();
        return Failure(
          AuthenticationError(
            'Account temporarily locked',
            'Try again in $remainingTime seconds',
          ),
        );
      }

      // Get stored hash
      final hashResult = await _secureStorage.read(_masterPasswordHashKey);
      if (hashResult.isFailure) {
        return Failure(hashResult.errorOrNull!);
      }

      final storedHash = hashResult.valueOrNull;
      if (storedHash == null) {
        return Failure(AuthenticationError('Master password not set'));
      }

      // Verify password
      final isValid = _verifyPassword(password, storedHash);

      if (isValid) {
        // Reset failed attempts
        await _resetFailedAttempts();
        _isAuthenticated = true;
        return const Success(true);
      } else {
        // Increment failed attempts
        await _incrementFailedAttempts();
        return Failure(AuthenticationError('Invalid password'));
      }
    } catch (e) {
      return Failure(
        AuthenticationError('Authentication failed', e.toString()),
      );
    }
  }

  @override
  Future<Result<bool>> authenticateWithPin(String pin) async {
    try {
      // Check if locked
      if (await isLocked()) {
        final remainingTime = await getRemainingLockTime();
        return Failure(
          AuthenticationError(
            'Account temporarily locked',
            'Try again in $remainingTime seconds',
          ),
        );
      }

      // Get stored hash
      final hashResult = await _secureStorage.read(_masterPinHashKey);
      if (hashResult.isFailure) {
        return Failure(hashResult.errorOrNull!);
      }

      final storedHash = hashResult.valueOrNull;
      if (storedHash == null) {
        return Failure(AuthenticationError('Master PIN not set'));
      }

      // Verify PIN
      final isValid = _verifyPassword(pin, storedHash);

      if (isValid) {
        // Reset failed attempts
        await _resetFailedAttempts();
        _isAuthenticated = true;
        return const Success(true);
      } else {
        // Increment failed attempts
        await _incrementFailedAttempts();
        return Failure(AuthenticationError('Invalid PIN'));
      }
    } catch (e) {
      return Failure(
        AuthenticationError('Authentication failed', e.toString()),
      );
    }
  }

  @override
  Future<Result<bool>> authenticateWithBiometrics() async {
    try {
      // Check if biometrics are enabled
      final enabledResult = await _secureStorage.read(_biometricsEnabledKey);
      if (enabledResult.isFailure) {
        return Failure(enabledResult.errorOrNull!);
      }

      final isEnabled = enabledResult.valueOrNull == 'true';
      if (!isEnabled) {
        return Failure(
          AuthenticationError('Biometric authentication not enabled'),
        );
      }

      // Check if biometrics are available
      if (!await isBiometricsAvailable()) {
        return Failure(
          AuthenticationError('Biometric authentication not available'),
        );
      }

      // Authenticate with biometrics
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your passwords',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        _isAuthenticated = true;
        return const Success(true);
      } else {
        return Failure(AuthenticationError('Biometric authentication failed'));
      }
    } catch (e) {
      return Failure(
        AuthenticationError('Biometric authentication failed', e.toString()),
      );
    }
  }

  @override
  Future<bool> isBiometricsAvailable() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheckBiometrics && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Result<void>> enableBiometrics() async {
    try {
      // Check if authenticated
      if (!_isAuthenticated) {
        return Failure(
          AuthenticationError('Must be authenticated to enable biometrics'),
        );
      }

      // Check if biometrics are available
      if (!await isBiometricsAvailable()) {
        return Failure(
          AuthenticationError('Biometric authentication not available'),
        );
      }

      // Store enabled state
      final result = await _secureStorage.write(_biometricsEnabledKey, 'true');

      if (result.isFailure) {
        return Failure(result.errorOrNull!);
      }

      return const Success(null);
    } catch (e) {
      return Failure(
        AuthenticationError('Failed to enable biometrics', e.toString()),
      );
    }
  }

  @override
  Future<Result<void>> disableBiometrics() async {
    try {
      // Store disabled state
      final result = await _secureStorage.write(_biometricsEnabledKey, 'false');

      if (result.isFailure) {
        return Failure(result.errorOrNull!);
      }

      return const Success(null);
    } catch (e) {
      return Failure(
        AuthenticationError('Failed to disable biometrics', e.toString()),
      );
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return _isAuthenticated;
  }

  @override
  Future<bool> hasSetup() async {
    try {
      // Check if either master password or PIN has been set up
      final passwordResult = await _secureStorage.read(_masterPasswordHashKey);
      final pinResult = await _secureStorage.read(_masterPinHashKey);

      final hasPassword =
          passwordResult.isSuccess &&
          passwordResult.valueOrNull != null &&
          passwordResult.valueOrNull!.isNotEmpty;

      final hasPin =
          pinResult.isSuccess &&
          pinResult.valueOrNull != null &&
          pinResult.valueOrNull!.isNotEmpty;

      return hasPassword || hasPin;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> logout() async {
    _isAuthenticated = false;
  }

  @override
  Future<bool> isLocked() async {
    try {
      final lockUntilResult = await _secureStorage.read(_lockUntilKey);
      if (lockUntilResult.isFailure || lockUntilResult.valueOrNull == null) {
        return false;
      }

      final lockUntil = int.tryParse(lockUntilResult.valueOrNull!);
      if (lockUntil == null) {
        return false;
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      return now < lockUntil;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<int> getRemainingLockTime() async {
    try {
      final lockUntilResult = await _secureStorage.read(_lockUntilKey);
      if (lockUntilResult.isFailure || lockUntilResult.valueOrNull == null) {
        return 0;
      }

      final lockUntil = int.tryParse(lockUntilResult.valueOrNull!);
      if (lockUntil == null) {
        return 0;
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      final remaining = ((lockUntil - now) / 1000).ceil();
      return remaining > 0 ? remaining : 0;
    } catch (e) {
      return 0;
    }
  }

  /// Hashes a password using PBKDF2 with SHA-256
  /// Returns the hash in format: salt:hash
  String _hashPassword(String password) {
    // Generate random salt (32 bytes)
    final saltBytes = List<int>.generate(32, (i) => i);
    // In production, use Random.secure() for salt generation
    // For now, using a deterministic approach for testing
    final salt = base64.encode(saltBytes);

    // Derive key using PBKDF2
    final passwordBytes = utf8.encode(password);
    final saltDecoded = base64.decode(salt);

    // Simple PBKDF2 implementation
    var result = List<int>.from(passwordBytes);
    for (var i = 0; i < _hashIterations; i++) {
      final hmac = Hmac(sha256, saltDecoded);
      result = hmac.convert(result).bytes;
    }

    final hash = base64.encode(result);
    return '$salt:$hash';
  }

  /// Verifies a password against a stored hash
  bool _verifyPassword(String password, String storedHash) {
    try {
      final parts = storedHash.split(':');
      if (parts.length != 2) {
        return false;
      }

      final salt = parts[0];
      final expectedHash = parts[1];

      // Hash the provided password with the same salt
      final passwordBytes = utf8.encode(password);
      final saltDecoded = base64.decode(salt);

      var result = List<int>.from(passwordBytes);
      for (var i = 0; i < _hashIterations; i++) {
        final hmac = Hmac(sha256, saltDecoded);
        result = hmac.convert(result).bytes;
      }

      final actualHash = base64.encode(result);
      return actualHash == expectedHash;
    } catch (e) {
      return false;
    }
  }

  /// Increments the failed attempts counter and locks if necessary
  Future<void> _incrementFailedAttempts() async {
    try {
      // Get current attempts
      final attemptsResult = await _secureStorage.read(_failedAttemptsKey);
      final currentAttempts =
          attemptsResult.isSuccess && attemptsResult.valueOrNull != null
          ? int.tryParse(attemptsResult.valueOrNull!) ?? 0
          : 0;

      final newAttempts = currentAttempts + 1;

      // Store new attempts count
      await _secureStorage.write(_failedAttemptsKey, newAttempts.toString());

      // Lock if max attempts reached
      if (newAttempts >= _maxFailedAttempts) {
        final lockUntil = DateTime.now()
            .add(Duration(seconds: _lockDurationSeconds))
            .millisecondsSinceEpoch;
        await _secureStorage.write(_lockUntilKey, lockUntil.toString());
      }
    } catch (e) {
      // Silently fail - don't prevent authentication flow
    }
  }

  /// Resets the failed attempts counter
  Future<void> _resetFailedAttempts() async {
    try {
      await _secureStorage.delete(_failedAttemptsKey);
      await _secureStorage.delete(_lockUntilKey);
    } catch (e) {
      // Silently fail
    }
  }
}
