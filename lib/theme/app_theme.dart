import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_styles.dart';
import 'input_decorations.dart';
import 'button_styles.dart';

/// Main theme class for EduSync app
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      // Base colors
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        background: Colors.white,
        error: AppColors.error,
      ),

      // Text theme
      textTheme: TextTheme(
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        labelLarge: AppTextStyles.labelLarge,
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorations.inputDecorationTheme,

      // Elevated button theme
      elevatedButtonTheme: ButtonStyles.elevatedButtonTheme,

      // Text button theme
      textButtonTheme: ButtonStyles.textButtonTheme,

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.secondary;
          }
          return Colors.transparent;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textDark),
        titleTextStyle: AppTextStyles.titleLarge,
      ),

      // Card theme
      cardTheme: CardTheme(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Colors.white,
      ),
    );
  }

  // You can add a dark theme later
  static ThemeData get darkTheme {
    // TODO: Implement dark theme
    return lightTheme;
  }
}
