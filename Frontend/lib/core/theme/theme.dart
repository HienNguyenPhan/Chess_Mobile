import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chess_app/core/theme/colors.dart';

class AppTheme {
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    brightness: Brightness.light,
    
    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryLight,
      onPrimary: AppColors.white,
      secondary: AppColors.secondary,
      onSecondary: AppColors.white,
      tertiary: AppColors.accent,
      background: AppColors.background,
      surface: AppColors.surface,
      error: AppColors.error,
    ),
    
    // Background & Surface Colors
    scaffoldBackgroundColor: AppColors.background,
    
    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    
    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    
    // Text Input Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    
    // Card Theme
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 1,
      shadowColor: AppColors.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: AppColors.grey800,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.grey700,
      ),
    ),
    
    // Icon Theme
    iconTheme: const IconThemeData(
      color: AppColors.primary,
      size: 24,
    ),
    
    // Dialog Theme
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // Bottom Sheet Theme
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      elevation: 3,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    
    // List Tile Theme
    listTileTheme: ListTileThemeData(
      tileColor: AppColors.surface,
      selectedTileColor: AppColors.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    
    // Divider Theme
    dividerTheme: DividerThemeData(
      color: AppColors.grey200,
      thickness: 1,
      space: 1,
    ),
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    brightness: Brightness.dark,
    
    // Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryLight,
      primaryContainer: AppColors.primary,
      onPrimary: AppColors.white,
      secondary: AppColors.accent,
      onSecondary: AppColors.black,
      background: AppColors.grey900,
      surface: AppColors.grey800,
      error: AppColors.error,
    ),
    
    // Background & Surface Colors 
    scaffoldBackgroundColor: AppColors.grey900,
    
    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.grey800,
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    
    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    
    // Card Theme
    cardTheme: CardThemeData(
      color: AppColors.grey800,
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.white,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: AppColors.grey300,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.grey400,
      ),
    ),
    
    // Icon Theme
    iconTheme: const IconThemeData(
      color: AppColors.primaryLight,
      size: 24,
    ),
    
    // Dialog Theme
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.grey800,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // Bottom Sheet Theme  
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.grey800,
      elevation: 3,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    
    // List Tile Theme
    listTileTheme: ListTileThemeData(
      tileColor: AppColors.grey800,
      selectedTileColor: AppColors.primary.withOpacity(0.2),
      textColor: AppColors.white,
      iconColor: AppColors.primaryLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    
    // Divider Theme
    dividerTheme: DividerThemeData(
      color: AppColors.grey700,
      thickness: 1,
      space: 1,
    ),
  );

  // Gradient Decorations
  static BoxDecoration primaryGradient = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.primary,
        AppColors.primaryLight,
      ],
    ),
  );

  static BoxDecoration accentGradient = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.accent,
        AppColors.accent.withOpacity(0.8),
      ],
    ),
  );

  static BoxDecoration surfaceDecoration = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
}