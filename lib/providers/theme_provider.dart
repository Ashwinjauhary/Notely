import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notely/core/theme/app_theme.dart';

// Auto theme mode notifier
class AutoThemeModeNotifier extends StateNotifier<bool> {
  AutoThemeModeNotifier() : super(false) {
    _loadAutoMode();
  }

  Future<void> _loadAutoMode() async {
    // Load from settings if needed
    // For now, default to false
  }

  Future<void> setAutoMode(bool enabled) async {
    state = enabled;
    // Save to settings if needed
  }

  Future<void> toggleAutoMode() async {
    await setAutoMode(!state);
  }
}

final autoThemeProvider = StateNotifierProvider<AutoThemeModeNotifier, bool>((ref) {
  return AutoThemeModeNotifier();
});

// Combined theme provider that handles auto mode
final effectiveThemeProvider = Provider<ThemeData>((ref) {
  final appTheme = ref.watch(appThemeProvider);
  final isAutoMode = ref.watch(autoThemeProvider);
  
  if (isAutoMode) {
    // Check system theme mode
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    if (brightness == Brightness.dark) {
      return AppTheme.darkTheme;
    } else {
      return AppTheme.lightTheme;
    }
  }
  
  return ref.watch(themeDataProvider);
});

// Theme mode provider for Material App
final themeModeProvider = Provider<ThemeMode>((ref) {
  final appTheme = ref.watch(appThemeProvider);
  final isAutoMode = ref.watch(autoThemeProvider);
  
  if (isAutoMode) {
    return ThemeMode.system;
  }
  
  switch (appTheme) {
    case AppThemeType.light:
    case AppThemeType.neumorphic:
    case AppThemeType.minimal:
      return ThemeMode.light;
    case AppThemeType.dark:
    case AppThemeType.nord:
      return ThemeMode.dark;
  }
});

// Font size provider
class FontSizeNotifier extends StateNotifier<double> {
  FontSizeNotifier() : super(1.0) {
    _loadFontSize();
  }

  Future<void> _loadFontSize() async {
    // Load from settings if needed
    // For now, default to 1.0
  }

  Future<void> setFontSize(double size) async {
    state = size.clamp(0.8, 1.5);
    // Save to settings if needed
  }

  Future<void> increaseFontSize() async {
    await setFontSize(state + 0.1);
  }

  Future<void> decreaseFontSize() async {
    await setFontSize(state - 0.1);
  }

  Future<void> resetFontSize() async {
    await setFontSize(1.0);
  }
}

final fontSizeProvider = StateNotifierProvider<FontSizeNotifier, double>((ref) {
  return FontSizeNotifier();
});

// Text scale factor provider for Material App
final textScaleFactorProvider = Provider<double>((ref) {
  return ref.watch(fontSizeProvider);
});

// Color scheme provider
final colorSchemeProvider = Provider<ColorScheme>((ref) {
  return ref.watch(effectiveThemeProvider).colorScheme;
});

// Text theme provider
final textThemeProvider = Provider<TextTheme>((ref) {
  final baseTheme = ref.watch(effectiveThemeProvider).textTheme;
  final fontSize = ref.watch(fontSizeProvider);
  
  return baseTheme.copyWith(
    headlineLarge: baseTheme.headlineLarge?.copyWith(
      fontSize: baseTheme.headlineLarge?.fontSize != null 
          ? baseTheme.headlineLarge!.fontSize! * fontSize
          : null,
    ),
    headlineMedium: baseTheme.headlineMedium?.copyWith(
      fontSize: baseTheme.headlineMedium?.fontSize != null 
          ? baseTheme.headlineMedium!.fontSize! * fontSize
          : null,
    ),
    headlineSmall: baseTheme.headlineSmall?.copyWith(
      fontSize: baseTheme.headlineSmall?.fontSize != null 
          ? baseTheme.headlineSmall!.fontSize! * fontSize
          : null,
    ),
    bodyLarge: baseTheme.bodyLarge?.copyWith(
      fontSize: baseTheme.bodyLarge?.fontSize != null 
          ? baseTheme.bodyLarge!.fontSize! * fontSize
          : null,
    ),
    bodyMedium: baseTheme.bodyMedium?.copyWith(
      fontSize: baseTheme.bodyMedium?.fontSize != null 
          ? baseTheme.bodyMedium!.fontSize! * fontSize
          : null,
    ),
    bodySmall: baseTheme.bodySmall?.copyWith(
      fontSize: baseTheme.bodySmall?.fontSize != null 
          ? baseTheme.bodySmall!.fontSize! * fontSize
          : null,
    ),
  );
});

// Icon theme provider
final iconThemeProvider = Provider<IconThemeData>((ref) {
  return ref.watch(effectiveThemeProvider).iconTheme;
});

