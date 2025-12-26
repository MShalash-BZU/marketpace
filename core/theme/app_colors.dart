import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const primary = Color(0xFF2563EB); // Blue
  static const primaryDark = Color(0xFF1E40AF);
  static const primaryLight = Color(0xFF60A5FA);
  
  // Secondary Colors
  static const secondary = Color(0xFF10B981); // Green
  static const secondaryDark = Color(0xFF059669);
  static const secondaryLight = Color(0xFF34D399);
  
  // Accent Colors
  static const accent = Color(0xFFF59E0B); // Amber
  static const accentDark = Color(0xFFD97706);
  static const accentLight = Color(0xFFFBBF24);
  
  // Status Colors
  static const success = Color(0xFF10B981);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF3B82F6);
  
  // Neutral Colors
  static const black = Color(0xFF000000);
  static const white = Color(0xFFFFFFFF);
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
  
  // Semantic Colors
  static const background = white;
  static const backgroundDark = grey900;
  static const surface = white;
  static const surfaceDark = grey800;
  static const text = grey900;
  static const textDark = grey50;
  static const textSecondary = grey600;
  static const textSecondaryDark = grey400;
  static const divider = grey200;
  static const dividerDark = grey700;
  
  // Order Status Colors
  static const statusPending = warning;
  static const statusPreparing = info;
  static const statusReady = accent;
  static const statusInTransit = primary;
  static const statusDelivered = success;
  static const statusCancelled = error;
  
  // Role Colors
  static const customer = primary;
  static const store = success;
  static const courier = accent;
  static const admin = Color(0xFF8B5CF6); // Purple
  
  // Gradient Colors
  static const gradientStart = primary;
  static const gradientEnd = Color(0xFF7C3AED);
  
  static LinearGradient get primaryGradient => const LinearGradient(
        colors: [gradientStart, gradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
  
  static LinearGradient get successGradient => const LinearGradient(
        colors: [success, secondaryDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
  
  static LinearGradient get warningGradient => const LinearGradient(
        colors: [warning, accentDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}