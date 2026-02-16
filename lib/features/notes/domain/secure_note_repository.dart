import 'dart:typed_data';
import '../../../core/utils/result.dart';
import 'secure_note.dart';

/// Abstract repository interface for secure notes operations
/// Defines CRUD operations for secure notes with encryption
abstract class SecureNoteRepository {
  /// Creates a new secure note
  /// Content is encrypted before storage
  Future<Result<SecureNote>> createNote(SecureNote note);

  /// Updates an existing secure note
  /// Content is encrypted before storage
  Future<Result<SecureNote>> updateNote(SecureNote note);

  /// Deletes a secure note by ID
  Future<Result<void>> deleteNote(String id);

  /// Retrieves all secure notes
  Future<Result<List<SecureNote>>> getAllNotes();

  /// Retrieves a specific note by ID
  /// Returns null if note not found
  Future<Result<SecureNote?>> getNoteById(String id);

  /// Searches notes by query string
  /// Searches in title and content fields
  Future<Result<List<SecureNote>>> searchNotes(String query);

  /// Attaches a file to a note
  /// Validates file size (max 5MB)
  /// File data is encrypted before storage
  Future<Result<AttachedFile>> attachFile({
    required String noteId,
    required String fileName,
    required Uint8List fileData,
  });

  /// Retrieves an attached file's data
  /// Returns decrypted file data
  Future<Result<Uint8List>> getAttachedFileData(String noteId, String fileId);

  /// Removes an attached file from a note
  Future<Result<void>> removeAttachedFile(String noteId, String fileId);
}
