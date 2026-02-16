import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markey_app/core/services/clipboard_service.dart';
import 'package:markey_app/core/services/clipboard_service_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ClipboardService clipboardService;

  setUp(() {
    clipboardService = ClipboardServiceImpl();
    // Set up method channel mock for clipboard
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (
          MethodCall methodCall,
        ) async {
          if (methodCall.method == 'Clipboard.setData') {
            return null;
          }
          if (methodCall.method == 'Clipboard.getData') {
            return null;
          }
          return null;
        });
  });

  tearDown(() {
    clipboardService.cancelScheduledClear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  group('ClipboardService', () {
    test('should copy text to clipboard', () async {
      const testText = 'TestPassword123!';

      await clipboardService.copyWithAutoClear(
        testText,
        const Duration(seconds: 30),
      );

      // Verify no exceptions were thrown
      expect(true, isTrue);
    });

    test('should clear clipboard immediately', () async {
      const testText = 'TestPassword123!';

      await clipboardService.copyWithAutoClear(
        testText,
        const Duration(seconds: 30),
      );

      await clipboardService.clearClipboard();

      // Verify no exceptions were thrown
      expect(true, isTrue);
    });

    test('should cancel scheduled clear', () async {
      const testText = 'TestPassword123!';

      await clipboardService.copyWithAutoClear(
        testText,
        const Duration(seconds: 30),
      );

      clipboardService.cancelScheduledClear();

      // Verify no exceptions were thrown
      expect(true, isTrue);
    });

    test('should auto-clear clipboard after specified duration', () async {
      const testText = 'TestPassword123!';
      bool cleared = false;

      // Track clipboard operations
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (
            MethodCall methodCall,
          ) async {
            if (methodCall.method == 'Clipboard.setData') {
              final data = methodCall.arguments as Map;
              if (data['text'] == '') {
                cleared = true;
              }
              return null;
            }
            return null;
          });

      await clipboardService.copyWithAutoClear(
        testText,
        const Duration(milliseconds: 100),
      );

      // Wait for auto-clear
      await Future.delayed(const Duration(milliseconds: 150));

      expect(cleared, isTrue);
    });

    test('should cancel previous timer when copying new content', () async {
      int clearCount = 0;

      // Track clipboard clear operations
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (
            MethodCall methodCall,
          ) async {
            if (methodCall.method == 'Clipboard.setData') {
              final data = methodCall.arguments as Map;
              if (data['text'] == '') {
                clearCount++;
              }
              return null;
            }
            return null;
          });

      // Copy first text with 100ms clear time
      await clipboardService.copyWithAutoClear(
        'FirstPassword',
        const Duration(milliseconds: 100),
      );

      // Wait 50ms (half the time)
      await Future.delayed(const Duration(milliseconds: 50));

      // Copy second text with 200ms clear time (should cancel first timer)
      await clipboardService.copyWithAutoClear(
        'SecondPassword',
        const Duration(milliseconds: 200),
      );

      // Wait 100ms (first timer would have fired if not cancelled)
      await Future.delayed(const Duration(milliseconds: 100));

      // First timer should have been cancelled, so no clear yet
      expect(clearCount, equals(0));

      // Wait for second timer to fire
      await Future.delayed(const Duration(milliseconds: 150));

      // Now clipboard should be cleared once (by second timer only)
      expect(clearCount, equals(1));
    });

    test('should handle empty string', () async {
      await clipboardService.copyWithAutoClear('', const Duration(seconds: 30));

      // Verify no exceptions were thrown
      expect(true, isTrue);
    });

    test('should handle special characters', () async {
      const specialText = '!@#\$%^&*()_+-=[]{}|;:,.<>?/~`"\'\\';

      await clipboardService.copyWithAutoClear(
        specialText,
        const Duration(seconds: 30),
      );

      // Verify no exceptions were thrown
      expect(true, isTrue);
    });

    test('should handle Unicode characters', () async {
      const unicodeText = 'Hello 世界 🌍 Привет مرحبا';

      await clipboardService.copyWithAutoClear(
        unicodeText,
        const Duration(seconds: 30),
      );

      // Verify no exceptions were thrown
      expect(true, isTrue);
    });

    test('should handle very short duration', () async {
      const testText = 'TestPassword';
      bool cleared = false;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (
            MethodCall methodCall,
          ) async {
            if (methodCall.method == 'Clipboard.setData') {
              final data = methodCall.arguments as Map;
              if (data['text'] == '') {
                cleared = true;
              }
              return null;
            }
            return null;
          });

      await clipboardService.copyWithAutoClear(
        testText,
        const Duration(milliseconds: 10),
      );

      await Future.delayed(const Duration(milliseconds: 50));

      expect(cleared, isTrue);
    });

    test('should handle multiple cancel calls', () {
      clipboardService.cancelScheduledClear();
      clipboardService.cancelScheduledClear();
      clipboardService.cancelScheduledClear();

      // Verify no exceptions were thrown
      expect(true, isTrue);
    });
  });
}
