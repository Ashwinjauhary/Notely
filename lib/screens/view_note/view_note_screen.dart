import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notely/core/animations.dart';
import 'package:notely/core/styles.dart';
import 'package:notely/models/note_model.dart';
import 'package:notely/providers/notes_provider.dart';
import 'package:notely/screens/editor/editor_screen.dart';

class ViewNoteScreen extends ConsumerStatefulWidget {
  final NoteModel note;

  const ViewNoteScreen({super.key, required this.note});

  @override
  ConsumerState<ViewNoteScreen> createState() => _ViewNoteScreenState();
}

class _ViewNoteScreenState extends ConsumerState<ViewNoteScreen>
    with TickerProviderStateMixin {
  late QuillController _controller;
  late AnimationController _fabController;
  late AnimationController _contentController;
  late Animation<double> _fabScale;
  late Animation<Offset> _contentSlide;
  
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
    _initializeAnimations();
  }

  void _initializeController() {
    try {
      List<dynamic> contentList;
      if (widget.note.content.startsWith('[')) {
        contentList = jsonDecode(widget.note.content);
      } else {
        contentList = [{"insert": widget.note.content}];
      }
      _controller = QuillController(
        document: Document.fromJson(contentList),
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (e) {
      // Fallback to plain text document if parsing fails
      _controller = QuillController(
        document: Document()..insert(0, widget.note.content),
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
  }

  void _initializeAnimations() {
    _fabController = AnimationController(
      duration: AppAnimations.mediumDuration,
      vsync: this,
    );

    _contentController = AnimationController(
      duration: AppAnimations.slowDuration,
      vsync: this,
    );

    _fabScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    ));

    _contentSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    ));

    _fabController.forward();
    _contentController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _fabController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            elevation: 0,
            backgroundColor: colorScheme.background,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.note.displayTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              titlePadding: const EdgeInsets.only(
                left: AppStyles.lg,
                bottom: AppStyles.md,
              ),
            ),
            actions: [
              // Pin button
              IconButton(
                onPressed: () {
                  ref.read(notesProvider.notifier).togglePin(widget.note);
                },
                icon: Icon(
                  widget.note.isPinned
                      ? Icons.push_pin_rounded
                      : Icons.push_pin_outlined,
                  color: widget.note.isPinned ? colorScheme.primary : colorScheme.onSurface,
                ),
              ),
              // Bookmark button
              IconButton(
                onPressed: () {
                  ref.read(notesProvider.notifier).toggleBookmark(widget.note);
                },
                icon: Icon(
                  widget.note.isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: widget.note.isBookmarked ? colorScheme.secondary : colorScheme.onSurface,
                ),
              ),
              // More options
              IconButton(
                onPressed: _showMoreOptions,
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: AppStyles.sm),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _contentSlide,
              builder: (context, child) {
                return SlideTransition(
                  position: _contentSlide,
                  child: Padding(
                    padding: AppStyles.screenPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Metadata
                        _buildMetadataRow(),
                        const SizedBox(height: AppStyles.lg),

                        // Tags
                        if (widget.note.tags.isNotEmpty) ...[
                          _buildTagsRow(),
                          const SizedBox(height: AppStyles.lg),
                        ],

                        // Content
                        _buildContent(),
                        const SizedBox(height: AppStyles.xxl),
                      ],
                    ),
                  ),
                );
              },
            ),
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
              onPressed: _navigateToEdit,
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Edit'),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              elevation: 4,
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetadataRow() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        // Color indicator
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: _getNoteColor(widget.note.color),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: AppStyles.sm),

        // Created date
        Icon(
          Icons.schedule_rounded,
          size: 16,
          color: colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 4),
        Text(
          'Created ${_formatDate(widget.note.createdAt)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(width: AppStyles.md),

        // Modified date
        Icon(
          Icons.edit_calendar_rounded,
          size: 16,
          color: colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 4),
        Text(
          'Modified ${_formatDate(widget.note.updatedAt)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsRow() {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.note.tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: _getTagColor(tag).withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            tag,
            style: theme.textTheme.bodySmall?.copyWith(
              color: _getTagColor(tag),
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContent() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: AppStyles.lgPadding,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppStyles.lgRadius,
        boxShadow: theme.brightness == Brightness.dark 
            ? [] 
            : AppStyles.lightShadow,
      ),
      child: QuillEditor.basic(
        controller: _controller,
        configurations: QuillEditorConfigurations(
          controller: _controller,
          readOnly: true,
          customStyles: DefaultStyles(
            h1: DefaultStyles.h1.copyWith(
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            h2: DefaultStyles.h2.copyWith(
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            h3: DefaultStyles.h3.copyWith(
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            paragraph: DefaultStyles.paragraph.copyWith(
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: colorScheme.onSurface,
              ),
            ),
            quote: DefaultStyles.quote.copyWith(
              style: theme.textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
                color: colorScheme.onSurface.withOpacity(0.8),
              ),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: colorScheme.primary,
                    width: 4,
                  ),
                ),
              ),
            ),
            code: DefaultStyles.code.copyWith(
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                backgroundColor: colorScheme.surfaceVariant,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        scrollController: ScrollController(),
      ),
    );
  }

  void _navigateToEdit() {
    Navigator.of(context).push(
      AppAnimations.slideRoute(
        child: EditorScreen(note: widget.note),
      ),
    ).then((_) {
      // Refresh the note when returning from editor
      ref.read(notesProvider.notifier).clearError();
    });
  }

  void _showMoreOptions() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: AppStyles.mdPadding,
              child: Column(
                children: [
                  Text(
                    'Note Options',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppStyles.lg),
                  
                  // Pin/Unpin
                  ListTile(
                    leading: Icon(
                      widget.note.isPinned
                          ? Icons.push_pin_rounded
                          : Icons.push_pin_outlined,
                    ),
                    title: Text(widget.note.isPinned ? 'Unpin Note' : 'Pin Note'),
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(notesProvider.notifier).togglePin(widget.note);
                    },
                  ),
                  
                  // Bookmark/Unbookmark
                  ListTile(
                    leading: Icon(
                      widget.note.isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                    ),
                    title: Text(widget.note.isBookmarked ? 'Remove Bookmark' : 'Bookmark Note'),
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(notesProvider.notifier).toggleBookmark(widget.note);
                    },
                  ),
                  
                  // Share
                  ListTile(
                    leading: const Icon(Icons.share_rounded),
                    title: const Text('Share Note'),
                    onTap: () {
                      Navigator.pop(context);
                      _shareNote();
                    },
                  ),
                  
                  // Export
                  ListTile(
                    leading: const Icon(Icons.download_rounded),
                    title: const Text('Export Note'),
                    onTap: () {
                      Navigator.pop(context);
                      _exportNote();
                    },
                  ),
                  
                  // Duplicate
                  ListTile(
                    leading: const Icon(Icons.copy_rounded),
                    title: const Text('Duplicate Note'),
                    onTap: () {
                      Navigator.pop(context);
                      _duplicateNote();
                    },
                  ),
                  
                  // Delete
                  ListTile(
                    leading: const Icon(Icons.delete_rounded),
                    title: const Text('Delete Note'),
                    textColor: Colors.red,
                    iconColor: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      _showDeleteDialog();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareNote() {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon!'),
      ),
    );
  }

  void _exportNote() {
    // Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export functionality coming soon!'),
      ),
    );
  }

  void _duplicateNote() async {
    try {
      await ref.read(notesProvider.notifier).createNote(
        title: '${widget.note.title} (Copy)',
        content: widget.note.content,
        tags: List.from(widget.note.tags),
        color: widget.note.color,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note duplicated successfully!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to duplicate note: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "${widget.note.displayTitle}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(notesProvider.notifier).deleteNote(widget.note.id);
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close view screen
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _getNoteColor(String colorHex) {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Theme.of(context).cardColor;
    }
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'just now';
        }
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }
}
