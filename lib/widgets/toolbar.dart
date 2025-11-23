import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:notely/core/styles.dart';

class RichTextToolbar extends StatelessWidget {
  final QuillController controller;
  final bool isExpanded;
  final VoidCallback? onToggleExpanded;

  const RichTextToolbar({
    super.key,
    required this.controller,
    this.isExpanded = false,
    this.onToggleExpanded,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppStyles.mdRadius,
        boxShadow: AppStyles.lightShadow,
      ),
      child: Column(
        children: [
          // Main toolbar
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppStyles.sm,
              vertical: AppStyles.xs,
            ),
            child: Row(
              children: [
                // Text formatting
                _ToolbarButton(
                  icon: Icons.format_bold_rounded,
                  isActive: controller.getSelectionStyle().attributes.containsKey(Attribute.bold.key),
                  onPressed: () => _toggleAttribute(Attribute.bold),
                ),
                _ToolbarButton(
                  icon: Icons.format_italic_rounded,
                  isActive: controller.getSelectionStyle().attributes.containsKey(Attribute.italic.key),
                  onPressed: () => _toggleAttribute(Attribute.italic),
                ),
                _ToolbarButton(
                  icon: Icons.format_underlined_rounded,
                  isActive: controller.getSelectionStyle().attributes.containsKey(Attribute.underline.key),
                  onPressed: () => _toggleAttribute(Attribute.underline),
                ),
                _ToolbarButton(
                  icon: Icons.format_strikethrough_rounded,
                  isActive: controller.getSelectionStyle().attributes.containsKey(Attribute.strikeThrough.key),
                  onPressed: () => _toggleAttribute(Attribute.strikeThrough),
                ),
                
                const VerticalDivider(width: AppStyles.sm),
                
                // Text color
                _ColorButton(
                  icon: Icons.format_color_text_rounded,
                  onPressed: () => _showColorPicker(context, isBackground: false),
                ),
                
                // Background color
                _ColorButton(
                  icon: Icons.format_color_fill_rounded,
                  onPressed: () => _showColorPicker(context, isBackground: true),
                ),
                
                const VerticalDivider(width: AppStyles.sm),
                
                // Alignment
                _ToolbarButton(
                  icon: Icons.format_align_left_rounded,
                  isActive: controller.getSelectionStyle().attributes[Attribute.align.key]?.value == 'left',
                  onPressed: () => _setAlignment('left'),
                ),
                _ToolbarButton(
                  icon: Icons.format_align_center_rounded,
                  isActive: controller.getSelectionStyle().attributes[Attribute.align.key]?.value == 'center',
                  onPressed: () => _setAlignment('center'),
                ),
                _ToolbarButton(
                  icon: Icons.format_align_right_rounded,
                  isActive: controller.getSelectionStyle().attributes[Attribute.align.key]?.value == 'right',
                  onPressed: () => _setAlignment('right'),
                ),
                
                const VerticalDivider(width: AppStyles.sm),
                
                // Lists
                _ToolbarButton(
                  icon: Icons.format_list_bulleted_rounded,
                  isActive: controller.getSelectionStyle().attributes.containsKey(Attribute.ul.key),
                  onPressed: () => _toggleAttribute(Attribute.ul),
                ),
                _ToolbarButton(
                  icon: Icons.format_list_numbered_rounded,
                  isActive: controller.getSelectionStyle().attributes.containsKey(Attribute.ol.key),
                  onPressed: () => _toggleAttribute(Attribute.ol),
                ),
                _ToolbarButton(
                  icon: Icons.checklist_rounded,
                  isActive: controller.getSelectionStyle().attributes.containsKey(Attribute.checked.key),
                  onPressed: () => _toggleAttribute(Attribute.checked),
                ),
                
                const Spacer(),
                
                // Expand/Collapse
                IconButton(
                  onPressed: onToggleExpanded,
                  icon: Icon(
                    isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          
          // Expanded toolbar
          if (isExpanded)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppStyles.sm,
                vertical: AppStyles.xs,
              ),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Heading styles
                  _HeadingButton(
                    label: 'H1',
                    isActive: controller.getSelectionStyle().attributes.containsKey(Attribute.h1.key),
                    onPressed: () => _toggleAttribute(Attribute.h1),
                  ),
                  _HeadingButton(
                    label: 'H2',
                    isActive: controller.getSelectionStyle().attributes.containsKey(Attribute.h2.key),
                    onPressed: () => _toggleAttribute(Attribute.h2),
                  ),
                  _HeadingButton(
                    label: 'H3',
                    isActive: controller.getSelectionStyle().attributes.containsKey(Attribute.h3.key),
                    onPressed: () => _toggleAttribute(Attribute.h3),
                  ),
                  
                  const VerticalDivider(width: AppStyles.sm),
                  
                  // Quote and code
                  _ToolbarButton(
                    icon: Icons.format_quote_rounded,
                    isActive: controller.getSelectionStyle().attributes.containsKey(Attribute.blockQuote.key),
                    onPressed: () => _toggleAttribute(Attribute.blockQuote),
                  ),
                  _ToolbarButton(
                    icon: Icons.code_rounded,
                    isActive: controller.getSelectionStyle().attributes.containsKey(Attribute.codeBlock.key),
                    onPressed: () => _toggleAttribute(Attribute.codeBlock),
                  ),
                  
                  const VerticalDivider(width: AppStyles.sm),
                  
                  // Clear formatting
                  _ToolbarButton(
                    icon: Icons.format_clear_rounded,
                    onPressed: _clearFormatting,
                  ),
                  
                  const Spacer(),
                  
                  // Undo/Redo
                  IconButton(
                    onPressed: controller.hasUndo ? () => controller.undo() : null,
                    icon: const Icon(Icons.undo_rounded),
                  ),
                  IconButton(
                    onPressed: controller.hasRedo ? () => controller.redo() : null,
                    icon: const Icon(Icons.redo_rounded),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _toggleAttribute(Attribute attribute) {
    final format = controller.getSelectionStyle();
    if (format.attributes.containsKey(attribute.key)) {
      controller.formatSelection(Attribute.clone(attribute, null));
    } else {
      controller.formatSelection(attribute);
    }
  }

  void _setAlignment(String alignment) {
    controller.formatSelection(Attribute.clone(Attribute.align, alignment));
  }

  void _clearFormatting() {
    controller.formatSelection(Attribute.clone(Attribute.bold, null));
    controller.formatSelection(Attribute.clone(Attribute.italic, null));
    controller.formatSelection(Attribute.clone(Attribute.underline, null));
    controller.formatSelection(Attribute.clone(Attribute.strikeThrough, null));
    controller.formatSelection(Attribute.clone(Attribute.color, null));
    controller.formatSelection(Attribute.clone(Attribute.background, null));
  }

  void _showColorPicker(BuildContext context, {required bool isBackground}) {
    final colors = [
      Colors.black,
      Colors.white,
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.cyan,
      Colors.pink,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isBackground ? 'Background Color' : 'Text Color'),
        content: SizedBox(
          width: 200,
          height: 100,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 1,
            ),
            itemCount: colors.length,
            itemBuilder: (context, index) {
              final color = colors[index];
              return InkWell(
                onTap: () {
                  if (isBackground) {
                    controller.formatSelection(Attribute.clone(Attribute.background, color.value));
                  } else {
                    controller.formatSelection(Attribute.clone(Attribute.color, color.value));
                  }
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onPressed;

  const _ToolbarButton({
    required this.icon,
    required this.onPressed,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 20,
        color: isActive ? colorScheme.primary : colorScheme.onSurface,
      ),
      style: IconButton.styleFrom(
        backgroundColor: isActive ? colorScheme.primary.withOpacity(0.1) : null,
        foregroundColor: isActive ? colorScheme.primary : colorScheme.onSurface,
      ),
    );
  }
}

class _HeadingButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _HeadingButton({
    required this.label,
    required this.onPressed,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isActive ? colorScheme.primary.withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isActive ? colorScheme.primary : colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ColorButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return IconButton(
      onPressed: onPressed,
      icon: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary,
              colorScheme.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          icon,
          size: 16,
          color: colorScheme.onPrimary,
        ),
      ),
    );
  }
}

// Floating toolbar for quick actions
class FloatingToolbar extends StatelessWidget {
  final QuillController controller;

  const FloatingToolbar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppStyles.mediumShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _FloatingButton(
            icon: Icons.format_bold_rounded,
            onPressed: () => _toggleAttribute(Attribute.bold),
          ),
          _FloatingButton(
            icon: Icons.format_italic_rounded,
            onPressed: () => _toggleAttribute(Attribute.italic),
          ),
          _FloatingButton(
            icon: Icons.format_underlined_rounded,
            onPressed: () => _toggleAttribute(Attribute.underline),
          ),
          Container(
            width: 1,
            height: 24,
            color: colorScheme.outline.withOpacity(0.2),
          ),
          _FloatingButton(
            icon: Icons.format_list_bulleted_rounded,
            onPressed: () => _toggleAttribute(Attribute.ul),
          ),
          _FloatingButton(
            icon: Icons.format_list_numbered_rounded,
            onPressed: () => _toggleAttribute(Attribute.ol),
          ),
        ],
      ),
    );
  }

  void _toggleAttribute(Attribute attribute) {
    final format = controller.getSelectionStyle();
    if (format.attributes.containsKey(attribute.key)) {
      controller.formatSelection(Attribute.clone(attribute, null));
    } else {
      controller.formatSelection(attribute);
    }
  }
}

class _FloatingButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _FloatingButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 18,
        color: colorScheme.onSurface,
      ),
      style: IconButton.styleFrom(
        minimumSize: const Size(40, 40),
      ),
    );
  }
}
