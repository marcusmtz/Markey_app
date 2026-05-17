import 'dart:async';
import 'package:flutter/widgets.dart';
import 'auto_lock_service.dart';

/// Implementation of AutoLockService that monitors app lifecycle and user activity
/// Uses WidgetsBindingObserver to detect when app goes to background
class AutoLockServiceImpl extends AutoLockService with WidgetsBindingObserver {
  Timer? _inactivityTimer;
  Duration _lockDuration = const Duration(minutes: 2); // Default: 2 minutes
  final StreamController<bool> _lockStateController =
      StreamController<bool>.broadcast();
  bool _isMonitoring = false;

  @override
  Stream<bool> get lockStateStream => _lockStateController.stream;

  @override
  Duration get currentLockDuration => _lockDuration;

  @override
  void startMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    WidgetsBinding.instance.addObserver(this);
    _startInactivityTimer();
  }

  @override
  void stopMonitoring() {
    if (!_isMonitoring) return;

    _isMonitoring = false;
    WidgetsBinding.instance.removeObserver(this);
    _cancelInactivityTimer();
  }

  @override
  void resetTimer() {
    if (!_isMonitoring) return;

    _cancelInactivityTimer();
    _startInactivityTimer();
  }

  @override
  void setLockDuration(Duration duration) {
    _lockDuration = duration;

    // If monitoring is active, restart timer with new duration
    if (_isMonitoring) {
      resetTimer();
    }
  }

  @override
  void dispose() {
    stopMonitoring();
    _lockStateController.close();
  }

  /// Handles app lifecycle state changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        // App came back to foreground - reset timer
        resetTimer();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // App went to background - count as inactivity
        // Timer continues running
        break;
    }
  }

  /// Starts the inactivity timer
  void _startInactivityTimer() {
    _inactivityTimer = Timer(_lockDuration, () {
      _triggerLock();
    });
  }

  /// Cancels the inactivity timer
  void _cancelInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }

  /// Triggers the lock event
  void _triggerLock() {
    if (!_lockStateController.isClosed) {
      _lockStateController.add(true);
    }
    _cancelInactivityTimer();
  }
}
