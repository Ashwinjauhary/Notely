import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'note_model.g.dart';

@HiveType(typeId: 0)
class NoteModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String content;
  
  @HiveField(3)
  List<String> tags;
  
  @HiveField(4)
  String color;
  
  @HiveField(5)
  bool isPinned;
  
  @HiveField(6)
  bool isBookmarked;
  
  @HiveField(7)
  DateTime createdAt;
  
  @HiveField(8)
  DateTime updatedAt;

  NoteModel({
    String? id,
    required this.title,
    required this.content,
    List<String>? tags,
    this.color = '#FFFFFF',
    this.isPinned = false,
    this.isBookmarked = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       tags = tags ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  NoteModel copyWith({
    String? title,
    String? content,
    List<String>? tags,
    String? color,
    bool? isPinned,
    bool? isBookmarked,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      color: color ?? this.color,
      isPinned: isPinned ?? this.isPinned,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Getters for convenience
  String get displayTitle => title.isEmpty ? 'Untitled Note' : title;
  String get displayContent {
    if (content.isEmpty) return '';
    // Strip HTML tags for preview
    String strippedContent = content.replaceAll(RegExp(r'<[^>]*>'), '');
    return strippedContent.length > 100 
        ? '${strippedContent.substring(0, 100)}...'
        : strippedContent;
  }

  // Search helpers
  bool matchesQuery(String query) {
    final lowerQuery = query.toLowerCase();
    return title.toLowerCase().contains(lowerQuery) ||
           content.toLowerCase().contains(lowerQuery) ||
           tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
  }

  bool hasTag(String tag) {
    return tags.contains(tag);
  }

  // Tag management
  void addTag(String tag) {
    if (!tags.contains(tag)) {
      tags.add(tag);
      updatedAt = DateTime.now();
    }
  }

  void removeTag(String tag) {
    tags.remove(tag);
    updatedAt = DateTime.now();
  }

  // Pin and bookmark helpers
  void togglePin() {
    isPinned = !isPinned;
    updatedAt = DateTime.now();
  }

  void toggleBookmark() {
    isBookmarked = !isBookmarked;
    updatedAt = DateTime.now();
  }

  // JSON serialization for export/import
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'tags': tags,
      'color': color,
      'isPinned': isPinned,
      'isBookmarked': isBookmarked,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      color: json['color'] ?? '#FFFFFF',
      isPinned: json['isPinned'] ?? false,
      isBookmarked: json['isBookmarked'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  @override
  String toString() {
    return 'NoteModel(id: $id, title: $title, tags: $tags, isPinned: $isPinned, isBookmarked: $isBookmarked)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NoteModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Extension for working with lists of notes
extension NoteListExtensions on List<NoteModel> {
  List<NoteModel> get pinnedNotes => where((note) => note.isPinned).toList();
  List<NoteModel> get bookmarkedNotes => where((note) => note.isBookmarked).toList();
  List<NoteModel> get regularNotes => where((note) => !note.isPinned).toList();

  List<NoteModel> sortByDate({bool descending = true}) {
    final sorted = List<NoteModel>.from(this);
    sorted.sort((a, b) {
      final comparison = a.updatedAt.compareTo(b.updatedAt);
      return descending ? -comparison : comparison;
    });
    return sorted;
  }

  List<NoteModel> sortByTitle({bool ascending = true}) {
    final sorted = List<NoteModel>.from(this);
    sorted.sort((a, b) {
      final comparison = a.title.toLowerCase().compareTo(b.title.toLowerCase());
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }

  List<NoteModel> filterByTag(String tag) {
    return where((note) => note.hasTag(tag)).toList();
  }

  List<NoteModel> searchNotes(String query) {
    if (query.isEmpty) return this;
    return where((note) => note.matchesQuery(query)).toList();
  }

  List<NoteModel> filterByDateRange(DateTime start, DateTime end) {
    return where((note) {
      return note.updatedAt.isAfter(start) && note.updatedAt.isBefore(end);
    }).toList();
  }
}
