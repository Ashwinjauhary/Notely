import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notely/core/animations.dart';
import 'package:notely/core/styles.dart';
import 'package:notely/models/note_model.dart';
import 'package:notely/providers/notes_provider.dart';
import 'package:notely/widgets/block_editor.dart';
import 'package:notely/widgets/toolbar.dart';

class EditorScreen extends ConsumerStatefulWidget {
  final NoteModel? note;

  const EditorScreen({super.key, this.note});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen>
    with TickerProviderStateMixin {
  late QuillController _controller;
  late TextEditingController _titleController;
  late FocusNode _titleFocusNode;
  late FocusNode _contentFocusNode;
  
  Timer? _autosaveTimer;
  bool _hasUnsavedChanges = false;
  String _selectedColor = '#FFFFFF';
  List<String> _tags = [];
  
  late AnimationController _toolbarController;
  late Animation<double> _toolbarOpacity;

  @override
  void initState() {
    super.initState();
    _initializeEditor();
    _initializeAnimations();
    _setupListeners();
    _startAutosave();
  }

  void _initializeEditor() {
    // Initialize Quill controller
    if (widget.note != null) {
      _controller = QuillController(
        document: Document.fromJson(widget.note!.content),
        selection: const TextSelection.collapsed(offset: 0),
      );
      _titleController = TextEditingController(text: widget.note!.title);
      _selectedColor = widget.note!.color;
      _tags = List.from(widget.note!.tags);
    } else {
      _controller = QuillController.basic();
      _titleController = TextEditingController();
    }

    _titleFocusNode = FocusNode();
    _contentFocusNode = FocusNode();
  }

  void _initializeAnimations() {
    _toolbarController = AnimationController(
      duration: AppAnimations.mediumDuration,
      vsync: this,
    );

    _toolbarOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _toolbarController,
      curve: Curves.easeInOut,
    ));

