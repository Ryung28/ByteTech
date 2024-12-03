import 'package:flutter/material.dart';

class ChartStyles {
  static TextStyle get labelStyle => TextStyle(
    color: Colors.grey[600],
    fontSize: 10,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get axisNameStyle => TextStyle(
    color: Colors.grey[700],
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
  );

  static TextStyle get tooltipTitleStyle => const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w600,
    fontSize: 12,
  );

  static TextStyle get tooltipSubtitleStyle => TextStyle(
    color: Colors.white.withOpacity(0.9),
    fontSize: 11,
    fontWeight: FontWeight.normal,
  );
}
