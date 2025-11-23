import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notely/core/animations.dart';
import 'package:notely/core/styles.dart';
import 'package:notely/core/theme/app_theme.dart';
import 'package:notely/data/hive_adapters/hive_adapter.dart';
import 'package:notely/providers/theme_provider.dart';
import 'package:notely/providers/notes_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _contentController;
  late Animation<Offset> _headerSlide;
  late Animation<double> _contentOpacity;
  
  bool _isAutoTheme = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSettings();
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

  void _loadSettings() {
    _isAutoTheme = ref.read(autoThemeProvider);
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
    final currentTheme = ref.watch(appThemeProvider);
    final fontSize = ref.watch(fontSizeProvider);

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
                        Icons.settings_rounded,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: AppStyles.sm),
                      Text(
                        'Settings',
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
          ),

          // Settings Content
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
                        // Theme Settings
                        _buildSection(
                          title: 'Appearance',
                          icon: Icons.palette_rounded,
                          children: [
                            // Auto theme toggle
                            SwitchListTile(
                              title: const Text('Auto Theme'),
                              subtitle: const Text('Follow system theme'),
                              value: _isAutoTheme,
                              onChanged: (value) {
                                setState(() {
                                  _isAutoTheme = value;
                                });
                                ref.read(autoThemeProvider.notifier).setAutoMode(value);
                              },
                              secondary: Icon(
                                Icons.brightness_auto_rounded,
                                color: colorScheme.primary,
                              ),
                            ),
                            
                            // Theme selector
                            if (!_isAutoTheme) ...[
                              const SizedBox(height: AppStyles.sm),
                              ListTile(
                                title: const Text('Theme'),
                                subtitle: Text(_getThemeName(currentTheme)),
                                trailing: Icon(
                                  Icons.chevron_right_rounded,
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                                onTap: _showThemeSelector,
                                leading: Icon(
                                  Icons.color_lens_rounded,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                            
                            // Font size
                            ListTile(
                              title: const Text('Font Size'),
                              subtitle: Text('${(fontSize * 100).round()}%'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      ref.read(fontSizeProvider.notifier).decreaseFontSize();
                                    },
                                    icon: const Icon(Icons.remove_rounded),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      ref.read(fontSizeProvider.notifier).increaseFontSize();
                                    },
                                    icon: const Icon(Icons.add_rounded),
                                  ),
                                ],
                              ),
                              leading: Icon(
                                Icons.text_fields_rounded,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppStyles.lg),

                        // Data Management
                        _buildSection(
                          title: 'Data Management',
                          icon: Icons.storage_rounded,
                          children: [
                            ListTile(
                              title: const Text('Export Notes'),
                              subtitle: const Text('Export all notes as JSON'),
                              leading: Icon(
                                Icons.download_rounded,
                                color: colorScheme.primary,
                              ),
                              onTap: _exportNotes,
                            ),
                            ListTile(
                              title: const Text('Import Notes'),
                              subtitle: const Text('Import notes from backup'),
                              leading: Icon(
                                Icons.upload_rounded,
                                color: colorScheme.primary,
                              ),
                              onTap: _importNotes,
                            ),
                            ListTile(
                              title: const Text('Clear All Data'),
                              subtitle: const Text('Delete all notes and settings'),
                              leading: Icon(
                                Icons.delete_sweep_rounded,
                                color: Colors.red,
                              ),
                              onTap: _showClearDataDialog,
                            ),
                          ],
                        ),

                        const SizedBox(height: AppStyles.lg),

                        // App Info
                        _buildSection(
                          title: 'About',
                          icon: Icons.info_rounded,
                          children: [
                            ListTile(
                              title: const Text('Version'),
                              subtitle: const Text('1.0.0'),
                              leading: Icon(
                                Icons.info_outline_rounded,
                                color: colorScheme.primary,
                              ),
                            ),
                            ListTile(
                              title: const Text('Statistics'),
                              subtitle: const Text('View app statistics'),
                              trailing: Icon(
                                Icons.chevron_right_rounded,
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                              leading: Icon(
                                Icons.analytics_rounded,
                                color: colorScheme.primary,
                              ),
                              onTap: _showStatistics,
                            ),
                            ListTile(
                              title: const Text('Report Bug'),
                              subtitle: const Text('Report issues or suggest features'),
                              leading: Icon(
                                Icons.bug_report_rounded,
                                color: colorScheme.primary,
                              ),
                              onTap: _reportBug,
                            ),
                          ],
                        ),

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
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppStyles.lgRadius,
        boxShadow: theme.brightness == Brightness.dark 
            ? [] 
            : AppStyles.lightShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: AppStyles.lgPadding,
            child: Row(
              children: [
                Icon(
                  icon,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: AppStyles.sm),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          
          // Section content
          ...children,
        ],
      ),
    );
  }

  void _showThemeSelector() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentTheme = ref.watch(appThemeProvider);

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
                    'Select Theme',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppStyles.lg),
                  ...AppThemeType.values.map((themeType) {
                    final isSelected = currentTheme == themeType;
                    return ListTile(
                      title: Text(_getThemeName(themeType)),
                      subtitle: Text(_getThemeDescription(themeType)),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            colors: _getThemeColors(themeType),
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: colorScheme.primary,
                            )
                          : null,
                      onTap: () {
                        ref.read(appThemeProvider.notifier).setTheme(themeType);
                        Navigator.pop(context);
                      },
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _exportNotes() async {
    try {
      final data = await HiveAdapter.exportData();
      // In a real app, you would use file_picker to save this data
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Export functionality coming soon!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export notes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _importNotes() async {
    try {
      // In a real app, you would use file_picker to load data
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Import functionality coming soon!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to import notes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all notes and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await HiveAdapter.clearAllData();
                ref.read(notesProvider.notifier).clearSelection();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data cleared successfully'),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to clear data: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showStatistics() {
    final stats = ref.read(notesProvider.notifier).statistics;
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
        child: Padding(
          padding: AppStyles.lgPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Statistics',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: AppStyles.lg),
              _StatItem(
                label: 'Total Notes',
                value: stats['totalNotes'].toString(),
                icon: Icons.note_rounded,
                color: colorScheme.primary,
              ),
              const SizedBox(height: AppStyles.md),
              _StatItem(
                label: 'Pinned Notes',
                value: stats['pinnedNotes'].toString(),
                icon: Icons.push_pin_rounded,
                color: colorScheme.secondary,
              ),
              const SizedBox(height: AppStyles.md),
              _StatItem(
                label: 'Bookmarked Notes',
                value: stats['bookmarkedNotes'].toString(),
                icon: Icons.bookmark_rounded,
                color: colorScheme.tertiary,
              ),
              const SizedBox(height: AppStyles.md),
              _StatItem(
                label: 'Total Tags',
                value: stats['totalTags'].toString(),
                icon: Icons.tag_rounded,
                color: Colors.orange,
              ),
              if (stats['lastUpdated'] != null) ...[
                const SizedBox(height: AppStyles.md),
                Text(
                  'Last Updated: ${DateTime.parse(stats['lastUpdated']).toString().split('.')[0]}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                  ),
                ),
              ],
              const SizedBox(height: AppStyles.lg),
            ],
          ),
        ),
      ),
    );
  }

  void _reportBug() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bug reporting coming soon!'),
      ),
    );
  }

  String _getThemeName(AppThemeType theme) {
    switch (theme) {
      case AppThemeType.light:
        return 'Light';
      case AppThemeType.dark:
        return 'Dark';
      case AppThemeType.nord:
        return 'Nord';
      case AppThemeType.neumorphic:
        return 'Neumorphic';
      case AppThemeType.minimal:
        return 'Minimal';
    }
  }

  String _getThemeDescription(AppThemeType theme) {
    switch (theme) {
      case AppThemeType.light:
        return 'Clean and bright interface';
      case AppThemeType.dark:
        return 'Easy on the eyes in low light';
      case AppThemeType.nord:
        return 'Nordic inspired blue theme';
      case AppThemeType.neumorphic:
        return 'Soft 3D design elements';
      case AppThemeType.minimal:
        return 'Clean white with gold accents';
    }
  }

  List<Color> _getThemeColors(AppThemeType theme) {
    switch (theme) {
      case AppThemeType.light:
        return [const Color(0xFF5865F2), const Color(0xFF57F287)];
      case AppThemeType.dark:
        return [const Color(0xFF7289DA), const Color(0xFF43B581)];
      case AppThemeType.nord:
        return [const Color(0xFF88C0D0), const Color(0xFFA3BE8C)];
      case AppThemeType.neumorphic:
        return [const Color(0xFF6C63FF), const Color(0xFF00D2FF)];
      case AppThemeType.minimal:
        return [const Color(0xFFD4AF37), const Color(0xFFF4E4C1)];
    }
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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
          ),
        ),
        const SizedBox(width: AppStyles.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
