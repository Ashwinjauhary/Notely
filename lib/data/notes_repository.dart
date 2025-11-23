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
    required String content,
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
  }

  Future<List<NoteModel>> getAllNotes() async {
    if (_notesBox == null) await _initializeRepository();
    
    return _notesBox!.values.toList();
  }

  Future<List<NoteModel>> getNotesByTag(String tag) async {
    final allNotes = await getAllNotes();
    return allNotes.where((note) => note.hasTag(tag)).toList();
  }

  Future<List<NoteModel>> searchNotes(String query) async {
    final allNotes = await getAllNotes();
    final lowercaseQuery = query.toLowerCase();
    
    return allNotes.where((note) =>
      note.title.toLowerCase().contains(lowercaseQuery) ||
      note.content.toString().toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  Future<List<NoteModel>> getPinnedNotes() async {
    final allNotes = await getAllNotes();
    return allNotes.where((note) => note.isPinned).toList();
  }

  Future<List<NoteModel>> getBookmarkedNotes() async {
    final allNotes = await getAllNotes();
    return allNotes.where((note) => note.isBookmarked).toList();
  }

  Future<List<String>> getAllTags() async {
    final allNotes = await getAllNotes();
    final allTags = <String>{};
    
    for (final note in allNotes) {
      allTags.addAll(note.tags);
    }
    
    return allTags.toList()..sort();
  }

  Future<void> batchDeleteNotes(List<String> ids) async {
    if (_notesBox == null) await _initializeRepository();
    
    for (final id in ids) {
      await _notesBox!.delete(id);
    }
    _notifyListeners();
  }

  Future<void> batchUpdateNotes(List<NoteModel> notes) async {
    if (_notesBox == null) await _initializeRepository();
    
    for (final note in notes) {
      final updatedNote = note.copyWith(updatedAt: DateTime.now());
      await _notesBox!.put(updatedNote.id, updatedNote);
    }
    _notifyListeners();
  }

  Future<Map<String, dynamic>> getStatistics() async {
    final allNotes = await getAllNotes();
    final pinnedNotes = await getPinnedNotes();
    final bookmarkedNotes = await getBookmarkedNotes();
    final allTags = await getAllTags();
    
    return {
      'totalNotes': allNotes.length,
      'pinnedNotes': pinnedNotes.length,
      'bookmarkedNotes': bookmarkedNotes.length,
      'totalTags': allTags.length,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  void dispose() {
    _debounceTimer?.cancel();
    _notesController.close();
    if (_notesBox != null) {
      _notesBox!.close();
    }
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
