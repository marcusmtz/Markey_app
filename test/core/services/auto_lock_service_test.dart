import 'package:flutter_test/flutter_test.dart';
import 'package:markey_app/core/services/auto_lock_service.dart';
import 'package:markey_app/core/services/auto_lock_service_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AutoLockService autoLockService;

  setUp(() {
    autoLockService = AutoLockServiceImpl();
  });

  tearDown(() {
    autoLockService.dispose();
  });

  group('AutoLockService', () {
    test('should have default lock duration of 2 minutes', () {
      expect(
        autoLockService.currentLockDuration,
        equals(const Duration(minutes: 2)),
      );
    });

    test('should start monitoring without errors', () {
      autoLockService.startMonitoring();

      // Verify no exceptions were thrown
      expect(true, isTrue);
    });

    test('should stop monitoring without errors', () {
      autoLockService.startMonitoring();
      autoLockService.stopMonitoring();

      // Verify no exceptions were thrown
      expect(true, isTrue);
    });

    test('should allow multiple start calls without errors', () {
      autoLockService.startMonitoring();
      autoLockService.startMonitoring();
      autoLockService.startMonitoring();

      // Verify no exceptions were thrown
      expect(true, isTrue);
    });

    test('should allow multiple stop calls without errors', () {
      autoLockService.startMonitoring();
      autoLockService.stopMonitoring();
      autoLockService.stopMonitoring();

      // Verify no exceptions were thrown
      expect(true, isTrue);
    });

    test('should reset timer without errors', () {
      autoLockService.startMonitoring();
      autoLockService.resetTimer();

      // Verify no exceptions were thrown
      expect(true, isTrue);
    });

    test('should set lock duration', () {
      const newDuration = Duration(minutes: 5);
      autoLockService.setLockDuration(newDuration);

      expect(autoLockService.currentLockDuration, equals(newDuration));
    });

    test('should emit lock event after configured duration', () async {
      const testDuration = Duration(milliseconds: 100);
      autoLockService.setLockDuration(testDuration);

      bool lockEventReceived = false;
      autoLockService.lockStateStream.listen((isLocked) {
        if (isLocked) {
          lockEventReceived = true;
        }
      });

      autoLockService.startMonitoring();

      // Wait for lock event
      await Future.delayed(const Duration(milliseconds: 150));

      expect(lockEventReceived, isTrue);
    });

    test('should not emit lock event before duration expires', () async {
      const testDuration = Duration(milliseconds: 200);
      autoLockService.setLockDuration(testDuration);

      bool lockEventReceived = false;
      autoLockService.lockStateStream.listen((isLocked) {
        if (isLocked) {
          lockEventReceived = true;
        }
      });

      autoLockService.startMonitoring();

      // Wait less than lock duration
      await Future.delayed(const Duration(milliseconds: 100));

      expect(lockEventReceived, isFalse);
    });

    test('should reset timer on resetTimer call', () async {
      const testDuration = Duration(milliseconds: 150);
      autoLockService.setLockDuration(testDuration);

      bool lockEventReceived = false;
      autoLockService.lockStateStream.listen((isLocked) {
        if (isLocked) {
          lockEventReceived = true;
        }
      });

      autoLockService.startMonitoring();

      // Wait 100ms (2/3 of duration)
      await Future.delayed(const Duration(milliseconds: 100));

      // Reset timer
      autoLockService.resetTimer();

      // Wait another 100ms (would have locked if timer wasn't reset)
      await Future.delayed(const Duration(milliseconds: 100));

      // Should not be locked yet
      expect(lockEventReceived, isFalse);

      // Wait for remaining time
      await Future.delayed(const Duration(milliseconds: 100));

      // Now should be locked
      expect(lockEventReceived, isTrue);
    });

    test('should not emit events when monitoring is stopped', () async {
      const testDuration = Duration(milliseconds: 100);
      autoLockService.setLockDuration(testDuration);

      bool lockEventReceived = false;
      autoLockService.lockStateStream.listen((isLocked) {
        if (isLocked) {
          lockEventReceived = true;
        }
      });

      autoLockService.startMonitoring();
      autoLockService.stopMonitoring();

      // Wait for what would have been lock time
      await Future.delayed(const Duration(milliseconds: 150));

      expect(lockEventReceived, isFalse);
    });

    test('should handle very short lock duration', () async {
      const testDuration = Duration(milliseconds: 10);
      autoLockService.setLockDuration(testDuration);

      bool lockEventReceived = false;
      autoLockService.lockStateStream.listen((isLocked) {
        if (isLocked) {
          lockEventReceived = true;
        }
      });

      autoLockService.startMonitoring();

      await Future.delayed(const Duration(milliseconds: 50));

      expect(lockEventReceived, isTrue);
    });

    test('should handle long lock duration', () async {
      const testDuration = Duration(minutes: 30);
      autoLockService.setLockDuration(testDuration);

      bool lockEventReceived = false;
      autoLockService.lockStateStream.listen((isLocked) {
        if (isLocked) {
          lockEventReceived = true;
        }
      });

      autoLockService.startMonitoring();

      // Wait a short time
      await Future.delayed(const Duration(milliseconds: 100));

      // Should not be locked yet
      expect(lockEventReceived, isFalse);
    });

    test('should update duration while monitoring', () async {
      const initialDuration = Duration(milliseconds: 200);
      const newDuration = Duration(milliseconds: 100);

      autoLockService.setLockDuration(initialDuration);
      autoLockService.startMonitoring();

      // Wait 50ms
      await Future.delayed(const Duration(milliseconds: 50));

      // Change duration (should restart timer)
      autoLockService.setLockDuration(newDuration);

      bool lockEventReceived = false;
      autoLockService.lockStateStream.listen((isLocked) {
        if (isLocked) {
          lockEventReceived = true;
        }
      });

      // Wait for new duration
      await Future.delayed(const Duration(milliseconds: 120));

      expect(lockEventReceived, isTrue);
    });

    test('should dispose without errors', () {
      autoLockService.startMonitoring();
      autoLockService.dispose();

      // Verify no exceptions were thrown
      expect(true, isTrue);
    });

    test('should handle dispose when not monitoring', () {
      autoLockService.dispose();

      // Verify no exceptions were thrown
      expect(true, isTrue);
    });

    test('should handle multiple dispose calls', () {
      autoLockService.startMonitoring();
      autoLockService.dispose();
      autoLockService.dispose();

      // Verify no exceptions were thrown
      expect(true, isTrue);
    });

    test('should not crash when resetTimer called without monitoring', () {
      autoLockService.resetTimer();

      // Verify no exceptions were thrown
      expect(true, isTrue);
    });

    test('should support multiple listeners on lock state stream', () async {
      const testDuration = Duration(milliseconds: 100);
      autoLockService.setLockDuration(testDuration);

      int listener1Count = 0;
      int listener2Count = 0;

      autoLockService.lockStateStream.listen((isLocked) {
        if (isLocked) listener1Count++;
      });

      autoLockService.lockStateStream.listen((isLocked) {
        if (isLocked) listener2Count++;
      });

      autoLockService.startMonitoring();

      await Future.delayed(const Duration(milliseconds: 150));

      expect(listener1Count, equals(1));
      expect(listener2Count, equals(1));
    });
  });
}