// Card theme provider
final cardThemeProvider = Provider<CardTheme>((ref) {
  return ref.watch(effectiveThemeProvider).cardTheme;
});

// App bar theme provider
final appBarThemeProvider = Provider<AppBarTheme>((ref) {
  return ref.watch(effectiveThemeProvider).appBarTheme;
});

// Elevated button theme provider
final elevatedButtonThemeProvider = Provider<ElevatedButtonThemeData>((ref) {
  return ref.watch(effectiveThemeProvider).elevatedButtonTheme;
});

// Outlined button theme provider
final outlinedButtonThemeProvider = Provider<OutlinedButtonThemeData>((ref) {
  return ref.watch(effectiveThemeProvider).outlinedButtonTheme;
});

// Text button theme provider
final textButtonThemeProvider = Provider<TextButtonThemeData>((ref) {
  return ref.watch(effectiveThemeProvider).textButtonTheme;
});

// Input decoration theme provider
final inputDecorationThemeProvider = Provider<InputDecorationTheme>((ref) {
  return ref.watch(effectiveThemeProvider).inputDecorationTheme);
});

// Floating action button theme provider
final floatingActionButtonThemeProvider = Provider<FloatingActionButtonThemeData>((ref) {
  return ref.watch(effectiveThemeProvider).floatingActionButtonTheme;
});

// Bottom navigation bar theme provider
final bottomNavigationBarThemeProvider = Provider<BottomNavigationBarThemeData>((ref) {
  return ref.watch(effectiveThemeProvider).bottomNavigationBarTheme;
});

// Chip theme provider
final chipThemeProvider = Provider<ChipThemeData>((ref) {
  return ref.watch(effectiveThemeProvider).chipTheme;
});

// Dialog theme provider
final dialogThemeProvider = Provider<DialogTheme>((ref) {
  return ref.watch(effectiveThemeProvider).dialogTheme);
});

// Divider theme provider
final dividerThemeProvider = Provider<DividerThemeData>((ref) {
  return ref.watch(effectiveThemeProvider).dividerTheme;
});

// List tile theme provider
final listTileThemeProvider = Provider<ListTileThemeData>((ref) {
  return ref.watch(effectiveThemeProvider).listTileTheme;
});

// Switch theme provider
final switchThemeProvider = Provider<SwitchThemeData>((ref) {
  return ref.watch(effectiveThemeProvider).switchTheme;
});

// Checkbox theme provider
final checkboxThemeProvider = Provider<CheckboxThemeData>((ref) {
  return ref.watch(effectiveThemeProvider).checkboxTheme;
});

// Radio theme provider
final radioThemeProvider = Provider<RadioThemeData>((ref) {
  return ref.watch(effectiveThemeProvider).radioTheme;
});

// Slider theme provider
final sliderThemeProvider = Provider<SliderThemeData>((ref) {
  return ref.watch(effectiveThemeProvider).sliderTheme;
});

// Progress indicator theme provider
final progressIndicatorThemeProvider = Provider<ProgressIndicatorThemeData>((ref) {
  return ref.watch(effectiveThemeProvider).progressIndicatorTheme);
});

// Tooltip theme provider
final tooltipThemeProvider =Provider<TooltipThemeData>((ref) {
  return ref.watch(effectiveThemeProvider).tooltipTheme);
});

// Snack bar theme provider
final snackBarThemeProvider = Provider<SnackBarThemeData>((ref) {
  return ref.watch(effectiveThemeProvider).snackBarTheme);
});

// Bottom sheet theme provider
final bottomSheetThemeProvider = Provider<BottomSheetThemeData>((ref) {
  return ref.watch(effectiveThemeProvider).bottomSheetTheme);
});

// Tab bar theme provider
final tabBarThemeProvider = Provider<TabBarTheme>((ref) {
  return ref.watch(effectiveThemeProvider).tabBarTheme);
});

// Badge theme provider
final badgeThemeProvider = Provider<BadgeThemeData>((ref) {
  return ref.watch(effectiveThemeProvider).badgeTheme);
});

// Expansion tile theme provider
final expansionTileThemeProvider = Provider<ExpansionTileThemeData>((ref) {
  return ref.watch(effectiveThemeProvider).expansionTileTheme;
});

// Popup menu theme provider
final popupMenuThemeProvider = Provider<PopupMenuThemeData>((ref) {
  return ref.watch(effectiveThemeProvider).popupMenuTheme);
});

// Search bar theme provider
final searchBarThemeProvider = Provider<SearchBarThemeData>((ref) {
  return ref.watch(effectiveThemeProvider).searchBarTheme);
});

// Search view theme provider
final searchViewThemeProvider = Provider<SearchViewThemeData>((ref) {
  return ref.watch(effectiveThemeProvider).searchViewTheme;
});
