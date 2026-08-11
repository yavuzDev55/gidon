import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized typography rules: Odibee Sans for large/display text
/// (numbers, headings, the logo), Outfit for everything else (body
/// text, labels).
class AppTypography {
  AppTypography._();

  static TextStyle display({required Color color, double fontSize = 40}) {
    return GoogleFonts.odibeeSans(
      fontSize: fontSize,
      color: color,
      fontWeight: FontWeight.w400,
      height: 1.0,
    );
  }

  static TextStyle heading({required Color color, double fontSize = 24}) {
    return GoogleFonts.odibeeSans(
      fontSize: fontSize,
      color: color,
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle body({
    required Color color,
    double fontSize = 15,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return GoogleFonts.outfit(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
    );
  }

  static TextStyle label({required Color color, double fontSize = 12}) {
    return GoogleFonts.outfit(
      fontSize: fontSize,
      color: color,
      fontWeight: FontWeight.w500,
    );
  }
}
