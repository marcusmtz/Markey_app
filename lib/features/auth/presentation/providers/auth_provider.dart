import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/auto_lock_service.dart';
import '../../../../core/utils/result.dart';
import '../../domain/auth_service.dart';

/// Provider for authentication state management
/// Integrates with AutoLockService for reactive lock notifications
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final AutoLockService? _autoLockService;
  StreamSubscription<bool>? _lockStateSubscription;

  bool _isAuthenticated = false;
  bool _isLoading = false;
  bool _isLocked = false;
  int _remainingLockTime = 0;

  AuthProvider(this._authService, {AutoLockService? autoLockService})
    : _autoLockService = autoLockService {
    _initializeAutoLock();
  }

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get isLocked => _isLocked;
  int get remainingLockTime => _remainingLockTime;

  /// Setup master password
  Future<Result<bool>> setupMasterPassword(String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.setupMasterPassword(password);

      if (result.isSuccess) {
        _isAuthenticated = true;
        _autoLockService?.startMonitoring();
      }

      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Setup master PIN
  Future<Result<bool>> setupMasterPin(String pin) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.setupMasterPin(pin);

      if (result.isSuccess) {
        _isAuthenticated = true;
        _autoLockService?.startMonitoring();
      }

      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Authenticate with password
  Future<Result<bool>> authenticateWithPassword(String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if locked
      await _checkLockStatus();
      if (_isLocked) {
        return Failure(
          AuthenticationError(
            'Account temporarily locked',
            'Try again in $_remainingLockTime seconds',
          ),
        );
      }

      final result = await _authService.authenticateWithPassword(password);

      if (result.isSuccess) {
        _isAuthenticated = true;
        _isLocked = false;
        _remainingLockTime = 0;
        _autoLockService?.startMonitoring();
      } else {
        // Check lock status after failed attempt
        await _checkLockStatus();
      }

      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Authenticate with PIN
  Future<Result<bool>> authenticateWithPin(String pin) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if locked
      await _checkLockStatus();
      if (_isLocked) {
        return Failure(
          AuthenticationError(
            'Account temporarily locked',
            'Try again in $_remainingLockTime seconds',
          ),
        );
      }

      final result = await _authService.authenticateWithPin(pin);

      if (result.isSuccess) {
        _isAuthenticated = true;
        _isLocked = false;
        _remainingLockTime = 0;
        _autoLockService?.startMonitoring();
      } else {
        // Check lock status after failed attempt
        await _checkLockStatus();
      }

      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Authenticate with biometrics
  Future<Result<bool>> authenticateWithBiometrics() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.authenticateWithBiometrics();

      if (result.isSuccess) {
        _isAuthenticated = true;
        _autoLockService?.startMonitoring();
      }

      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check if biometrics are available
  Future<bool> isBiometricsAvailable() async {
    return await _authService.isBiometricsAvailable();
  }

  /// Logout
  Future<void> logout() async {
    await _authService.logout();
    _isAuthenticated = false;
    _autoLockService?.stopMonitoring();
    notifyListeners();
  }

  /// Check lock status
  Future<void> _checkLockStatus() async {
    _isLocked = await _authService.isLocked();
    if (_isLocked) {
      _remainingLockTime = await _authService.getRemainingLockTime();
    } else {
      _remainingLockTime = 0;
    }
  }

  /// Initialize authentication state
  Future<void> initialize() async {
    _isAuthenticated = await _authService.isAuthenticated();
    await _checkLockStatus();

    if (_isAuthenticated) {
      _autoLockService?.startMonitoring();
    }

    notifyListeners();
  }

  /// Initialize auto-lock service integration
  void _initializeAutoLock() {
    _lockStateSubscription = _autoLockService?.lockStateStream.listen((
      shouldLock,
    ) {
      if (shouldLock && _isAuthenticated) {
        _handleAutoLock();
      }
    });
  }

  /// Handle automatic lock event
  Future<void> _handleAutoLock() async {
    await logout();
    notifyListeners();
  }

  /// Reset inactivity timer (call on user interaction)
  void resetInactivityTimer() {
    if (_isAuthenticated) {
      _autoLockService?.resetTimer();
    }
  }

  @override
  void dispose() {
    _lockStateSubscription?.cancel();
    _autoLockService?.stopMonitoring();
    super.dispose();
  }
}
