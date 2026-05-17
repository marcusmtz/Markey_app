import 'dart:convert';
import 'dart:typed_data';
import '../../../core/errors/failures.dart';
import '../../../core/services/encryption_service.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/utils/result.dart';
import '../domain/secure_note.dart';
import '../domain/secure_note_repository.dart';
import 'secure_note_model.dart';

/// Implementation of SecureNoteRepository
/// Manages encrypted storage of secure notes and attached files
class SecureNoteRepositoryImpl implements SecureNoteRepository {
  final EncryptionService _encryptionService;
  final SecureStorageService _storageService;
  final String _masterKey;

  static const String _notesKey = 'secure_notes';
  static const String _filesKeyPrefix = 'note_file_';
  static const int _maxFileSizeBytes = 5 * 1024 * 1024; // 5MB

  SecureNoteRepositoryImpl({
    required EncryptionService encryptionService,
    required SecureStorageService storageService,
    required String masterKey,
  }) : _encryptionService = encryptionService,
       _storageService = storageService,
       _masterKey = masterKey;

  @override
  Future<Result<SecureNote>> createNote(SecureNote note) async {
    // Validate required fields
    final validationError = _validateNote(note);
    if (validationError != null) {
      return Failure(validationError);
    }

    // Get all existing notes
    final allNotesResult = await getAllNotes();
    if (allNotesResult.isFailure) {
      return Failure(allNotesResult.errorOrNull!);
    }

    final notes = List<SecureNote>.from(allNotesResult.valueOrNull!);

    // Check if note with same ID already exists
    if (notes.any((n) => n.id == note.id)) {
      return Failure(
        ValidationError('Note creation failed', {
          'id': 'Note with this ID already exists',
        }),
      );
    }

    // Add new note
    notes.add(note);

    // Save all notes
    final saveResult = await _saveAllNotes(notes);
    if (saveResult.isFailure) {
      return Failure(saveResult.errorOrNull!);
    }

    return Success(note);
  }

  @override
  Future<Result<SecureNote>> updateNote(SecureNote note) async {
    // Validate required fields
    final validationError = _validateNote(note);
    if (validationError != null) {
      return Failure(validationError);
    }

    // Get all existing notes
    final allNotesResult = await getAllNotes();
    if (allNotesResult.isFailure) {
      return Failure(allNotesResult.errorOrNull!);
    }

    final notes = List<SecureNote>.from(allNotesResult.valueOrNull!);

    // Find the existing note
    final existingIndex = notes.indexWhere((n) => n.id == note.id);
    if (existingIndex == -1) {
      return Failure(
        ValidationError('Note update failed', {'id': 'Note not found'}),
      );
    }

    // Update the note
    notes[existingIndex] = note;

    // Save all notes
    final saveResult = await _saveAllNotes(notes);
    if (saveResult.isFailure) {
      return Failure(saveResult.errorOrNull!);
    }

    return Success(note);
  }

  @override
  Future<Result<void>> deleteNote(String id) async {
    // Get all existing notes
    final allNotesResult = await getAllNotes();
    if (allNotesResult.isFailure) {
      return Failure(allNotesResult.errorOrNull!);
    }

    final notes = List<SecureNote>.from(allNotesResult.valueOrNull!);

    // Find the note to get its attached files
    final noteToDelete = notes.firstWhere(
      (n) => n.id == id,
      orElse: () => throw StateError('Note not found'),
    );

    // Delete all attached files
    for (final file in noteToDelete.attachedFiles) {
      final fileKey = _getFileKey(id, file.id);
      await _storageService.delete(fileKey);
    }

    // Remove the note
    final initialLength = notes.length;
    notes.removeWhere((n) => n.id == id);

    if (notes.length == initialLength) {
      return Failure(
        ValidationError('Note deletion failed', {'id': 'Note not found'}),
      );
    }

    // Save all notes
    final saveResult = await _saveAllNotes(notes);
    if (saveResult.isFailure) {
      return Failure(saveResult.errorOrNull!);
    }

    return const Success(null);
  }

