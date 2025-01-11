import 'package:flutter/material.dart';

class ChartStyles {
  static TextStyle get labelStyle => TextStyle(
    color: Colors.grey[600],
    fontSize: 12,  // Increased from 12
    fontWeight: FontWeight.w500,
  );

  static TextStyle get axisNameStyle => TextStyle(
    color: Colors.grey[700],
    fontSize: 14,  // Increased from 14
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  static TextStyle get tooltipTitleStyle => const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w600,
    fontSize: 10,  // Increased from 16
  );

  static TextStyle get tooltipSubtitleStyle => TextStyle(
    color: Colors.white.withOpacity(0.9),
    fontSize: 10,  // Increased from 14
    fontWeight: FontWeight.w500,
  );

  // Adding padding configurations for better positioning
  static const EdgeInsets axisTitlePadding = EdgeInsets.only(
    top: 16.0,    // Move time labels up
    bottom: 8.0,
    left: 8.0,
    right: 8.0,
  );

  static const EdgeInsets userTextPadding = EdgeInsets.only(
    top: 2.0,    // Move user text up
    bottom: 8.0,
    left: 8.0,
    right: 8.0,
  );
}
