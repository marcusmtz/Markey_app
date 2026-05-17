import 'package:flutter/foundation.dart';
import '../../../../core/utils/result.dart';
import '../../domain/secure_note.dart';
import '../../domain/secure_note_repository.dart';

/// Provider for managing secure notes state
class NotesProvider extends ChangeNotifier {
  final SecureNoteRepository _repository;

  NotesProvider({required SecureNoteRepository repository})
    : _repository = repository;

  List<SecureNote> _notes = [];
  List<SecureNote> _filteredNotes = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<SecureNote> get notes => _filteredNotes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get hasSearch => _searchQuery.isNotEmpty;

  /// Load all notes from repository
  Future<void> loadNotes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getAllNotes();

    if (result.isSuccess) {
      _notes = result.valueOrNull ?? [];
      _applyFilters();
    } else {
      _errorMessage = result.errorOrNull?.message ?? 'Failed to load notes';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Search notes
  Future<void> search(String query) async {
    _searchQuery = query;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.searchNotes(query);

    if (result.isSuccess) {
      _filteredNotes = result.valueOrNull ?? [];
    } else {
      _errorMessage = result.errorOrNull?.message ?? 'Search failed';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Clear search
  Future<void> clearSearch() async {
    _searchQuery = '';
    await loadNotes();
  }

  /// Delete note
  Future<bool> deleteNote(String id) async {
    final result = await _repository.deleteNote(id);

    if (result.isSuccess) {
      await loadNotes();
      return true;
    } else {
      _errorMessage = result.errorOrNull?.message ?? 'Failed to delete note';
      notifyListeners();
      return false;
    }
  }

  /// Apply current filters to notes
  void _applyFilters() {
    if (_searchQuery.isEmpty) {
      _filteredNotes = List.from(_notes);
      _filteredNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }
  }
}
