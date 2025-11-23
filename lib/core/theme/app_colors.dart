import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightPrimary = Color(0xFF5865F2);
  static const Color lightSecondary = Color(0xFF57F287);
  static const Color lightAccent = Color(0xFFED4245);
  
  static const Color lightTextPrimary = Color(0xFF2C3E50);
  static const Color lightTextSecondary = Color(0xFF7F8C8D);
  static const Color lightTextTertiary = Color(0xFFBDC3C7);
  
  static const Color lightBorder = Color(0xFFE1E8ED);
  static const Color lightDivider = Color(0xFFF0F3F4);
  static const Color lightShadow = Color(0x1A000000);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF1A1B1E);
  static const Color darkSurface = Color(0xFF2C2F33);
  static const Color darkPrimary = Color(0xFF7289DA);
  static const Color darkSecondary = Color(0xFF43B581);
  static const Color darkAccent = Color(0xFFF04747);
  
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB9BBBE);
  static const Color darkTextTertiary = Color(0xFF72767D);
  
  static const Color darkBorder = Color(0xFF42454A);
  static const Color darkDivider = Color(0xFF36393F);
  static const Color darkShadow = Color(0x33000000);

  // Nord Theme Colors
  static const Color nordBackground = Color(0xFF2E3440);
  static const Color nordSurface = Color(0xFF3B4252);
  static const Color nordPrimary = Color(0xFF88C0D0);
  static const Color nordSecondary = Color(0xFFA3BE8C);
  static const Color nordAccent = Color(0xFFBF616A);
  
  static const Color nordTextPrimary = Color(0xFFD8DEE9);
  static const Color nordTextSecondary = Color(0xFFE5E9F0);
  static const Color nordTextTertiary = Color(0xFF4C566A);
  
  static const Color nordBorder = Color(0xFF434C5E);
  static const Color nordDivider = Color(0xFF3B4252);
  static const Color nordShadow = Color(0x66000000);

  // Neumorphic Theme Colors
  static const Color neoBackground = Color(0xFFE8EAED);
  static const Color neoSurface = Color(0xFFF5F7FA);
  static const Color neoPrimary = Color(0xFF6C63FF);
  static const Color neoSecondary = Color(0xFF00D2FF);
  static const Color neoAccent = Color(0xFFFF6B6B);
  
  static const Color neoTextPrimary = Color(0xFF2D3436);
  static const Color neoTextSecondary = Color(0xFF636E72);
  static const Color neoTextTertiary = Color(0xFFB2BEC3);
  
  static const Color neoBorder = Color(0xFFDFE6E9);
  static const Color neoDivider = Color(0xFFF5F7FA);
  static const Color neoShadow = Color(0x33000000);

  // Minimal White + Gold Theme
  static const Color minimalBackground = Color(0xFFFFFFFF);
  static const Color minimalSurface = Color(0xFFFFFAF5);
  static const Color minimalPrimary = Color(0xFFD4AF37); // Gold
  static const Color minimalSecondary = Color(0xFFF4E4C1); // Light Gold
  static const Color minimalAccent = Color(0xFFE8C547); // Warm Gold
  
  static const Color minimalTextPrimary = Color(0xFF1A1A1A);
  static const Color minimalTextSecondary = Color(0xFF666666);
  static const Color minimalTextTertiary = Color(0xFF999999);
  
  static const Color minimalBorder = Color(0xFFE8E8E8);
  static const Color minimalDivider = Color(0xFFF5F5F5);
  static const Color minimalShadow = Color(0x1A000000);

  // Tag Colors
  static const Color tagWork = Color(0xFF3498DB);
  static const Color tagStudy = Color(0xFF2ECC71);
  static const Color tagIdea = Color(0xFFF39C12);
  static const Color tagUrgent = Color(0xFFE74C3C);
  static const Color tagPersonal = Color(0xFF9B59B6);
  
  static const List<Color> tagColors = [
    tagWork,
    tagStudy,
    tagIdea,
    tagUrgent,
    tagPersonal,
  ];

  // Note Colors
  static const List<Color> noteColors = [
    Color(0xFFFFFBFE), // Default
    Color(0xFFFFF8E1), // Light Yellow
    Color(0xFFE8F5E8), // Light Green
    Color(0xFFFFF3E0), // Light Orange
    Color(0xFFF3E5F5), // Light Purple
    Color(0xFFE3F2FD), // Light Blue
    Color(0xFFFFEBEE), // Light Red
    Color(0xFFE0F2F1), // Light Teal
  ];
}

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightPrimary,
      secondary: AppColors.lightSecondary,
      surface: AppColors.lightSurface,
      background: AppColors.lightBackground,
      error: AppColors.lightAccent,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: AppColors.lightTextPrimary,
      onBackground: AppColors.lightTextPrimary,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightBackground,
      foregroundColor: AppColors.lightTextPrimary,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardTheme(
      color: AppColors.lightSurface,
      elevation: 2,
      shadowColor: AppColors.lightShadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 32,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        color: AppColors.lightTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkSecondary,
      surface: AppColors.darkSurface,
      background: AppColors.darkBackground,
      error: AppColors.darkAccent,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: AppColors.darkTextPrimary,
      onBackground: AppColors.darkTextPrimary,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.darkTextPrimary,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardTheme(
      color: AppColors.darkSurface,
      elevation: 4,
      shadowColor: AppColors.darkShadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: Colors.black,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 32,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        color: AppColors.darkTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    ),
  );

  static ThemeData get nordTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.nordPrimary,
      secondary: AppColors.nordSecondary,
      surface: AppColors.nordSurface,
      background: AppColors.nordBackground,
      error: AppColors.nordAccent,
      onPrimary: AppColors.nordBackground,
      onSecondary: AppColors.nordBackground,
      onSurface: AppColors.nordTextPrimary,
      onBackground: AppColors.nordTextPrimary,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.nordBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.nordBackground,
      foregroundColor: AppColors.nordTextPrimary,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardTheme(
      color: AppColors.nordSurface,
      elevation: 4,
      shadowColor: AppColors.nordShadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.nordPrimary,
        foregroundColor: AppColors.nordBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppColors.nordTextPrimary,
        fontSize: 32,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: TextStyle(
        color: AppColors.nordTextPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: AppColors.nordTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        color: AppColors.nordTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    ),
  );

  static ThemeData get neumorphicTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.neoPrimary,
      secondary: AppColors.neoSecondary,
      surface: AppColors.neoSurface,
      background: AppColors.neoBackground,
      error: AppColors.neoAccent,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: AppColors.neoTextPrimary,
      onBackground: AppColors.neoTextPrimary,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.neoBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.neoBackground,
      foregroundColor: AppColors.neoTextPrimary,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardTheme(
      color: AppColors.neoSurface,
      elevation: 8,
      shadowColor: AppColors.neoShadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.neoPrimary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppColors.neoTextPrimary,
        fontSize: 32,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: TextStyle(
        color: AppColors.neoTextPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: AppColors.neoTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        color: AppColors.neoTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    ),
  );

  static ThemeData get minimalTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.minimalPrimary,
      secondary: AppColors.minimalSecondary,
      surface: AppColors.minimalSurface,
      background: AppColors.minimalBackground,
      error: AppColors.minimalAccent,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: AppColors.minimalTextPrimary,
      onBackground: AppColors.minimalTextPrimary,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.minimalBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.minimalBackground,
      foregroundColor: AppColors.minimalTextPrimary,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardTheme(
      color: AppColors.minimalSurface,
      elevation: 1,
      shadowColor: AppColors.minimalShadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.minimalPrimary,
        foregroundColor: Colors.black,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppColors.minimalTextPrimary,
        fontSize: 32,
        fontWeight: FontWeight.w300,
      ),
      headlineMedium: TextStyle(
        color: AppColors.minimalTextPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w400,
      ),
      bodyLarge: TextStyle(
        color: AppColors.minimalTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w300,
      ),
      bodyMedium: TextStyle(
        color: AppColors.minimalTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w300,
      ),
    ),
  );
}