  @override
  Future<Result<List<SecureNote>>> getAllNotes() async {
    try {
      // Read encrypted notes from storage
      final readResult = await _storageService.read(_notesKey);
      if (readResult.isFailure) {
        return Failure(readResult.errorOrNull!);
      }

      final encryptedData = readResult.valueOrNull;
      if (encryptedData == null || encryptedData.isEmpty) {
        return const Success([]);
      }

      // Decrypt the notes data
      final decryptResult = await _encryptionService.decrypt(
        encryptedData,
        _masterKey,
      );
      if (decryptResult.isFailure) {
        return Failure(decryptResult.errorOrNull!);
      }

      // Parse JSON array
      final jsonData = jsonDecode(decryptResult.valueOrNull!);
      if (jsonData is! List) {
        return Failure(
          StorageError('Invalid notes data format', 'Expected JSON array'),
        );
      }

      // Convert to SecureNote objects
      final notes = <SecureNote>[];
      for (final item in jsonData) {
        if (item is! Map<String, dynamic>) continue;

        try {
          final model = SecureNoteModel.fromJson(item);
          final note = await _decryptNote(model);
          if (note != null) {
            notes.add(note);
          }
        } catch (e) {
          // Skip invalid notes but continue processing
          continue;
        }
      }

      return Success(notes);
    } catch (e) {
      return Failure(StorageError('Failed to retrieve notes', e.toString()));
    }
  }

  @override
  Future<Result<SecureNote?>> getNoteById(String id) async {
    final allNotesResult = await getAllNotes();
    if (allNotesResult.isFailure) {
      return Failure(allNotesResult.errorOrNull!);
    }

    final notes = allNotesResult.valueOrNull!;
    try {
      final note = notes.firstWhere((n) => n.id == id);
      return Success(note);
    } catch (e) {
      return const Success(null);
    }
  }

  @override
  Future<Result<List<SecureNote>>> searchNotes(String query) async {
    final allNotesResult = await getAllNotes();
    if (allNotesResult.isFailure) {
      return Failure(allNotesResult.errorOrNull!);
    }

    final notes = allNotesResult.valueOrNull!;

    if (query.trim().isEmpty) {
      // Return all notes sorted by date if query is empty
      final sorted = List<SecureNote>.from(notes);
      sorted.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return Success(sorted);
    }

    final queryLower = query.toLowerCase();

    // Filter notes and calculate relevance scores
    final scoredNotes = <_ScoredNote>[];

    for (final note in notes) {
      final score = _calculateRelevanceScore(note, queryLower);
      if (score > 0) {
        scoredNotes.add(_ScoredNote(note, score));
      }
    }

    // Sort by relevance (higher score first), then by date (newer first)
    scoredNotes.sort((a, b) {
      final scoreComparison = b.score.compareTo(a.score);
      if (scoreComparison != 0) return scoreComparison;
      return b.note.updatedAt.compareTo(a.note.updatedAt);
    });

    final filtered = scoredNotes.map((sn) => sn.note).toList();
    return Success(filtered);
  }

