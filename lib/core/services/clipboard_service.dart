/// Abstract interface for clipboard operations with auto-clear functionality
abstract class ClipboardService {
  /// Copies text to clipboard and schedules automatic clearing after [clearAfter] duration
  ///
  /// Cancels any previously scheduled clear operation before copying new content.
  ///
  /// Parameters:
  /// - [text]: The text to copy to clipboard
  /// - [clearAfter]: Duration after which clipboard should be automatically cleared
  Future<void> copyWithAutoClear(String text, Duration clearAfter);

  /// Clears the clipboard immediately
  Future<void> clearClipboard();

  /// Cancels any scheduled clipboard clear operation
  void cancelScheduledClear();
}
