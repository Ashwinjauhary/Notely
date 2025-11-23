import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:notely/core/styles.dart';

class BlockEditor extends StatefulWidget {
  final QuillController controller;
  final Function()? onBlockAdded;
  final Function()? onBlockDeleted;

  const BlockEditor({
    super.key,
    required this.controller,
    this.onBlockAdded,
    this.onBlockDeleted,
  });

  @override
  State<BlockEditor> createState() => _BlockEditorState();
}

class _BlockEditorState extends State<BlockEditor> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppStyles.mdRadius,
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          // Editor toolbar
          _buildBlockToolbar(),
          
          // Editor content
          Expanded(
            child: QuillEditor.basic(
              controller: widget.controller,
              configurations: QuillEditorConfigurations(
                controller: widget.controller,
                readOnly: false,
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
          ),
        ],
      ),
    );
  }

  Widget _buildBlockToolbar() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppStyles.sm),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          // Block type selector
          PopupMenuButton<String>(
            icon: Icon(
              Icons.format_size_rounded,
              size: 20,
              color: colorScheme.onSurface,
            ),
            onSelected: _insertBlockType,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'heading1',
                child: Row(
                  children: [
                    Icon(Icons.title_rounded, size: 16),
                    SizedBox(width: 8),
                    Text('Heading 1'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'heading2',
                child: Row(
                  children: [
                    Icon(Icons.title_rounded, size: 16),
                    SizedBox(width: 8),
                    Text('Heading 2'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'heading3',
                child: Row(
                  children: [
                    Icon(Icons.title_rounded, size: 16),
                    SizedBox(width: 8),
                    Text('Heading 3'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'paragraph',
                child: Row(
                  children: [
                    Icon(Icons.text_fields_rounded, size: 16),
                    SizedBox(width: 8),
                    Text('Paragraph'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'quote',
                child: Row(
                  children: [
                    Icon(Icons.format_quote_rounded, size: 16),
                    SizedBox(width: 8),
                    Text('Quote'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'code',
                child: Row(
                  children: [
                    Icon(Icons.code_rounded, size: 16),
                    SizedBox(width: 8),
                    Text('Code'),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(width: AppStyles.sm),
          
          // List options
          PopupMenuButton<String>(
            icon: Icon(
              Icons.format_list_bulleted_rounded,
              size: 20,
              color: colorScheme.onSurface,
            ),
            onSelected: _insertListType,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'bullet',
                child: Row(
                  children: [
                    Icon(Icons.format_list_bulleted_rounded, size: 16),
                    SizedBox(width: 8),
                    Text('Bullet List'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'numbered',
                child: Row(
                  children: [
                    Icon(Icons.format_list_numbered_rounded, size: 16),
                    SizedBox(width: 8),
                    Text('Numbered List'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'checklist',
                child: Row(
                  children: [
                    Icon(Icons.checklist_rounded, size: 16),
                    SizedBox(width: 8),
                    Text('Checklist'),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(width: AppStyles.sm),
          
          // Divider
          IconButton(
            onPressed: _insertDivider,
            icon: Icon(
              Icons.horizontal_rule_rounded,
              size: 20,
              color: colorScheme.onSurface,
            ),
          ),
          
          const Spacer(),
          
          // Delete block
          IconButton(
            onPressed: widget.onBlockDeleted,
            icon: Icon(
              Icons.delete_rounded,
              size: 20,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  void _insertBlockType(String type) {
    switch (type) {
      case 'heading1':
        widget.controller.formatText(0, 0, Attribute.h1);
        break;
      case 'heading2':
        widget.controller.formatText(0, 0, Attribute.h2);
        break;
      case 'heading3':
        widget.controller.formatText(0, 0, Attribute.h3);
        break;
      case 'quote':
        widget.controller.formatText(0, 0, Attribute.blockQuote);
        break;
      case 'code':
        widget.controller.formatText(0, 0, Attribute.codeBlock);
        break;
    }
    widget.onBlockAdded?.call();
  }

  void _insertListType(String type) {
    switch (type) {
      case 'bullet':
        widget.controller.formatText(0, 0, Attribute.ul);
        break;
      case 'numbered':
        widget.controller.formatText(0, 0, Attribute.ol);
        break;
      case 'checklist':
        widget.controller.formatText(0, 0, Attribute.checked);
        break;
    }
    widget.onBlockAdded?.call();
  }

  void _insertDivider() {
    final index = widget.controller.selection.baseOffset;
    widget.controller.document.insert(index, '\n---\n');
    widget.onBlockAdded?.call();
  }
}