    _toolbarController.forward();
  }

  void _setupListeners() {
    _controller.addListener(_onContentChanged);
    _titleController.addListener(_onTitleChanged);
    
    _contentFocusNode.addListener(() {
      if (_contentFocusNode.hasFocus) {
        _toolbarController.forward();
      }
    });

    _titleFocusNode.addListener(() {
      if (_titleFocusNode.hasFocus) {
        _toolbarController.reverse();
      }
    });
  }

  void _onContentChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  void _onTitleChanged() {
    if (!_hasUnsavedChanges && _titleController.text.isNotEmpty) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  void _startAutosave() {
    _autosaveTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_hasUnsavedChanges) {
        _saveNote();
      }
    });
  }

  Future<void> _saveNote() async {
    if (_titleController.text.trim().isEmpty && _controller.document.isEmpty()) {
      return;
    }

    try {
      final title = _titleController.text.trim().isEmpty 
          ? 'Untitled Note' 
          : _titleController.text.trim();
      
      final content = _controller.document.toDelta().toJson();

      if (widget.note != null) {
        await ref.read(notesProvider.notifier).updateNote(
          widget.note!.copyWith(
            title: title,
            content: content,
            color: _selectedColor,
            tags: _tags,
          ),
        );
      } else {
        await ref.read(notesProvider.notifier).createNote(
          title: title,
          content: content,
          color: _selectedColor,
          tags: _tags,
        );
      }

      setState(() {
        _hasUnsavedChanges = false;
      });
    } catch (e) {
      // Handle save error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save note: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    _controller.dispose();
    _titleController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    _toolbarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Title input
          Padding(
            padding: const EdgeInsets.all(AppStyles.lg),
            child: TextField(
              controller: _titleController,
              focusNode: _titleFocusNode,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                hintText: 'Note Title',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              maxLines: null,
            ),
          ),

          // Tags and color
          _buildMetadataRow(),

          // Content editor
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppStyles.lg),
              child: QuillEditor.basic(
                controller: _controller,
                configurations: QuillEditorConfigurations(
                  controller: _controller,
                  autoFocus: false,
                  placeholder: 'Start typing...',
                  customStyles: DefaultStyles(
                    h1: DefaultStyles.h1.copyWith(
                      style: theme.textTheme.headlineLarge,
                    ),
                    h2: DefaultStyles.h2.copyWith(
                      style: theme.textTheme.headlineMedium,
                    ),
                    h3: DefaultStyles.h3.copyWith(
                      style: theme.textTheme.headlineSmall,
                    ),
                    paragraph: DefaultStyles.paragraph.copyWith(
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ),
                focusNode: _contentFocusNode,
                scrollController: ScrollController(),
              ),
            ),
          ),

          // Toolbar
          AnimatedBuilder(
            animation: _toolbarOpacity,
            builder: (context, child) {
              return Opacity(
                opacity: _toolbarOpacity.value,
                child: QuillToolbar.simple(
                  configurations: QuillToolbarSimpleConfigurations(
                    controller: _controller,
                    multiRowsDisplay: false,
                    toolbarIconAlignment: WrapAlignment.start,
                    showDividers: true,
                    showFontSize: true,
                    showBoldButton: true,
                    showItalicButton: true,
                    showUnderLineButton: true,
                    showStrikeThroughButton: true,
                    showClearFormat: true,
                    showLeftAlignment: false,
                    showCenterAlignment: false,
                    showRightAlignment: false,
                    showJustifyAlignment: false,
                    showDirection: false,
                    showCodeBlock: false,
                    showBlockQuote: false,
                    showListNumbers: true,
                    showListBullets: true,
                    showListCheck: true,
                    showIndent: false,
                    showLink: false,
                    showUndo: true,
                    showRedo: true,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActions(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      backgroundColor: colorScheme.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () async {
          if (_hasUnsavedChanges) {
            await _saveNote();
          }
          Navigator.of(context).pop();
        },
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      title: Text(
        _hasUnsavedChanges ? 'Editing*' : 'Editing',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      actions: [
        // Color picker
        PopupMenuButton<String>(
          icon: Icon(
            Icons.palette_rounded,
            color: colorScheme.onSurface,
          ),
          onSelected: (color) {
            setState(() {
              _selectedColor = color;
              _hasUnsavedChanges = true;
            });
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: '#FFFFFF', child: Text('Default')),
            const PopupMenuItem(value: '#FFF8E1', child: Text('Light Yellow')),
            const PopupMenuItem(value: '#E8F5E8', child: Text('Light Green')),
            const PopupMenuItem(value: '#FFF3E0', child: Text('Light Orange')),
            const PopupMenuItem(value: '#F3E5F5', child: Text('Light Purple')),
            const PopupMenuItem(value: '#E3F2FD', child: Text('Light Blue')),
            const PopupMenuItem(value: '#FFEBEE', child: Text('Light Red')),
            const PopupMenuItem(value: '#E0F2F1', child: Text('Light Teal')),
          ],
        ),
        // Tags
        IconButton(
          onPressed: _showTagDialog,
          icon: Icon(
            Icons.tag_rounded,
            color: colorScheme.onSurface,
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
    );
  }

  Widget _buildMetadataRow() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppStyles.lg),
      child: Row(
        children: [
          // Tags
          Expanded(
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: _tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getTagColor(tag).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tag,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getTagColor(tag),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _tags.remove(tag);
                            _hasUnsavedChanges = true;
                          });
                        },
                        child: Icon(
                          Icons.close_rounded,
                          size: 12,
                          color: _getTagColor(tag),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          // Add tag button
          IconButton(
            onPressed: _showTagDialog,
            icon: Icon(
              Icons.add_rounded,
              size: 20,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActions() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Save button
        FloatingActionButton.extended(
          onPressed: _saveNote,
          icon: const Icon(Icons.save_rounded),
          label: const Text('Save'),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
        const SizedBox(width: AppStyles.sm),
        // Quick actions
        FloatingActionButton(
          onPressed: _showQuickActions,
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          child: const Icon(Icons.more_horiz_rounded),
        ),
      ],
    );
  }

  void _showTagDialog() {
    final TextEditingController tagController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Tag'),
        content: TextField(
          controller: tagController,
          decoration: AppStyles.textInputDecoration(
            context,
            hint: 'Enter tag name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final tag = tagController.text.trim();
              if (tag.isNotEmpty && !_tags.contains(tag)) {
                setState(() {
                  _tags.add(tag);
                  _hasUnsavedChanges = true;
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
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
                  ListTile(
                    leading: const Icon(Icons.push_pin_rounded),
                    title: const Text('Pin Note'),
                    onTap: () {
                      Navigator.pop(context);
                      if (widget.note != null) {
                        ref.read(notesProvider.notifier).togglePin(widget.note!);
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.bookmark_rounded),
                    title: const Text('Bookmark Note'),
                    onTap: () {
                      Navigator.pop(context);
                      if (widget.note != null) {
                        ref.read(notesProvider.notifier).toggleBookmark(widget.note!);
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.share_rounded),
                    title: const Text('Share Note'),
                    onTap: () {
                      Navigator.pop(context);
                      // Implement share functionality
                    },
                  ),
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

  void _showQuickActions() {
    // Show quick actions for formatting
    _showMoreOptions();
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (widget.note != null) {
                ref.read(notesProvider.notifier).deleteNote(widget.note!.id);
              }
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close editor
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
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
