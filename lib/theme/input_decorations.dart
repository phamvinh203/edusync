import 'package:flutter/material.dart';
import 'colors.dart';

/// Input decoration styles for EduSync application
class InputDecorations {
  // Default input decoration theme
  static InputDecorationTheme get inputDecorationTheme {
    return InputDecorationTheme(
      // Filled style with light background
      filled: true,
      fillColor: AppColors.backgroundLight,

      // Content padding
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

      // Border styles
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.error, width: 1.5),
      ),

      // Label text style
      labelStyle: const TextStyle(
        fontSize: 14,
        color: AppColors.textMedium,
      ),

      // Hint text style
      hintStyle: const TextStyle(
        fontSize: 14,
        color: AppColors.textLight,
      ),

      // Error text style
      errorStyle: const TextStyle(
        fontSize: 12,
        color: AppColors.error,
      ),

      // Icon color
      prefixIconColor: AppColors.secondary,
      suffixIconColor: AppColors.secondary,
    );
  }

  // Auth input decoration (for login & signup screens)
  static InputDecoration authInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(
        prefixIcon,
        color: AppColors.secondary,
      ),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: AppColors.backgroundLight,
    );
  }

  // Search input decoration
  static InputDecoration searchInputDecoration({String hintText = 'Search'}) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: const Icon(
        Icons.search,
        color: AppColors.textLight,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: AppColors.backgroundLight,
    );
  }
}
