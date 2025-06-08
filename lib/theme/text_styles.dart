import 'package:flutter/material.dart';
import 'colors.dart';

/// Text styles for EduSync application
class AppTextStyles {
  // Headline styles
  static const headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
    letterSpacing: 0.25,
  );

  static const headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
    letterSpacing: 0.25,
  );

  // Title styles
  static const titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    letterSpacing: 0.15,
  );

  static const titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    letterSpacing: 0.15,
  );

  // Body styles
  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textMedium,
    letterSpacing: 0.5,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textMedium,
    letterSpacing: 0.25,
  );

  // Label styles
  static const labelLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    letterSpacing: 0.1,
  );

  // Form field label style
  static const fieldLabel = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    letterSpacing: 0.1,
  );

  // Button text style
  static const buttonText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.0,
  );

  // Link text style
  static const linkText = TextStyle(
    color: AppColors.primary,
    fontWeight: FontWeight.w600,
    decoration: TextDecoration.underline,
  );

  // Welcome text style for login/register screens
  static const welcomeText = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 1.2,
  );

  // Subtitle text style for login/register screens
  static const subtitleText = TextStyle(
    fontSize: 16,
    color: Colors.white70,
  );
}
