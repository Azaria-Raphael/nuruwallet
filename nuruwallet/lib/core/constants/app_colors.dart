import 'package:flutter/material.dart';

/// NuruWallet brand palette.
/// Primary teal is derived from the Swahili word "Nuru" (light) — clear, trustworthy, illuminating.
abstract final class AppColors {
  // --- Brand ---
  static const primary = Color(0xFF0D9488);       // Teal 600
  static const primaryLight = Color(0xFF14B8A6);  // Teal 500
  static const primaryDark = Color(0xFF0F766E);   // Teal 700
  static const primaryContainer = Color(0xFFCCFBF1); // Teal 100

  // --- Semantic ---
  static const income = Color(0xFF16A34A);        // Green 600
  static const expense = Color(0xFFDC2626);       // Red 600
  static const warning = Color(0xFFD97706);       // Amber 600
  static const info = Color(0xFF2563EB);          // Blue 600

  // --- Budget progress bar ---
  static const budgetSafe = Color(0xFF16A34A);    // 0–60%
  static const budgetWarning = Color(0xFFD97706); // 60–80%
  static const budgetDanger = Color(0xFFDC2626);  // 80–100%
  static const budgetOver = Color(0xFF7F1D1D);    // over 100%

  // --- Neutral ---
  static const grey50 = Color(0xFFF9FAFB);
  static const grey100 = Color(0xFFF3F4F6);
  static const grey200 = Color(0xFFE5E7EB);
  static const grey300 = Color(0xFFD1D5DB);
  static const grey400 = Color(0xFF9CA3AF);
  static const grey500 = Color(0xFF6B7280);
  static const grey600 = Color(0xFF4B5563);
  static const grey700 = Color(0xFF374151);
  static const grey800 = Color(0xFF1F2937);
  static const grey900 = Color(0xFF111827);

  // --- Category palette (used to auto-assign colors) ---
  static const categoryColors = [
    Color(0xFFEF5350), // Red
    Color(0xFFEC407A), // Pink
    Color(0xFFAB47BC), // Purple
    Color(0xFF7E57C2), // Deep Purple
    Color(0xFF42A5F5), // Blue
    Color(0xFF26C6DA), // Cyan
    Color(0xFF26A69A), // Teal
    Color(0xFF66BB6A), // Green
    Color(0xFFD4E157), // Lime
    Color(0xFFFFCA28), // Yellow
    Color(0xFFFFA726), // Orange
    Color(0xFFFF7043), // Deep Orange
    Color(0xFF8D6E63), // Brown
    Color(0xFF78909C), // Blue Grey
  ];
}
