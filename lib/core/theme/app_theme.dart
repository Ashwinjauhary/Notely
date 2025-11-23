import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'app_colors.dart';

enum AppThemeType {
  light,
  dark,
  nord,
  neumorphic,
  minimal,
}

class AppThemeNotifier extends StateNotifier<AppThemeType> {
  AppThemeNotifier() : super(AppThemeType.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final box = await Hive.openBox('settings');
      final savedTheme = box.get('theme', defaultValue: AppThemeType.light);
      state = savedTheme;
    } catch (e) {
      state = AppThemeType.light;
    }
  }

  Future<void> setTheme(AppThemeType theme) async {
    state = theme;
    try {
      final box = await Hive.openBox('settings');
      await box.put('theme', theme);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> toggleDarkMode() async {
    final newTheme = state == AppThemeType.dark ? AppThemeType.light : AppThemeType.dark;
    await setTheme(newTheme);
  }

  bool get isDarkMode => state == AppThemeType.dark || state == AppThemeType.nord;
}

final appThemeProvider = StateNotifierProvider<AppThemeNotifier, AppThemeType>((ref) {
  return AppThemeNotifier();
});

final themeDataProvider = Provider<ThemeData>((ref) {
  final themeType = ref.watch(appThemeProvider);
  
  switch (themeType) {
    case AppThemeType.light:
      return AppTheme.lightTheme;
    case AppThemeType.dark:
      return AppTheme.darkTheme;
    case AppThemeType.nord:
      return AppTheme.nordTheme;
    case AppThemeType.neumorphic:
      return AppTheme.neumorphicTheme;
    case AppThemeType.minimal:
      return AppTheme.minimalTheme;
  }
});

class ThemeExtension extends ThemeExtension<ThemeExtension> {
  final Color cardBackground;
  final Color noteBackground;
  final Color tagColor;
  final Color searchBackground;
  final Color dividerColor;
  final Color shadowColor;

  const ThemeExtension({
    required this.cardBackground,
    required this.noteBackground,
    required this.tagColor,
    required this.searchBackground,
    required this.dividerColor,
    required this.shadowColor,
  });

  @override
  ThemeExtension copyWith({
    Color? cardBackground,
    Color? noteBackground,
    Color? tagColor,
    Color? searchBackground,
    Color? dividerColor,
    Color? shadowColor,
  }) {
    return ThemeExtension(
      cardBackground: cardBackground ?? this.cardBackground,
      noteBackground: noteBackground ?? this.noteBackground,
      tagColor: tagColor ?? this.tagColor,
      searchBackground: searchBackground ?? this.searchBackground,
      dividerColor: dividerColor ?? this.dividerColor,
      shadowColor: shadowColor ?? this.shadowColor,
    );
  }

  @override
  ThemeExtension lerp(ThemeExtension? other, double t) {
    if (other is! ThemeExtension) return this;
    
    return ThemeExtension(
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      noteBackground: Color.lerp(noteBackground, other.noteBackground, t)!,
      tagColor: Color.lerp(tagColor, other.tagColor, t)!,
      searchBackground: Color.lerp(searchBackground, other.searchBackground, t)!,
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
    );
  }

  static ThemeExtension of(BuildContext context) {
    return Theme.of(context).extension<ThemeExtension>() ?? _getDefault();
  }

  static ThemeExtension _getDefault() {
    return const ThemeExtension(
      cardBackground: AppColors.lightSurface,
      noteBackground: AppColors.lightBackground,
      tagColor: AppColors.tagWork,
      searchBackground: AppColors.lightDivider,
      dividerColor: AppColors.lightBorder,
      shadowColor: AppColors.lightShadow,
    );
  }
}

extension ThemeDataExtension on ThemeData {
  ThemeExtension get customExtension => extension<ThemeExtension>() ?? ThemeExtension._getDefault();
}