  @override
  Future<Result<AttachedFile>> attachFile({
    required String noteId,
    required String fileName,
    required Uint8List fileData,
  }) async {
    // Validate file size (max 5MB)
    if (fileData.length > _maxFileSizeBytes) {
      return Failure(
        ValidationError('File attachment failed', {
          'size': 'File size exceeds maximum limit of 5MB',
        }),
      );
    }

    // Get the note
    final noteResult = await getNoteById(noteId);
    if (noteResult.isFailure) {
      return Failure(noteResult.errorOrNull!);
    }

    final note = noteResult.valueOrNull;
    if (note == null) {
      return Failure(
        ValidationError('File attachment failed', {'noteId': 'Note not found'}),
      );
    }

    // Create attached file metadata
    final fileId = _generateId();
    final attachedFile = AttachedFile(
      id: fileId,
      fileName: fileName,
      sizeBytes: fileData.length,
      attachedAt: DateTime.now(),
    );

    // Encrypt and save file data
    final encryptResult = await _encryptionService.encryptBytes(
      fileData,
      _masterKey,
    );
    if (encryptResult.isFailure) {
      return Failure(encryptResult.errorOrNull!);
    }

    final fileKey = _getFileKey(noteId, fileId);
    final encryptedBytes = encryptResult.valueOrNull!;
    final base64Data = base64.encode(encryptedBytes);

    final writeResult = await _storageService.write(fileKey, base64Data);
    if (writeResult.isFailure) {
      return Failure(writeResult.errorOrNull!);
    }

    // Update note with new attached file
    final updatedFiles = List<AttachedFile>.from(note.attachedFiles);
    updatedFiles.add(attachedFile);

    final updatedNote = note.copyWith(
      attachedFiles: updatedFiles,
      updatedAt: DateTime.now(),
    );

    final updateResult = await updateNote(updatedNote);
    if (updateResult.isFailure) {
      // Rollback: delete the file we just saved
      await _storageService.delete(fileKey);
      return Failure(updateResult.errorOrNull!);
    }

    return Success(attachedFile);
  }

  @override
  Future<Result<Uint8List>> getAttachedFileData(
    String noteId,
    String fileId,
  ) async {
    try {
      // Read encrypted file data from storage
      final fileKey = _getFileKey(noteId, fileId);
      final readResult = await _storageService.read(fileKey);
      if (readResult.isFailure) {
        return Failure(readResult.errorOrNull!);
      }

      final base64Data = readResult.valueOrNull;
      if (base64Data == null || base64Data.isEmpty) {
        return Failure(
          StorageError('File not found', 'No data for file $fileId'),
        );
      }

      // Decode from base64
      final encryptedBytes = base64.decode(base64Data);

      // Decrypt the file data
      final decryptResult = await _encryptionService.decryptBytes(
        encryptedBytes,
        _masterKey,
      );
      if (decryptResult.isFailure) {
        return Failure(decryptResult.errorOrNull!);
      }

      return Success(decryptResult.valueOrNull!);
    } catch (e) {
      return Failure(
        StorageError('Failed to retrieve file data', e.toString()),
      );
    }
  }

  @override
  Future<Result<void>> removeAttachedFile(String noteId, String fileId) async {
    // Get the note
    final noteResult = await getNoteById(noteId);
    if (noteResult.isFailure) {
      return Failure(noteResult.errorOrNull!);
    }

    final note = noteResult.valueOrNull;
    if (note == null) {
      return Failure(
        ValidationError('File removal failed', {'noteId': 'Note not found'}),
      );
    }

    // Check if file exists
    if (!note.attachedFiles.any((f) => f.id == fileId)) {
      return Failure(
        ValidationError('File removal failed', {'fileId': 'File not found'}),
      );
    }

    // Delete file data from storage
    final fileKey = _getFileKey(noteId, fileId);
    final deleteResult = await _storageService.delete(fileKey);
    if (deleteResult.isFailure) {
      return Failure(deleteResult.errorOrNull!);
    }

    // Update note to remove file metadata
    final updatedFiles = note.attachedFiles
        .where((f) => f.id != fileId)
        .toList();

    final updatedNote = note.copyWith(
      attachedFiles: updatedFiles,
      updatedAt: DateTime.now(),
    );

    final updateResult = await updateNote(updatedNote);
    if (updateResult.isFailure) {
      return Failure(updateResult.errorOrNull!);
    }

    return const Success(null);
  }

  /// Validates that a note has required fields
  ValidationError? _validateNote(SecureNote note) {
    final errors = <String, String>{};

    if (note.title.trim().isEmpty) {
      errors['title'] = 'Title is required';
    }

    if (errors.isNotEmpty) {
      return ValidationError('Note validation failed', errors);
    }

    return null;
  }

