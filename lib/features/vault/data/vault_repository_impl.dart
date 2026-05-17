import 'dart:convert';
import '../../../core/errors/failures.dart';
import '../../../core/services/encryption_service.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/utils/result.dart';
import '../domain/entry.dart';
import '../domain/vault_repository.dart';
import 'entry_model.dart';

/// Implementation of VaultRepository
/// Manages encrypted storage of password entries
class VaultRepositoryImpl implements VaultRepository {
  final EncryptionService _encryptionService;
  final SecureStorageService _storageService;
  final String _masterKey;

  static const String _entriesKey = 'entries';

  VaultRepositoryImpl({
    required EncryptionService encryptionService,
    required SecureStorageService storageService,
    required String masterKey,
  }) : _encryptionService = encryptionService,
       _storageService = storageService,
       _masterKey = masterKey;

  @override
  Future<Result<List<Entry>>> getAllEntries() async {
    try {
      // Read encrypted entries from storage
      final readResult = await _storageService.read(_entriesKey);
      if (readResult.isFailure) {
        return Failure(readResult.errorOrNull!);
      }

      final encryptedData = readResult.valueOrNull;
      if (encryptedData == null || encryptedData.isEmpty) {
        return const Success([]);
      }

      // Decrypt the entries data
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
          StorageError('Invalid entries data format', 'Expected JSON array'),
        );
      }

      // Convert to Entry objects
      final entries = <Entry>[];
      for (final item in jsonData) {
        if (item is! Map<String, dynamic>) continue;

        try {
          final model = EntryModel.fromJson(item);
          final entry = await _decryptEntry(model);
          if (entry != null) {
            entries.add(entry);
          }
        } catch (e) {
          // Skip invalid entries but continue processing
          continue;
        }
      }

