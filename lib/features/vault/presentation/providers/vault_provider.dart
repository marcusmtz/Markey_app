import 'package:flutter/foundation.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entry.dart';
import '../../domain/vault_repository.dart';

/// Provider for managing vault state
class VaultProvider extends ChangeNotifier {
  final VaultRepository? _repository;
  String? _masterKey;

  VaultProvider({VaultRepository? repository}) : _repository = repository;

  List<Entry> _entries = [];
  List<Entry> _filteredEntries = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String? _selectedCategory;
  bool _showOnlyFavorites = false;

  List<Entry> get entries => _filteredEntries;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  bool get showOnlyFavorites => _showOnlyFavorites;
  bool get hasFilters =>
      _searchQuery.isNotEmpty ||
      _selectedCategory != null ||
      _showOnlyFavorites;
  bool get isInitialized => _masterKey != null;

  /// Initialize with master key after authentication
  void initialize(String masterKey) {
    _masterKey = masterKey;
    loadEntries();
  }

  /// Load all entries from storage
  Future<void> loadEntries() async {
    if (_masterKey == null) {
      _errorMessage = 'Vault not initialized';
      notifyListeners();
      return;
    }

    if (_repository == null) {
      _errorMessage = 'Repository not available';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getAllEntries();
      if (result.isSuccess) {
        _entries = result.valueOrNull ?? [];
        print('VaultProvider: Loaded ${_entries.length} entries'); // DEBUG
        _applyFilters();
      } else {
        _errorMessage = result.errorOrNull?.message ?? 'Failed to load entries';
        print('VaultProvider: Error loading entries: $_errorMessage'); // DEBUG
        _entries = [];
        _filteredEntries = [];
      }
    } catch (e) {
      _errorMessage = 'Error loading entries: $e';
      print('VaultProvider: Exception loading entries: $e'); // DEBUG
      _entries = [];
      _filteredEntries = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Search entries with current filters
  Future<void> search(String query) async {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  /// Filter by category
  Future<void> filterByCategory(String? category) async {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  /// Toggle favorites filter
  Future<void> toggleFavoritesFilter() async {
    _showOnlyFavorites = !_showOnlyFavorites;
    _applyFilters();
    notifyListeners();
  }

  /// Clear all filters
  Future<void> clearFilters() async {
    _searchQuery = '';
    _selectedCategory = null;
    _showOnlyFavorites = false;
    _applyFilters();
    notifyListeners();
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String id) async {
    if (_masterKey == null || _repository == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _repository.toggleFavorite(id);
      if (result.isSuccess) {
        await loadEntries();
      } else {
        _errorMessage =
            result.errorOrNull?.message ?? 'Failed to toggle favorite';
        print(
          'VaultProvider: Error toggling favorite: $_errorMessage',
        ); // DEBUG
      }
    } catch (e) {
      _errorMessage = 'Error toggling favorite: $e';
      print('VaultProvider: Exception toggling favorite: $e'); // DEBUG
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Delete entry
  Future<bool> deleteEntry(String id) async {
    if (_masterKey == null || _repository == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _repository.deleteEntry(id);
      if (result.isSuccess) {
        print('VaultProvider: Entry deleted successfully'); // DEBUG
        await loadEntries();
        return true;
      } else {
        _errorMessage = result.errorOrNull?.message ?? 'Failed to delete entry';
        print('VaultProvider: Error deleting entry: $_errorMessage'); // DEBUG
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error deleting entry: $e';
      print('VaultProvider: Exception deleting entry: $e'); // DEBUG
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Increment access count for an entry
  Future<void> incrementAccessCount(String id) async {
    if (_masterKey == null || _repository == null) return;

    // Find the entry and increment its access count
    final entryResult = await _repository.getEntryById(id);
    if (entryResult.isSuccess && entryResult.valueOrNull != null) {
      final entry = entryResult.valueOrNull!;
      final updatedEntry = entry.copyWith(accessCount: entry.accessCount + 1);
      await _repository.updateEntry(updatedEntry);
    }
  }

  /// Apply current filters to entries
  void _applyFilters() {
    _filteredEntries = List.from(_entries);

    // Apply favorites filter
    if (_showOnlyFavorites) {
      _filteredEntries = _filteredEntries
          .where((entry) => entry.isFavorite)
          .toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      _filteredEntries = _filteredEntries.where((entry) {
        return entry.title.toLowerCase().contains(query) ||
            entry.username.toLowerCase().contains(query) ||
            (entry.url?.toLowerCase().contains(query) ?? false) ||
            (entry.notes?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Apply category filter
    if (_selectedCategory != null) {
      _filteredEntries = _filteredEntries
          .where((entry) => entry.categories.contains(_selectedCategory))
          .toList();
    }

    // Sort by date
    _filteredEntries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  /// Clear vault data on logout
  void clear() {
    _masterKey = null;
    _entries = [];
    _filteredEntries = [];
    _searchQuery = '';
    _selectedCategory = null;
    _showOnlyFavorites = false;
    _errorMessage = null;
    notifyListeners();
  }
}
