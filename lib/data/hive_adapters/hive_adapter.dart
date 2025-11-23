import 'package:hive_flutter/hive_flutter.dart';
import 'package:notely/models/note_model.dart';

class HiveAdapter {
  static Future<void> initializeHive() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(NoteModelAdapter());
    }
    
    // Open boxes
    await _openBoxes();
  }

  static Future<void> _openBoxes() async {
    // Open notes box
    await Hive.openBox<NoteModel>('notes');
    
    // Open settings box
    await Hive.openBox('settings');
    
    // Open themes box
    await Hive.openBox('themes');
  }

  static Future<void> closeBoxes() async {
    await Hive.close();
  }

  static Future<void> clearAllData() async {
    await Hive.deleteBoxFromDisk('notes');
    await Hive.deleteBoxFromDisk('settings');
    await Hive.deleteBoxFromDisk('themes');
    await _openBoxes();
  }

  // Box getters
  static Box<NoteModel> get notesBox => Hive.box<NoteModel>('notes');
  static Box get settingsBox => Hive.box('settings');
  static Box get themesBox => Hive.box('themes');

  // Backup and Restore
  static Future<Map<String, dynamic>> exportData() async {
    final notes = notesBox.values.map((note) => note.toJson()).toList();
    final settings = Map<String, dynamic>.from(settingsBox.toMap());
    final themes = Map<String, dynamic>.from(themesBox.toMap());

    return {
      'notes': notes,
      'settings': settings,
      'themes': themes,
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  static Future<void> importData(Map<String, dynamic> data) async {
    try {
      // Clear existing data
      await notesBox.clear();
      await settingsBox.clear();
      await themesBox.clear();

      // Import notes
      final notesData = data['notes'] as List<dynamic>?;
      if (notesData != null) {
        for (final noteData in notesData) {
          final note = NoteModel.fromJson(Map<String, dynamic>.from(noteData));
          await notesBox.put(note.id, note);
        }
      }

      // Import settings
      final settingsData = data['settings'] as Map<String, dynamic>?;
      if (settingsData != null) {
        for (final entry in settingsData.entries) {
          await settingsBox.put(entry.key, entry.value);
        }
      }

      // Import themes
      final themesData = data['themes'] as Map<String, dynamic>?;
      if (themesData != null) {
        for (final entry in themesData.entries) {
          await themesBox.put(entry.key, entry.value);
        }
      }
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }

  // Statistics
  static Map<String, dynamic> getStatistics() {
    final notes = notesBox.values.toList();
    final pinnedCount = notes.where((note) => note.isPinned).length;
    final bookmarkedCount = notes.where((note) => note.isBookmarked).length;
    final totalNotes = notes.length;
    
    // Count tags
    final allTags = <String, int>{};
    for (final note in notes) {
      for (final tag in note.tags) {
        allTags[tag] = (allTags[tag] ?? 0) + 1;
      }
    }

    return {
      'totalNotes': totalNotes,
      'pinnedNotes': pinnedCount,
      'bookmarkedNotes': bookmarkedCount,
      'totalTags': allTags.length,
      'tagDistribution': allTags,
      'lastUpdated': notes.isNotEmpty 
          ? notes.map((n) => n.updatedAt).reduce((a, b) => a.isAfter(b) ? a : b).toIso8601String()
          : null,
    };
  }

  // Maintenance
  static Future<void> optimizeDatabase() async {
    // Compact the database
    await Hive.compact();
  }

  static Future<void> validateData() async {
    final notes = notesBox.values.toList();
    final corruptedNotes = <String>[];
    
    for (final note in notes) {
      try {
        // Validate note structure
        if (note.id.isEmpty || note.title.isEmpty) {
          corruptedNotes.add(note.id);
        }
      } catch (e) {
        corruptedNotes.add(note.id);
      }
    }

    if (corruptedNotes.isNotEmpty) {
      // Remove corrupted notes
      for (final noteId in corruptedNotes) {
        await notesBox.delete(noteId);
      }
    }
  }
}
