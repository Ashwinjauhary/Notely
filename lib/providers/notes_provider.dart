import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notely/data/notes_repository.dart';
import 'package:notely/models/note_model.dart';

// Repository provider
final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepository();
});

// Notes state
class NotesState {
  final List<NoteModel> notes;
  final List<NoteModel> filteredNotes;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final String? selectedTag;
  final SortOption sortOption;
  final bool isGridView;
  final Set<String> selectedNotes;

  const NotesState({
    this.notes = const [],
    this.filteredNotes = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.selectedTag,
    this.sortOption = SortOption.dateModifiedDesc,
    this.isGridView = true,
    this.selectedNotes = const {},
  });

  NotesState copyWith({
    List<NoteModel>? notes,
    List<NoteModel>? filteredNotes,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? selectedTag,
    SortOption? sortOption,
    bool? isGridView,
    Set<String>? selectedNotes,
  }) {
    return NotesState(
      notes: notes ?? this.notes,
      filteredNotes: filteredNotes ?? this.filteredNotes,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTag: selectedTag ?? this.selectedTag,
      sortOption: sortOption ?? this.sortOption,
      isGridView: isGridView ?? this.isGridView,
      selectedNotes: selectedNotes ?? this.selectedNotes,
    );
  }

  int get pinnedCount => notes.where((note) => note.isPinned).length;
  int get bookmarkedCount => notes.where((note) => note.isBookmarked).length;
  int get selectedCount => selectedNotes.length;
  bool get hasSelection => selectedNotes.isNotEmpty;
}

// Notes notifier
class NotesNotifier extends StateNotifier<NotesState> {
  final NotesRepository _repository;
  late StreamSubscription _notesSubscription;

  NotesNotifier(this._repository) : super(const NotesState()) {
    _initializeNotes();
  }

  void _initializeNotes() {
    state = state.copyWith(isLoading: true);
    
    _notesSubscription = _repository.notesStream.listen(
      (notes) {
        state = state.copyWith(
          notes: notes,
          isLoading: false,
          error: null,
        );
        _applyFiltersAndSort();
      },
      onError: (error) {
        state = state.copyWith(
          isLoading: false,
          error: error.toString(),
        );
      },
    );
  }

  void _applyFiltersAndSort() {
    var filteredNotes = state.notes;

    // Apply search filter
    if (state.searchQuery.isNotEmpty) {
      filteredNotes = _repository.searchNotes(state.searchQuery);
    }

    // Apply tag filter
    if (state.selectedTag != null) {
      filteredNotes = filteredNotes.where((note) => note.hasTag(state.selectedTag!)).toList();
    }

    // Apply sorting
    filteredNotes = _repository.sortNotes(filteredNotes, state.sortOption);

    state = state.copyWith(filteredNotes: filteredNotes);
  }

  // CRUD Operations
  Future<void> createNote({
    required String title,
    String content = '',
    List<String>? tags,
    String color = '#FFFFFF',
  }) async {
    try {
      state = state.copyWith(isLoading: true);
      await _repository.createNote(
        title: title,
        content: content,
        tags: tags,
        color: color,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateNote(NoteModel note) async {
    try {
      state = state.copyWith(isLoading: true);
      await _repository.updateNote(note);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      state = state.copyWith(isLoading: true);
      await _repository.deleteNote(noteId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> deleteSelectedNotes() async {
    try {
      state = state.copyWith(isLoading: true);
      await _repository.deleteNotes(state.selectedNotes.toList());
      clearSelection();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Search and Filter
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFiltersAndSort();
  }

  void setSelectedTag(String? tag) {
    state = state.copyWith(selectedTag: tag);
    _applyFiltersAndSort();
  }

  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      selectedTag: null,
    );
    _applyFiltersAndSort();
  }

  // Sorting
  void setSortOption(SortOption option) {
    state = state.copyWith(sortOption: option);
    _applyFiltersAndSort();
  }

  // View Mode
  void toggleViewMode() {
    state = state.copyWith(isGridView: !state.isGridView);
  }

  // Selection
  void toggleNoteSelection(String noteId) {
    final newSelection = Set<String>.from(state.selectedNotes);
    if (newSelection.contains(noteId)) {
      newSelection.remove(noteId);
    } else {
      newSelection.add(noteId);
    }
    state = state.copyWith(selectedNotes: newSelection);
  }

  void selectAllNotes() {
    state = state.copyWith(
      selectedNotes: Set<String>.from(state.filteredNotes.map((note) => note.id)),
    );
  }

  void clearSelection() {
    state = state.copyWith(selectedNotes: <String>{});
  }

  // Batch Operations
  Future<void> togglePinSelected() async {
    try {
      state = state.copyWith(isLoading: true);
      await _repository.togglePinMultiple(state.selectedNotes.toList());
      clearSelection();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> toggleBookmarkSelected() async {
    try {
      state = state.copyWith(isLoading: true);
      await _repository.toggleBookmarkMultiple(state.selectedNotes.toList());
      clearSelection();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> changeColorSelected(String color) async {
    try {
      state = state.copyWith(isLoading: true);
      await _repository.changeColorMultiple(state.selectedNotes.toList(), color);
      clearSelection();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> addTagToSelected(String tag) async {
    try {
      state = state.copyWith(isLoading: true);
      await _repository.addTagToMultiple(state.selectedNotes.toList(), tag);
      clearSelection();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Note Actions
  Future<void> togglePin(NoteModel note) async {
    try {
      await _repository.updateNote(note.copyWith(isPinned: !note.isPinned));
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> toggleBookmark(NoteModel note) async {
    try {
      await _repository.updateNote(note.copyWith(isBookmarked: !note.isBookmarked));
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> changeNoteColor(NoteModel note, String color) async {
    try {
      await _repository.updateNote(note.copyWith(color: color));
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Tag Management
  List<String> get allTags => _repository.getAllTags();

  Future<void> renameTag(String oldName, String newName) async {
    try {
      state = state.copyWith(isLoading: true);
      await _repository.renameTag(oldName, newName);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> deleteTag(String tagName) async {
    try {
      state = state.copyWith(isLoading: true);
      await _repository.deleteTag(tagName);
      if (state.selectedTag == tagName) {
        setSelectedTag(null);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Statistics
  Map<String, dynamic> get statistics => _repository.getStatistics();

  // Error handling
  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _notesSubscription.cancel();
    super.dispose();
  }
}

// Provider
final notesProvider = StateNotifierProvider<NotesNotifier, NotesState>((ref) {
  final repository = ref.watch(notesRepositoryProvider);
  return NotesNotifier(repository);
});

// Specific providers for convenience
final filteredNotesProvider = Provider<List<NoteModel>>((ref) {
  return ref.watch(notesProvider).filteredNotes;
});

final pinnedNotesProvider = Provider<List<NoteModel>>((ref) {
  return ref.watch(notesProvider).notes.pinnedNotes;
});

final bookmarkedNotesProvider = Provider<List<NoteModel>>((ref) {
  return ref.watch(notesProvider).notes.bookmarkedNotes;
});

final allTagsProvider = Provider<List<String>>((ref) {
  return ref.watch(notesProvider).allTags;
});

final searchQueryProvider = Provider<String>((ref) {
  return ref.watch(notesProvider).searchQuery;
});

final selectedTagProvider = Provider<String?>((ref) {
  return ref.watch(notesProvider).selectedTag;
});

final isGridViewProvider = Provider<bool>((ref) {
  return ref.watch(notesProvider).isGridView;
});
