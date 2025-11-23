import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notely/core/animations.dart';
import 'package:notely/core/styles.dart';
import 'package:notely/models/note_model.dart';
import 'package:notely/providers/notes_provider.dart';
import 'package:notely/providers/theme_provider.dart';
import 'package:notely/widgets/note_card.dart';
import 'package:notely/screens/editor/editor_screen.dart';
import 'package:notely/screens/bookmarks/bookmarks_screen.dart';
import 'package:notely/screens/settings/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fabController;
  late AnimationController _searchController;
  late Animation<double> _fabScale;
  late Animation<Offset> _searchSlide;
  
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupListeners();
  }

  void _initializeAnimations() {
    _fabController = AnimationController(
      duration: AppAnimations.mediumDuration,
      vsync: this,
    );

    _searchController = AnimationController(
      duration: AppAnimations.mediumDuration,
      vsync: this,
    );

    _fabScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    ));

    _searchSlide = Tween<Offset>(
      begin: const Offset(0.0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _searchController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _fabController.forward();
    _searchController.forward();
  }

  void _setupListeners() {
    _searchController.addListener(() {
      ref.read(notesProvider.notifier).setSearchQuery(_searchController.text);
    });

    _scrollController.addListener(() {
      if (_scrollController.offset > 100) {
        _searchFocusNode.unfocus();
      }
    });
  }

  @override
  void dispose() {
    _fabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notesState = ref.watch(notesProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            snap: true,
            elevation: 0,
            backgroundColor: colorScheme.background,
            surfaceTintColor: Colors.transparent,
            title: Hero(
              tag: AppAnimations.heroAppBar,
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colorScheme.primary, colorScheme.secondary],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.note_alt_rounded,
                      size: 18,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: AppStyles.sm),
                  Text(
                    'Notely',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // View toggle
              IconButton(
                onPressed: () {
                  ref.read(notesProvider.notifier).toggleViewMode();
                },
                icon: Icon(
                  notesState.isGridView ? Icons.view_list : Icons.grid_view,
                  color: colorScheme.onSurface,
                ),
              ),
              // Bookmarks
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    AppAnimations.slideRoute(
                      child: const BookmarksScreen(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.bookmark_rounded,
                  color: colorScheme.onSurface,
                ),
              ),
              // Settings
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    AppAnimations.slideRoute(
                      child: const SettingsScreen(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.settings_rounded,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: AppStyles.sm),
            ],
          ),

          // Search and Filters
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _searchSlide,
              builder: (context, child) {
                return SlideTransition(
                  position: _searchSlide,
                  child: Padding(
                    padding: AppStyles.screenPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search bar
                        TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          decoration: AppStyles.searchInputDecoration(
                            context,
                            hint: 'Search notes...',
                          ),
                        ),
                        const SizedBox(height: AppStyles.md),

                        // Filter chips
                        _buildFilterChips(notesState),
                        const SizedBox(height: AppStyles.lg),

                        // Stats row
                        _buildStatsRow(notesState),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Notes Grid/List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppStyles.lg),
            sliver: notesState.isLoading
                ? _buildLoadingState()
                : notesState.error != null
                    ? _buildErrorState(notesState.error!)
                    : notesState.filteredNotes.isEmpty
                        ? _buildEmptyState()
                        : notesState.isGridView
                            ? _buildNotesGrid(notesState.filteredNotes)
                            : _buildNotesList(notesState.filteredNotes),
          ),

          // Bottom padding
          const SliverPadding(
            padding: EdgeInsets.only(bottom: 100),
          ),
        ],
      ),

      // Floating Action Button
      floatingActionButton: AnimatedBuilder(
        animation: _fabScale,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabScale.value,
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  AppAnimations.slideRoute(
                    child: const EditorScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('New Note'),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              elevation: 4,
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChips(notesState) {
    final allTags = ref.read(allTagsProvider);
    final selectedTag = ref.read(selectedTagProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // All notes chip
          FilterChip(
            label: const Text('All'),
            selected: selectedTag == null,
            onSelected: (selected) {
              if (selected) {
                ref.read(notesProvider.notifier).setSelectedTag(null);
              }
            },
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            checkmarkColor: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: AppStyles.sm),

          // Tag chips
          ...allTags.map((tag) {
            return Padding(
              padding: const EdgeInsets.only(right: AppStyles.sm),
              child: FilterChip(
                label: Text(tag),
                selected: selectedTag == tag,
                onSelected: (selected) {
                  if (selected) {
                    ref.read(notesProvider.notifier).setSelectedTag(tag);
                  }
                },
                backgroundColor: Theme.of(context).colorScheme.surface,
                selectedColor: _getTagColor(tag).withOpacity(0.2),
                checkmarkColor: _getTagColor(tag),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatsRow(notesState) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        _StatItem(
          label: 'Total',
          value: notesState.notes.length.toString(),
          icon: Icons.note_rounded,
          color: colorScheme.primary,
        ),
        const SizedBox(width: AppStyles.lg),
        _StatItem(
          label: 'Pinned',
          value: notesState.pinnedCount.toString(),
          icon: Icons.push_pin_rounded,
          color: colorScheme.secondary,
        ),
        const SizedBox(width: AppStyles.lg),
        _StatItem(
          label: 'Bookmarked',
          value: notesState.bookmarkedCount.toString(),
          icon: Icons.bookmark_rounded,
          color: colorScheme.tertiary,
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppStyles.md,
        mainAxisSpacing: AppStyles.md,
        childAspectRatio: 0.8,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: AppStyles.mdRadius,
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        childCount: 6,
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: AppStyles.xlPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: AppStyles.md),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppStyles.sm),
              Text(
                error,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppStyles.lg),
              ElevatedButton(
                onPressed: () {
                  ref.read(notesProvider.notifier).clearError();
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasSearchQuery = ref.read(searchQueryProvider).isNotEmpty;
    final hasTagFilter = ref.read(selectedTagProvider) != null;

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
                  hasSearchQuery || hasTagFilter
                      ? Icons.search_off_rounded
                      : Icons.note_add_rounded,
                  size: 60,
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: AppStyles.lg),
              Text(
                hasSearchQuery || hasTagFilter
                    ? 'No notes found'
                    : 'No notes yet',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: AppStyles.sm),
              Text(
                hasSearchQuery || hasTagFilter
                    ? 'Try adjusting your filters or search query'
                    : 'Create your first note to get started',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
              if (!hasSearchQuery && !hasTagFilter) ...[
                const SizedBox(height: AppStyles.lg),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      AppAnimations.slideRoute(
                        child: const EditorScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Create Note'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotesGrid(List<NoteModel> notes) {
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
            isSelected: ref.watch(notesProvider).selectedNotes.contains(note.id),
            onTap: () {
              if (ref.watch(notesProvider).hasSelection) {
                ref.read(notesProvider.notifier).toggleNoteSelection(note.id);
              }
            },
            onLongPress: () {
              ref.read(notesProvider.notifier).toggleNoteSelection(note.id);
            },
          );
        },
        childCount: notes.length,
      ),
    );
  }

  Widget _buildNotesList(List<NoteModel> notes) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final note = notes[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppStyles.md),
            child: NoteCard(
              note: note,
              index: index,
              isGridView: false,
              isSelected: ref.watch(notesProvider).selectedNotes.contains(note.id),
              onTap: () {
                if (ref.watch(notesProvider).hasSelection) {
                  ref.read(notesProvider.notifier).toggleNoteSelection(note.id);
                }
              },
              onLongPress: () {
                ref.read(notesProvider.notifier).toggleNoteSelection(note.id);
              },
            ),
          );
        },
        childCount: notes.length,
      ),
    );
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
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: AppStyles.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
