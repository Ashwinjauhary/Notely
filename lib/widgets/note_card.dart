import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notely/core/animations.dart';
import 'package:notely/core/styles.dart';
import 'package:notely/models/note_model.dart';
import 'package:notely/providers/notes_provider.dart';
import 'package:notely/screens/view_note/view_note_screen.dart';

class NoteCard extends ConsumerWidget {
  final NoteModel note;
  final int index;
  final bool isGridView;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;

  const NoteCard({
    super.key,
    required this.note,
    required this.index,
    this.isGridView = true,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final notesNotifier = ref.read(notesProvider.notifier);

    return Container(
      decoration: AppStyles.noteCardDecoration(
        context,
        color: _getNoteColor(note.color, context),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppStyles.mdRadius,
          onTap: onTap ?? () => _navigateToNote(context),
          onLongPress: onLongPress ?? () => _showQuickActions(context, ref),
          child: Stack(
            children: [
              // Main content
              Padding(
                padding: AppStyles.mdPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with indicators
                    Row(
                      children: [
                        // Pin indicator
                        if (note.isPinned)
                          Icon(
                            Icons.push_pin_rounded,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                        if (note.isPinned && note.isBookmarked) const SizedBox(width: 4),
                        // Bookmark indicator
                        if (note.isBookmarked)
                          Icon(
                            Icons.bookmark_rounded,
                            size: 16,
                            color: colorScheme.secondary,
                          ),
                        const Spacer(),
                        // Selection indicator
                        if (isSelected)
                          Icon(
                            Icons.check_circle_rounded,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                      ],
                    ),
                    const SizedBox(height: AppStyles.sm),

                    // Title
                    Text(
                      note.displayTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                      maxLines: isGridView ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppStyles.xs),

                    // Content preview
                    if (note.content.isNotEmpty)
                      Text(
                        note.displayContent,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                        maxLines: isGridView ? 3 : 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: AppStyles.sm),

                    // Tags
                    if (note.tags.isNotEmpty) ...[
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: note.tags.take(3).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getTagColor(tag).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tag,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: _getTagColor(tag),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      if (note.tags.length > 3)
                        Text(
                          '+${note.tags.length - 3}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                            fontSize: 10,
                          ),
                        ),
                      const SizedBox(height: AppStyles.sm),
                    ],

                    // Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDate(note.updatedAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                            fontSize: 10,
                          ),
                        ),
                        // Quick action buttons
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _QuickActionButton(
                              icon: note.isPinned
                                  ? Icons.push_pin_rounded
                                  : Icons.push_pin_outlined,
                              onTap: () => notesNotifier.togglePin(note),
                              isActive: note.isPinned,
                            ),
                            const SizedBox(width: 4),
                            _QuickActionButton(
                              icon: note.isBookmarked
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              onTap: () => notesNotifier.toggleBookmark(note),
                              isActive: note.isBookmarked,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Selection overlay
              if (isSelected)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: AppStyles.mdRadius,
                      border: Border.all(
                        color: colorScheme.primary,
                        width: 2,
                      ),
                      color: colorScheme.primary.withOpacity(0.1),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .scale(
          duration: 300.ms,
          delay: Duration(milliseconds: index * 50),
          curve: Curves.easeOutCubic,
          begin: const Offset(0.9, 0.9),
          end: const Offset(1.0, 1.0),
        )
        .fadeIn(
          duration: 400.ms,
          delay: Duration(milliseconds: index * 50),
        )
        .slideY(
          duration: 400.ms,
          delay: Duration(milliseconds: index * 50),
          begin: 0.1,
          curve: Curves.easeOutCubic,
        );
  }

  Color _getNoteColor(String colorHex, BuildContext context) {
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
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _navigateToNote(BuildContext context) {
    Navigator.of(context).push(
      AppAnimations.fadeRoute(
        child: ViewNoteScreen(note: note),
      ),
    );
  }

  void _showQuickActions(BuildContext context, WidgetRef ref) {
    final notesNotifier = ref.read(notesProvider.notifier);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
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
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: AppStyles.mdPadding,
              child: Column(
                children: [
                  // Note title
                  Text(
                    note.displayTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppStyles.lg),

                  // Quick actions
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    childAspectRatio: 1,
                    mainAxisSpacing: AppStyles.md,
                    crossAxisSpacing: AppStyles.md,
                    children: [
                      _QuickActionTile(
                        icon: note.isPinned
                            ? Icons.push_pin_rounded
                            : Icons.push_pin_outlined,
                        label: 'Pin',
                        onTap: () {
                          notesNotifier.togglePin(note);
                          Navigator.pop(context);
                        },
                        isActive: note.isPinned,
                      ),
                      _QuickActionTile(
                        icon: note.isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        label: 'Bookmark',
                        onTap: () {
                          notesNotifier.toggleBookmark(note);
                          Navigator.pop(context);
                        },
                        isActive: note.isBookmarked,
                      ),
                      _QuickActionTile(
                        icon: Icons.edit_rounded,
                        label: 'Edit',
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to editor
                        },
                      ),
                      _QuickActionTile(
                        icon: Icons.delete_rounded,
                        label: 'Delete',
                        onTap: () {
                          Navigator.pop(context);
                          _showDeleteDialog(context, ref);
                        },
                        isDanger: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppStyles.lg),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "${note.displayTitle}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(notesProvider.notifier).deleteNote(note.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  const _QuickActionButton({
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isActive
              ? colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isActive ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final bool isDanger;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDanger
                  ? Colors.red.withOpacity(0.1)
                  : isActive
                      ? colorScheme.primary.withOpacity(0.1)
                      : colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24,
              color: isDanger
                  ? Colors.red
                  : isActive
                      ? colorScheme.primary
                      : colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDanger
                  ? Colors.red
                  : isActive
                      ? colorScheme.primary
                      : colorScheme.onSurface,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
