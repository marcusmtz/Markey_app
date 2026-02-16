/// Abstract interface for automatic lock functionality
/// Monitors app activity and locks the app after configured inactivity period
abstract class AutoLockService {
  /// Starts monitoring app activity and inactivity
  /// Should be called when the app starts or user authenticates
  void startMonitoring();

  /// Stops monitoring app activity
  /// Should be called when the app is closed or user logs out
  void stopMonitoring();

  /// Resets the inactivity timer
  /// Should be called on any user interaction with the app
  void resetTimer();

  /// Sets the duration after which the app should auto-lock
  /// [duration] - The inactivity duration before locking
  void setLockDuration(Duration duration);

  /// Stream that emits lock state changes
  /// Emits true when the app should lock, false when unlocked
  Stream<bool> get lockStateStream;

  /// Gets the current lock duration setting
  Duration get currentLockDuration;

  /// Disposes resources and cancels timers
  void dispose();
}
