import '../../../core/utils/result.dart';
import 'entry.dart';

/// Abstract repository interface for vault operations
/// Defines CRUD operations for password entries
abstract class VaultRepository {
  /// Retrieves all entries from the vault
  Future<Result<List<Entry>>> getAllEntries();

  /// Retrieves a specific entry by ID
  /// Returns null if entry not found
  Future<Result<Entry?>> getEntryById(String id);

  /// Creates a new entry in the vault
  /// Validates required fields (title, password)
  Future<Result<Entry>> createEntry(Entry entry);

  /// Updates an existing entry
  /// Manages password history when password changes
  Future<Result<Entry>> updateEntry(Entry entry);

  /// Deletes an entry by ID
  Future<Result<void>> deleteEntry(String id);

  /// Searches entries by query string
  /// Searches in title, username, URL, and notes fields
  /// Results are ordered by relevance and modification date
  Future<Result<List<Entry>>> searchEntries(String query);

  /// Retrieves entries filtered by category
  Future<Result<List<Entry>>> getEntriesByCategory(String category);

  /// Searches entries with combined filters (AND logic)
  /// If query is empty, only category filter is applied
  /// If category is null, only search query is applied
  /// Results are ordered by relevance and modification date
  Future<Result<List<Entry>>> searchWithFilters({
    String? query,
    String? category,
  });

  /// Retrieves all favorite entries
  Future<Result<List<Entry>>> getFavorites();

  /// Toggles favorite status of an entry
  Future<Result<Entry>> toggleFavorite(String id);
}
