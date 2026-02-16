import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:markey_app/core/services/encryption_service.dart';
import 'package:markey_app/core/services/encryption_service_impl.dart';
import 'package:markey_app/core/services/secure_storage_service.dart';
import 'package:markey_app/core/utils/result.dart';
import 'package:markey_app/features/notes/data/secure_note_repository_impl.dart';
import 'package:markey_app/features/notes/domain/secure_note.dart';

/// Mock implementation of SecureStorageService for testing
class MockSecureStorageService implements SecureStorageService {
  final Map<String, String> _storage = {};

  @override
  Future<Result<String?>> read(String key) async {
    return Success(_storage[key]);
  }

  @override
  Future<Result<void>> write(String key, String value) async {
    _storage[key] = value;
    return const Success(null);
  }

  @override
  Future<Result<void>> delete(String key) async {
    _storage.remove(key);
    return const Success(null);
  }

  @override
  Future<Result<void>> deleteAll() async {
    _storage.clear();
    return const Success(null);
  }

  @override
  Future<Result<bool>> containsKey(String key) async {
    return Success(_storage.containsKey(key));
  }

  @override
  Future<Result<Map<String, String>>> readAll() async {
    return Success(Map.from(_storage));
  }

  @override
  Future<bool> isStorageAvailable() async {
    return true;
  }
}

