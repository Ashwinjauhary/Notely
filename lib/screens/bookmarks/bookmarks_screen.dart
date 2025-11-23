import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notely/core/animations.dart';
import 'package:notely/core/styles.dart';
import 'package:notely/providers/notes_provider.dart';
import 'package:notely/widgets/note_card.dart';
import 'package:notely/screens/view_note/view_note_screen.dart';

class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _contentController;
  late Animation<Offset> _headerSlide;
  late Animation<double> _contentOpacity;
  
  String _searchQuery = '';
  String? _selectedTag;
  SortOption _sortOption = SortOption.dateModifiedDesc;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _headerController = AnimationController(
      duration: AppAnimations.mediumDuration,
      vsync: this,
    );

    _contentController = AnimationController(
      duration: AppAnimations.slowDuration,
      vsync: this,
    );

    _headerSlide = Tween<Offset>(
      begin: const Offset(0.0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    ));

    _contentOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeInOut,
    ));

    _headerController.forward();
    _contentController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bookmarkedNotes = ref.watch(bookmarkedNotesProvider);
    final allTags = ref.watch(allTagsProvider);

    // Filter and sort bookmarked notes
    var filteredNotes = bookmarkedNotes;
    
    if (_searchQuery.isNotEmpty) {
      filteredNotes = filteredNotes.where((note) => 
        note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        note.content.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    if (_selectedTag != null) {
      filteredNotes = filteredNotes.where((note) => note.hasTag(_selectedTag!)).toList();
    }

    // Sort notes
    filteredNotes = _sortNotes(filteredNotes);

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            snap: true,
            elevation: 0,
            backgroundColor: colorScheme.background,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            title: AnimatedBuilder(
              animation: _headerSlide,
              builder: (context, child) {
                return SlideTransition(
                  position: _headerSlide,
                  child: Row(
                    children: [
                      Icon(
                        Icons.bookmark_rounded,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: AppStyles.sm),
                      Text(
                        'Bookmarks',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            actions: [
              // Sort options
              PopupMenuButton<SortOption>(
                icon: Icon(
                  Icons.sort_rounded,
                  color: colorScheme.onSurface,
                ),
                onSelected: (option) {
                  setState(() {
                    _sortOption = option;
                  });
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: SortOption.dateModifiedDesc,
                    child: Text('Recently Modified'),
                  ),
                  const PopupMenuItem(
                    value: SortOption.dateModifiedAsc,
                    child: Text('Oldest Modified'),
                  ),
                  const PopupMenuItem(
                    value: SortOption.dateCreatedDesc,
                    child: Text('Recently Created'),
                  ),
                  const PopupMenuItem(
                    value: SortOption.titleAsc,
                    child: Text('Title (A-Z)'),
                  ),
                  const PopupMenuItem(
                    value: SortOption.titleDesc,
                    child: Text('Title (Z-A)'),
                  ),
                ],
              ),
              const SizedBox(width: AppStyles.sm),
            ],
          ),

          // Search and Filters
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _contentOpacity,
              builder: (context, child) {
                return Opacity(
                  opacity: _contentOpacity.value,
                  child: Padding(
                    padding: AppStyles.screenPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search bar
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: AppStyles.searchInputDecoration(
                            context,
                            hint: 'Search bookmarks...',
                          ),
                        ),
                        const SizedBox(height: AppStyles.md),

                        // Stats and filters
                        Row(
                          children: [
                            // Stats
                            Text(
                              '${filteredNotes.length} bookmark${filteredNotes.length == 1 ? '' : 's'}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                              ),
                            ),
                            const Spacer(),
                            // Clear filters
                            if (_searchQuery.isNotEmpty || _selectedTag != null)
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = '';
                                    _selectedTag = null;
                                  });
                                },
                                icon: const Icon(Icons.clear_rounded, size: 16),
                                label: const Text('Clear'),
                                style: TextButton.styleFrom(
                                  foregroundColor: colorScheme.primary,
                                ),
                              ),
                    ],
                  ),
                  const SizedBox(height: AppStyles.md),

                  // Tag filters
                  if (allTags.isNotEmpty) ...[
                    Text(
                      'Filter by tag:',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: AppStyles.sm),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // All tags chip
                          FilterChip(
                            label: const Text('All'),
                            selected: _selectedTag == null,
                            onSelected: (selected) {
                              setState(() {
                                _selectedTag = selected ? null : _selectedTag;
                              });
                            },
                            backgroundColor: colorScheme.surface,
                            selectedColor: colorScheme.primary.withOpacity(0.2),
                            checkmarkColor: colorScheme.primary,
                          ),
                          const SizedBox(width: AppStyles.sm),
                          // Tag chips
                          ...allTags.map((tag) {
                            final hasBookmarkedTag = bookmarkedNotes.any((note) => note.hasTag(tag));
                            if (!hasBookmarkedTag) return const SizedBox.shrink();
                            
                            return Padding(
                              padding: const EdgeInsets.only(right: AppStyles.sm),
                              child: FilterChip(
                                label: Text(tag),
                                selected: _selectedTag == tag,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedTag = selected ? tag : null;
                                  });
                                },
                                backgroundColor: colorScheme.surface,
                                selectedColor: _getTagColor(tag).withOpacity(0.2),
                                checkmarkColor: _getTagColor(tag),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppStyles.lg),
                  ],
                ],
              ),
            );
          },
        ),
      ),

      // Bookmarks Grid/List
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppStyles.lg),
        sliver: filteredNotes.isEmpty
            ? _buildEmptyState()
            : _buildBookmarksGrid(filteredNotes),
      ),

      // Bottom padding
      const SliverPadding(
        padding: EdgeInsets.only(bottom: 100),
      ),
    ],
  ),
);
}

Widget _buildEmptyState() {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  return SliverToBoxAdapter(
    child: Center(
      child: Padding(
        padding: AppStyles.xlPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.bookmark_border_rounded,
                size: 60,
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: AppStyles.lg),
            Text(
              _searchQuery.isNotEmpty || _selectedTag != null
                  ? 'No bookmarks found'
                  : 'No bookmarks yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: AppStyles.sm),
            Text(
              _searchQuery.isNotEmpty || _selectedTag != null
                  ? 'Try adjusting your search or filters'
                  : 'Bookmark your important notes to see them here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildBookmarksGrid(List<NoteModel> notes) {
  return SliverGrid(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: AppStyles.md,
      mainAxisSpacing: AppStyles.md,
      childAspectRatio: 0.8,
    ),
    delegate: SliverChildBuilderDelegate(
      (context, index) {
        final note = notes[index];
        return NoteCard(
          note: note,
          index: index,
          isGridView: true,
          onTap: () {
            Navigator.of(context).push(
              AppAnimations.fadeRoute(
                child: ViewNoteScreen(note: note),
              ),
            );
          },
        );
      },
      childCount: notes.length,
    ),
  );
}

List<NoteModel> _sortNotes(List<NoteModel> notes) {
    final sortedNotes = List<NoteModel>.from(notes);

    switch (_sortOption) {
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

Color _getTagColor(String tag) {
  final tagColors = {
    'Work': const Color(0xFF3498DB),
    'Study': const Color(0xFF2ECC71),
    'Idea': const Color(0xFFF39C12),
    'Urgent': const Color(0xFFE74C3C),
    'Personal': const Color(0xFF9B59B6),
  };
  return tagColors[tag] ?? const Color(0xFF95A5A6);
}