  /// Calculates relevance score for search query
  /// Higher score means more relevant
  /// Exact matches score higher than partial matches
  /// Title matches score higher than content
  int _calculateRelevanceScore(SecureNote note, String queryLower) {
    int score = 0;

    final titleLower = note.title.toLowerCase();
    final contentLower = note.content.toLowerCase();

    // Exact matches (highest priority)
    if (titleLower == queryLower) {
      score += 100;
    } else if (contentLower == queryLower) {
      score += 50;
    }

    // Starts with query (high priority)
    if (titleLower.startsWith(queryLower)) {
      score += 50;
    } else if (contentLower.startsWith(queryLower)) {
      score += 25;
    }

    // Contains query (lower priority)
    if (titleLower.contains(queryLower)) {
      score += 10;
    }
    if (contentLower.contains(queryLower)) {
      score += 5;
    }

    return score;
  }

  /// Saves all notes to encrypted storage
  Future<Result<void>> _saveAllNotes(List<SecureNote> notes) async {
    try {
      // Convert notes to models with encrypted data
      final models = <Map<String, dynamic>>[];
      for (final note in notes) {
        final model = await _encryptNoteToModel(note);
        if (model != null) {
          models.add(model.toJson());
        }
      }

      // Convert to JSON string
      final jsonString = jsonEncode(models);

      // Encrypt the entire JSON
      final encryptResult = await _encryptionService.encrypt(
        jsonString,
        _masterKey,
      );
      if (encryptResult.isFailure) {
        return Failure(encryptResult.errorOrNull!);
      }

      // Save to storage
      final writeResult = await _storageService.write(
        _notesKey,
        encryptResult.valueOrNull!,
      );
      if (writeResult.isFailure) {
        return Failure(writeResult.errorOrNull!);
      }

      return const Success(null);
    } catch (e) {
      return Failure(StorageError('Failed to save notes', e.toString()));
    }
  }

  /// Encrypts a SecureNote and converts to SecureNoteModel
  Future<SecureNoteModel?> _encryptNoteToModel(SecureNote note) async {
    try {
      // Convert note to SecureNoteData
      final noteData = SecureNoteData.fromDomain(note);

      // Convert to JSON string
      final jsonString = jsonEncode(noteData.toJson());

      // Encrypt the data
      final encryptResult = await _encryptionService.encrypt(
        jsonString,
        _masterKey,
      );
      if (encryptResult.isFailure) {
        return null;
      }

      // Create model
      return SecureNoteModel.fromDomain(note, encryptResult.valueOrNull!);
    } catch (e) {
      return null;
    }
  }

  /// Decrypts a SecureNoteModel and converts to SecureNote
  Future<SecureNote?> _decryptNote(SecureNoteModel model) async {
    try {
      // Decrypt the data
      final decryptResult = await _encryptionService.decrypt(
        model.encryptedData,
        _masterKey,
      );
      if (decryptResult.isFailure) {
        return null;
      }

      // Parse JSON
      final jsonData = jsonDecode(decryptResult.valueOrNull!);
      if (jsonData is! Map<String, dynamic>) {
        return null;
      }

      // Convert to SecureNoteData and then to SecureNote
      final noteData = SecureNoteData.fromJson(jsonData);
      return noteData.toDomain(model.id, model.createdAt, model.updatedAt);
    } catch (e) {
      return null;
    }
  }

  /// Generates a unique ID for notes and files
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Gets the storage key for an attached file
  String _getFileKey(String noteId, String fileId) {
    return '$_filesKeyPrefix${noteId}_$fileId';
  }
}

/// Helper class to store note with its relevance score
class _ScoredNote {
  final SecureNote note;
  final int score;

  _ScoredNote(this.note, this.score);
}
