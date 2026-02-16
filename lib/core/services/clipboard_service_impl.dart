import 'dart:async';
import 'package:flutter/services.dart';
import 'clipboard_service.dart';

/// Implementation of ClipboardService that manages clipboard operations
/// with automatic clearing functionality
class ClipboardServiceImpl implements ClipboardService {
  Timer? _clearTimer;
  String? _copiedText;

  @override
  Future<void> copyWithAutoClear(String text, Duration clearAfter) async {
    // Cancel any previously scheduled clear operation
    cancelScheduledClear();

    // Copy text to clipboard
    await Clipboard.setData(ClipboardData(text: text));
    _copiedText = text;

    // Schedule automatic clearing
    _clearTimer = Timer(clearAfter, () async {
      await _clearIfUnchanged();
    });
  }

  @override
  Future<void> clearClipboard() async {
    await Clipboard.setData(const ClipboardData(text: ''));
    _copiedText = null;
  }

  @override
  void cancelScheduledClear() {
    _clearTimer?.cancel();
    _clearTimer = null;
  }

  /// Clears clipboard only if the content hasn't changed
  Future<void> _clearIfUnchanged() async {
    if (_copiedText == null) return;

    try {
      // Check current clipboard content
      final currentData = await Clipboard.getData(Clipboard.kTextPlain);
      final currentText = currentData?.text;

      // Only clear if the clipboard still contains what we copied
      if (currentText == _copiedText) {
        await clearClipboard();
      } else {
        // User copied something else, don't clear
        _copiedText = null;
      }
    } catch (e) {
      // If we can't read clipboard, don't clear it to be safe
      _copiedText = null;
    }
  }
}
