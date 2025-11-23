import 'dart:async';
import 'package:hive/hive.dart';
import 'package:notely/models/note_model.dart';

class NotesRepository {
  static const String _notesBoxName = 'notes';
  Box<NoteModel>? _notesBox;
  final StreamController<List<NoteModel>> _notesController = StreamController.broadcast();
  Timer? _debounceTimer;

  NotesRepository() {
    _initializeRepository();
  }

  Future<void> _initializeRepository() async {
    try {
      _notesBox = await Hive.openBox<NoteModel>(_notesBoxName);
      _notifyListeners();
    } catch (e) {
      throw Exception('Failed to initialize notes repository: $e');
    }
  }

  void _notifyListeners() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 100), () {
      if (_notesBox != null) {
        _notesController.add(_notesBox!.values.toList());
      }
    });
  }

  Stream<List<NoteModel>> get notesStream => _notesController.stream;

  Future<NoteModel> createNote({
    required String title,
    required List<dynamic> content,
    String color = '#FFFFFF',
    List<String> tags = const [],
  }) async {
    if (_notesBox == null) await _initializeRepository();
    
    final note = NoteModel(
      title: title,
      content: content,
      color: color,
      tags: tags,
    );
    
    await _notesBox!.put(note.id, note);
    _notifyListeners();
    return note;
  }

  Future<NoteModel> updateNote(NoteModel note) async {
    if (_notesBox == null) await _initializeRepository();
    
    final updatedNote = note.copyWith(updatedAt: DateTime.now());
    await _notesBox!.put(updatedNote.id, updatedNote);
    _notifyListeners();
    return updatedNote;
  }

  Future<void> deleteNote(String id) async {
    if (_notesBox == null) await _initializeRepository();
    
    await _notesBox!.delete(id);
    _notifyListeners();
  }

  Future<NoteModel?> getNoteById(String id) async {
    if (_notesBox == null) await _initializeRepository();
    
    return _notesBox!.get(id);
    if (endDate != null) {
      notes = notes.where((note) => note.updatedAt.isBefore(endDate)).toList();
    }

    if (color != null) {
      notes = notes.where((note) => note.color == color).toList();
    }

    return notes;
  }

  List<NoteModel> sortNotes(List<NoteModel> notes, SortOption sortOption) {
    final sortedNotes = List<NoteModel>.from(notes);

    switch (sortOption) {
      case SortOption.dateModifiedDesc:
        sortedNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case SortOption.dateModifiedAsc:
        sortedNotes.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
        break;
      case SortOption.dateCreatedDesc:
        sortedNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.dateCreatedAsc:
        sortedNotes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortOption.titleAsc:
        sortedNotes.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case SortOption.titleDesc:
        sortedNotes.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
      case SortOption.pinnedFirst:
        final pinned = sortedNotes.where((note) => note.isPinned).toList();
        final regular = sortedNotes.where((note) => !note.isPinned).toList();
        return [...pinned, ...regular];
    }

    return sortedNotes;
  }

  // Tag Management
  List<String> getAllTags() {
    final allTags = <String>{};
    for (final note in _notesBox.values) {
      allTags.addAll(note.tags);
    }
    return allTags.toList()..sort();
  }

  Future<void> renameTag(String oldName, String newName) async {
    for (final note in _notesBox.values) {
      if (note.hasTag(oldName)) {
        final updatedTags = List<String>.from(note.tags);
        updatedTags[updatedTags.indexOf(oldName)] = newName;
        await updateNote(note.copyWith(tags: updatedTags));
      }
    }
  }

  Future<void> deleteTag(String tagName) async {
    for (final note in _notesBox.values) {
      if (note.hasTag(tagName)) {
        final updatedTags = List<String>.from(note.tags)..remove(tagName);
        await updateNote(note.copyWith(tags: updatedTags));
      }
    }
  }

  // Batch Operations
  Future<void> togglePinMultiple(List<String> noteIds) async {
    for (final noteId in noteIds) {
      final note = getNoteById(noteId);
      if (note != null) {
        await updateNote(note.copyWith(isPinned: !note.isPinned));
      }
    }
  }

  Future<void> toggleBookmarkMultiple(List<String> noteIds) async {
    for (final noteId in noteIds) {
      final note = getNoteById(noteId);
      if (note != null) {
        await updateNote(note.copyWith(isBookmarked: !note.isBookmarked));
      }
    }
  }

  Future<void> changeColorMultiple(List<String> noteIds, String color) async {
    for (final noteId in noteIds) {
      final note = getNoteById(noteId);
      if (note != null) {
        await updateNote(note.copyWith(color: color));
      }
    }
  }

  Future<void> addTagToMultiple(List<String> noteIds, String tag) async {
    for (final noteId in noteIds) {
      final note = getNoteById(noteId);
      if (note != null && !note.hasTag(tag)) {
        final updatedTags = List<String>.from(note.tags)..add(tag);
        await updateNote(note.copyWith(tags: updatedTags));
      }
    }
  }

  // Statistics
  Map<String, dynamic> getStatistics() {
    return HiveAdapter.getStatistics();
  }

  // Stream
  Stream<List<NoteModel>> get notesStream => _notesController.stream;

  // Cleanup
  void dispose() {
    _notesBox.listenable().removeListener(_notifyListeners);
    _notesController.close();
  }
}

enum SortOption {
  dateModifiedDesc,
  dateModifiedAsc,
  dateCreatedDesc,
  dateCreatedAsc,
  titleAsc,
  titleDesc,
  pinnedFirst,
}