void main() {
  late SecureNoteRepositoryImpl repository;
  late EncryptionService encryptionService;
  late MockSecureStorageService storageService;
  const masterKey = 'test_master_key_123';

  setUp(() {
    encryptionService = EncryptionServiceImpl();
    storageService = MockSecureStorageService();
    repository = SecureNoteRepositoryImpl(
      encryptionService: encryptionService,
      storageService: storageService,
      masterKey: masterKey,
    );
  });

  group('SecureNoteRepository - Basic CRUD', () {
    test('should create a note successfully', () async {
      // Arrange
      final note = SecureNote(
        id: '1',
        title: 'Test Note',
        content: 'This is a test note content',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final result = await repository.createNote(note);

      // Assert
      expect(result.isSuccess, true);
      expect(result.valueOrNull?.id, note.id);
      expect(result.valueOrNull?.title, note.title);
    });

    test('should fail to create note without title', () async {
      // Arrange
      final note = SecureNote(
        id: '1',
        title: '',
        content: 'Content',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final result = await repository.createNote(note);

      // Assert
      expect(result.isFailure, true);
    });

    test('should retrieve all notes', () async {
      // Arrange
      final note1 = SecureNote(
        id: '1',
        title: 'Note 1',
        content: 'Content 1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final note2 = SecureNote(
        id: '2',
        title: 'Note 2',
        content: 'Content 2',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createNote(note1);
      await repository.createNote(note2);

      // Act
      final result = await repository.getAllNotes();

      // Assert
      expect(result.isSuccess, true);
      expect(result.valueOrNull?.length, 2);
    });

    test('should update a note', () async {
      // Arrange
      final note = SecureNote(
        id: '1',
        title: 'Original Title',
        content: 'Original Content',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createNote(note);

      final updatedNote = note.copyWith(
        title: 'Updated Title',
        content: 'Updated Content',
      );

      // Act
      final result = await repository.updateNote(updatedNote);

      // Assert
      expect(result.isSuccess, true);
      expect(result.valueOrNull?.title, 'Updated Title');
      expect(result.valueOrNull?.content, 'Updated Content');
    });

    test('should delete a note', () async {
      // Arrange
      final note = SecureNote(
        id: '1',
        title: 'Test Note',
        content: 'Content',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createNote(note);

      // Act
      final deleteResult = await repository.deleteNote(note.id);
      final getAllResult = await repository.getAllNotes();

      // Assert
      expect(deleteResult.isSuccess, true);
      expect(getAllResult.valueOrNull?.length, 0);
    });

    test('should get note by id', () async {
      // Arrange
      final note = SecureNote(
        id: '1',
        title: 'Test Note',
        content: 'Content',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createNote(note);

      // Act
      final result = await repository.getNoteById('1');

      // Assert
      expect(result.isSuccess, true);
      expect(result.valueOrNull?.id, '1');
      expect(result.valueOrNull?.title, 'Test Note');
    });

    test('should return null for non-existent note', () async {
      // Act
      final result = await repository.getNoteById('non_existent');

      // Assert
      expect(result.isSuccess, true);
      expect(result.valueOrNull, null);
    });
  });

  group('SecureNoteRepository - Search', () {
    test('should search notes by title', () async {
      // Arrange
      final note1 = SecureNote(
        id: '1',
        title: 'Important Meeting Notes',
        content: 'Discussion about project',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final note2 = SecureNote(
        id: '2',
        title: 'Shopping List',
        content: 'Buy groceries',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createNote(note1);
      await repository.createNote(note2);

      // Act
      final result = await repository.searchNotes('meeting');

      // Assert
      expect(result.isSuccess, true);
      expect(result.valueOrNull?.length, 1);
      expect(result.valueOrNull?.first.title, 'Important Meeting Notes');
    });

    test('should search notes by content', () async {
      // Arrange
      final note1 = SecureNote(
        id: '1',
        title: 'Note 1',
        content: 'Contains important information',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final note2 = SecureNote(
        id: '2',
        title: 'Note 2',
        content: 'Random content',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createNote(note1);
      await repository.createNote(note2);

      // Act
      final result = await repository.searchNotes('important');

      // Assert
      expect(result.isSuccess, true);
      expect(result.valueOrNull?.length, 1);
      expect(result.valueOrNull?.first.id, '1');
    });

    test('should return all notes when search query is empty', () async {
      // Arrange
      final note1 = SecureNote(
        id: '1',
        title: 'Note 1',
        content: 'Content 1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final note2 = SecureNote(
        id: '2',
        title: 'Note 2',
        content: 'Content 2',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createNote(note1);
      await repository.createNote(note2);

      // Act
      final result = await repository.searchNotes('');

      // Assert
      expect(result.isSuccess, true);
      expect(result.valueOrNull?.length, 2);
    });
  });

  group('SecureNoteRepository - File Attachments', () {
    test('should attach file to note', () async {
      // Arrange
      final note = SecureNote(
        id: '1',
        title: 'Note with attachment',
        content: 'Content',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createNote(note);

      final fileData = Uint8List.fromList([1, 2, 3, 4, 5]);

      // Act
      final result = await repository.attachFile(
        noteId: '1',
        fileName: 'test.txt',
        fileData: fileData,
      );

      // Assert
      expect(result.isSuccess, true);
      expect(result.valueOrNull?.fileName, 'test.txt');
      expect(result.valueOrNull?.sizeBytes, 5);
    });

    test('should fail to attach file exceeding 5MB', () async {
      // Arrange
      final note = SecureNote(
        id: '1',
        title: 'Note',
        content: 'Content',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createNote(note);

      // Create a file larger than 5MB
      final fileData = Uint8List(6 * 1024 * 1024); // 6MB

      // Act
      final result = await repository.attachFile(
        noteId: '1',
        fileName: 'large_file.bin',
        fileData: fileData,
      );

      // Assert
      expect(result.isFailure, true);
    });

    test('should retrieve attached file data', () async {
      // Arrange
      final note = SecureNote(
        id: '1',
        title: 'Note',
        content: 'Content',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createNote(note);

      final originalData = Uint8List.fromList([10, 20, 30, 40, 50]);
      final attachResult = await repository.attachFile(
        noteId: '1',
        fileName: 'data.bin',
        fileData: originalData,
      );

      final fileId = attachResult.valueOrNull!.id;

      // Act
      final result = await repository.getAttachedFileData('1', fileId);

      // Assert
      expect(result.isSuccess, true);
      expect(result.valueOrNull, originalData);
    });

    test('should remove attached file', () async {
      // Arrange
      final note = SecureNote(
        id: '1',
        title: 'Note',
        content: 'Content',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createNote(note);

      final fileData = Uint8List.fromList([1, 2, 3]);
      final attachResult = await repository.attachFile(
        noteId: '1',
        fileName: 'file.txt',
        fileData: fileData,
      );

      final fileId = attachResult.valueOrNull!.id;

      // Act
      final removeResult = await repository.removeAttachedFile('1', fileId);
      final noteResult = await repository.getNoteById('1');

      // Assert
      expect(removeResult.isSuccess, true);
      expect(noteResult.valueOrNull?.attachedFiles.length, 0);
    });
  });
}
