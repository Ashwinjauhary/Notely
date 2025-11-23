import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notely/models/note_model.dart';
import 'package:notely/core/styles.dart';
import 'package:notely/screens/editor/editor_screen.dart';

class ViewNoteScreen extends ConsumerStatefulWidget {
  final NoteModel note;

  const ViewNoteScreen({
    super.key,
    required this.note,
  });

  @override
  ConsumerState<ViewNoteScreen> createState() => _ViewNoteScreenState();
}

class _ViewNoteScreenState extends ConsumerState<ViewNoteScreen>
    with TickerProviderStateMixin {
  late AnimationController _fabController;
  late AnimationController _contentController;
  late Animation<double> _fabAnimation;
  late Animation<Offset> _contentAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    ));

    _contentAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
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
    _fabController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.note.title.isEmpty ? 'Untitled Note' : widget.note.title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          // Pin button
          IconButton(
            onPressed: () {
              // Toggle pin functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pin functionality coming soon!')),
              );
            },
            icon: Icon(
              widget.note.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
              color: widget.note.isPinned ? colorScheme.primary : colorScheme.onSurface,
            ),
          ),
          // Bookmark button
          IconButton(
            onPressed: () {
              // Toggle bookmark functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bookmark functionality coming soon!')),
              );
            },
            icon: Icon(
              widget.note.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: widget.note.isBookmarked ? colorScheme.primary : colorScheme.onSurface,
            ),
          ),
          // More options
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: colorScheme.onSurface,
            ),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share_rounded, size: 16),
                    SizedBox(width: 8),
                    Text('Share'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download_rounded, size: 16),
                    SizedBox(width: 8),
                    Text('Export'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy_rounded, size: 16),
                    SizedBox(width: 8),
                    Text('Duplicate'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_rounded, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SlideTransition(
        position: _contentAnimation,
        child: SingleChildScrollView(
          padding: AppStyles.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Note metadata
              _buildMetadata(),
              const SizedBox(height: AppStyles.lg),
              
              // Tags
              if (widget.note.tags.isNotEmpty) ...[
                _buildTags(),
                const SizedBox(height: AppStyles.lg),
              ],
              
              // Content
              _buildContent(),
              const SizedBox(height: 100), // Bottom padding for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EditorScreen(note: widget.note),
              ),
            );
          },
          icon: const Icon(Icons.edit_rounded),
          label: const Text('Edit'),
        ),
      ),
    );
  }

  Widget _buildMetadata() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: AppStyles.mdPadding,
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: AppStyles.mdRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Color indicator
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _parseColor(widget.note.color),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: AppStyles.sm),
              Text(
                'Created: ${_formatDate(widget.note.createdAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppStyles.xs),
          Text(
            'Modified: ${_formatDate(widget.note.updatedAt)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Wrap(
      spacing: AppStyles.xs,
      runSpacing: AppStyles.xs,
      children: widget.note.tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppStyles.sm,
            vertical: AppStyles.xs,
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
      child: Text(
        widget.note.content,
        style: theme.textTheme.bodyLarge?.copyWith(
          height: 1.6,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'share':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Share functionality coming soon!')),
        );
        break;
      case 'export':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export functionality coming soon!')),
        );
        break;
      case 'duplicate':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Duplicate functionality coming soon!')),
        );
        break;
      case 'delete':
        _showDeleteDialog();
        break;
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to home
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Note deleted')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
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
    return '${date.day}/${date.month}/${date.year}';
  }
}