      return Success(entries);
    } catch (e) {
      return Failure(StorageError('Failed to retrieve entries', e.toString()));
    }
  }

  @override
  Future<Result<Entry?>> getEntryById(String id) async {
    final allEntriesResult = await getAllEntries();
    if (allEntriesResult.isFailure) {
      return Failure(allEntriesResult.errorOrNull!);
    }

    final entries = allEntriesResult.valueOrNull!;
    try {
      final entry = entries.firstWhere((e) => e.id == id);
      return Success(entry);
    } catch (e) {
      return const Success(null);
    }
  }

  @override
  Future<Result<Entry>> createEntry(Entry entry) async {
    // Validate required fields
    final validationError = _validateEntry(entry);
    if (validationError != null) {
      return Failure(validationError);
    }

    // Get all existing entries
    final allEntriesResult = await getAllEntries();
    if (allEntriesResult.isFailure) {
      return Failure(allEntriesResult.errorOrNull!);
    }

    final entries = List<Entry>.from(allEntriesResult.valueOrNull!);

    // Check if entry with same ID already exists
    if (entries.any((e) => e.id == entry.id)) {
      return Failure(
        ValidationError('Entry creation failed', {
          'id': 'Entry with this ID already exists',
        }),
      );
    }

    // Add new entry
    entries.add(entry);

    // Save all entries
    final saveResult = await _saveAllEntries(entries);
    if (saveResult.isFailure) {
      return Failure(saveResult.errorOrNull!);
    }

    return Success(entry);
  }

  @override
  Future<Result<Entry>> updateEntry(Entry entry) async {
    // Validate required fields
    final validationError = _validateEntry(entry);
    if (validationError != null) {
      return Failure(validationError);
    }

    // Get all existing entries
    final allEntriesResult = await getAllEntries();
    if (allEntriesResult.isFailure) {
      return Failure(allEntriesResult.errorOrNull!);
    }

    final entries = List<Entry>.from(allEntriesResult.valueOrNull!);

    // Find the existing entry
    final existingIndex = entries.indexWhere((e) => e.id == entry.id);
    if (existingIndex == -1) {
      return Failure(
        ValidationError('Entry update failed', {'id': 'Entry not found'}),
      );
    }

    final existingEntry = entries[existingIndex];

    // Manage password history if password changed
    Entry updatedEntry = entry;
    if (existingEntry.password != entry.password) {
      final newHistory = List<PasswordHistory>.from(entry.passwordHistory);

      // Add the old password to history with timestamp
      newHistory.add(
        PasswordHistory(
          password: existingEntry.password,
          changedAt: DateTime.now(),
        ),
      );

      // Enforce limit of 10 passwords in history
      // Remove oldest entries if limit is exceeded
      const maxHistorySize = 10;
      if (newHistory.length > maxHistorySize) {
        // Remove the oldest entries (from the beginning of the list)
        newHistory.removeRange(0, newHistory.length - maxHistorySize);
      }

      updatedEntry = entry.copyWith(passwordHistory: newHistory);
    }

    // Update the entry
    entries[existingIndex] = updatedEntry;

    // Save all entries
    final saveResult = await _saveAllEntries(entries);
    if (saveResult.isFailure) {
      return Failure(saveResult.errorOrNull!);
    }

    return Success(updatedEntry);
  }

  @override
  Future<Result<void>> deleteEntry(String id) async {
    // Get all existing entries
    final allEntriesResult = await getAllEntries();
    if (allEntriesResult.isFailure) {
      return Failure(allEntriesResult.errorOrNull!);
    }

    final entries = List<Entry>.from(allEntriesResult.valueOrNull!);

    // Remove the entry
    final initialLength = entries.length;
    entries.removeWhere((e) => e.id == id);

    if (entries.length == initialLength) {
      return Failure(
        ValidationError('Entry deletion failed', {'id': 'Entry not found'}),
      );
    }

    // Save all entries
    final saveResult = await _saveAllEntries(entries);
    if (saveResult.isFailure) {
      return Failure(saveResult.errorOrNull!);
    }

    return const Success(null);
  }

  @override
  Future<Result<List<Entry>>> searchEntries(String query) async {
    final allEntriesResult = await getAllEntries();
    if (allEntriesResult.isFailure) {
      return Failure(allEntriesResult.errorOrNull!);
    }

    final entries = allEntriesResult.valueOrNull!;

    if (query.trim().isEmpty) {
      // Return all entries sorted by date if query is empty
      final sorted = List<Entry>.from(entries);
      sorted.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return Success(sorted);
    }

    final queryLower = query.toLowerCase();

    // Filter entries and calculate relevance scores
    final scoredEntries = <_ScoredEntry>[];

    for (final entry in entries) {
      final score = _calculateRelevanceScore(entry, queryLower);
      if (score > 0) {
        scoredEntries.add(_ScoredEntry(entry, score));
      }
    }

    // Sort by relevance (higher score first), then by date (newer first)
    scoredEntries.sort((a, b) {
      final scoreComparison = b.score.compareTo(a.score);
      if (scoreComparison != 0) return scoreComparison;
      return b.entry.updatedAt.compareTo(a.entry.updatedAt);
    });

    final filtered = scoredEntries.map((se) => se.entry).toList();
    return Success(filtered);
  }

  @override
  Future<Result<List<Entry>>> getEntriesByCategory(String category) async {
    final allEntriesResult = await getAllEntries();
    if (allEntriesResult.isFailure) {
      return Failure(allEntriesResult.errorOrNull!);
    }

    final entries = allEntriesResult.valueOrNull!;
    final filtered = entries
        .where((entry) => entry.categories.contains(category))
        .toList();

    // Sort by date (newer first)
    filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return Success(filtered);
  }

  @override
  Future<Result<List<Entry>>> searchWithFilters({
    String? query,
    String? category,
  }) async {
    final allEntriesResult = await getAllEntries();
    if (allEntriesResult.isFailure) {
      return Failure(allEntriesResult.errorOrNull!);
    }

    final entries = allEntriesResult.valueOrNull!;

    // Apply filters with AND logic
    List<Entry> filtered = entries;

    // Apply category filter if provided
    if (category != null && category.isNotEmpty) {
      filtered = filtered
          .where((entry) => entry.categories.contains(category))
          .toList();
    }

    // Apply search query if provided
    if (query != null && query.trim().isNotEmpty) {
      final queryLower = query.toLowerCase();

      // Filter and calculate relevance scores
      final scoredEntries = <_ScoredEntry>[];

      for (final entry in filtered) {
        final score = _calculateRelevanceScore(entry, queryLower);
        if (score > 0) {
          scoredEntries.add(_ScoredEntry(entry, score));
        }
      }

      // Sort by relevance (higher score first), then by date (newer first)
      scoredEntries.sort((a, b) {
        final scoreComparison = b.score.compareTo(a.score);
        if (scoreComparison != 0) return scoreComparison;
        return b.entry.updatedAt.compareTo(a.entry.updatedAt);
      });

      filtered = scoredEntries.map((se) => se.entry).toList();
    } else {
      // No search query, just sort by date
      filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }

    return Success(filtered);
  }

  @override
  Future<Result<List<Entry>>> getFavorites() async {
    final allEntriesResult = await getAllEntries();
    if (allEntriesResult.isFailure) {
      return Failure(allEntriesResult.errorOrNull!);
    }

    final entries = allEntriesResult.valueOrNull!;
    final favorites = entries.where((entry) => entry.isFavorite).toList();

    // Sort by access count (most accessed first)
    favorites.sort((a, b) => b.accessCount.compareTo(a.accessCount));

    return Success(favorites);
  }

  @override
  Future<Result<Entry>> toggleFavorite(String id) async {
    // Get all existing entries
    final allEntriesResult = await getAllEntries();
    if (allEntriesResult.isFailure) {
      return Failure(allEntriesResult.errorOrNull!);
    }

    final entries = List<Entry>.from(allEntriesResult.valueOrNull!);

    // Find the entry
    final existingIndex = entries.indexWhere((e) => e.id == id);
    if (existingIndex == -1) {
      return Failure(
        ValidationError('Toggle favorite failed', {'id': 'Entry not found'}),
      );
    }

    final existingEntry = entries[existingIndex];
    final updatedEntry = existingEntry.copyWith(
      isFavorite: !existingEntry.isFavorite,
    );

    // Update the entry
    entries[existingIndex] = updatedEntry;

    // Save all entries
    final saveResult = await _saveAllEntries(entries);
    if (saveResult.isFailure) {
      return Failure(saveResult.errorOrNull!);
    }

    return Success(updatedEntry);
  }

  /// Validates that an entry has required fields
  ValidationError? _validateEntry(Entry entry) {
    final errors = <String, String>{};

    if (entry.title.trim().isEmpty) {
      errors['title'] = 'Title is required';
    }

    if (entry.password.trim().isEmpty) {
      errors['password'] = 'Password is required';
    }

    if (errors.isNotEmpty) {
      return ValidationError('Entry validation failed', errors);
    }

    return null;
  }

  /// Calculates relevance score for search query
  /// Higher score means more relevant
  /// Exact matches score higher than partial matches
  /// Title matches score higher than other fields
  int _calculateRelevanceScore(Entry entry, String queryLower) {
    int score = 0;

    final titleLower = entry.title.toLowerCase();
    final usernameLower = entry.username.toLowerCase();
    final urlLower = entry.url?.toLowerCase() ?? '';
    final notesLower = entry.notes?.toLowerCase() ?? '';

    // Exact matches (highest priority)
    if (titleLower == queryLower) {
      score += 100;
    } else if (usernameLower == queryLower) {
      score += 80;
    } else if (urlLower == queryLower) {
      score += 60;
    } else if (notesLower == queryLower) {
      score += 40;
    }

    // Starts with query (high priority)
    if (titleLower.startsWith(queryLower)) {
      score += 50;
    } else if (usernameLower.startsWith(queryLower)) {
      score += 40;
    } else if (urlLower.startsWith(queryLower)) {
      score += 30;
    } else if (notesLower.startsWith(queryLower)) {
      score += 20;
    }

    // Contains query (lower priority)
    if (titleLower.contains(queryLower)) {
      score += 10;
    }
    if (usernameLower.contains(queryLower)) {
      score += 8;
    }
    if (urlLower.contains(queryLower)) {
      score += 6;
    }
    if (notesLower.contains(queryLower)) {
      score += 4;
    }

    return score;
  }

  /// Saves all entries to encrypted storage
  Future<Result<void>> _saveAllEntries(List<Entry> entries) async {
    try {
      // Convert entries to models with encrypted data
      final models = <Map<String, dynamic>>[];
      for (final entry in entries) {
        final model = await _encryptEntryToModel(entry);
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
        _entriesKey,
        encryptResult.valueOrNull!,
      );
      if (writeResult.isFailure) {
        return Failure(writeResult.errorOrNull!);
      }

      return const Success(null);
    } catch (e) {
      return Failure(StorageError('Failed to save entries', e.toString()));
    }
  }

  /// Encrypts an Entry and converts to EntryModel
  Future<EntryModel?> _encryptEntryToModel(Entry entry) async {
    try {
      // Convert entry to EntryData
      final entryData = EntryData.fromDomain(entry);

      // Convert to JSON string
      final jsonString = jsonEncode(entryData.toJson());

      // Encrypt the data
      final encryptResult = await _encryptionService.encrypt(
        jsonString,
        _masterKey,
      );
      if (encryptResult.isFailure) {
        return null;
      }

      // Create model
      return EntryModel.fromDomain(entry, encryptResult.valueOrNull!);
    } catch (e) {
      return null;
    }
  }

  /// Decrypts an EntryModel and converts to Entry
  Future<Entry?> _decryptEntry(EntryModel model) async {
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

      // Convert to EntryData and then to Entry
      final entryData = EntryData.fromJson(jsonData);
      return entryData.toDomain(model.id, model.createdAt, model.updatedAt);
    } catch (e) {
      return null;
    }
  }
}

/// Helper class to store entry with its relevance score
class _ScoredEntry {
  final Entry entry;
  final int score;

  _ScoredEntry(this.entry, this.score);
}
