import '../../features/notes/domain/secure_note.dart';
import '../../features/vault/domain/entry.dart';

/// Centralized route names for the application
class RouteNames {
  // Auth routes
  static const String onboarding = '/onboarding';
  static const String login = '/login';

  // Main routes
  static const String vault = '/vault';
  static const String entryDetail = '/entry-detail';
  static const String passwordGenerator = '/password-generator';
  static const String securityAnalysis = '/security-analysis';
  static const String notesList = '/notes';
  static const String noteEditor = '/note-editor';
  static const String settings = '/settings';
  static const String categories = '/categories';
}

/// Arguments for entry detail screen
class EntryDetailArguments {
  final Entry? entry;
  final String? heroTag;

  EntryDetailArguments({this.entry, this.heroTag});
}

/// Arguments for note editor screen
class NoteEditorArguments {
  final SecureNote? note;

  NoteEditorArguments({this.note});
}
