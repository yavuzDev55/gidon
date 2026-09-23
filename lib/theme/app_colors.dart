import 'package:flutter/material.dart';

/// Centralized brand colors for the app. Change a value here and it
/// updates everywhere the color is used — never hardcode a color
/// elsewhere in the app.
class AppColors {
  AppColors._();

  static const Color yellow = Color(0xFFDB9F15);
  static const Color black = Color(0xFF111620);
  static const Color secondaryBlack = Color(0xFF2C3541);
  static const Color white = Color(0xFFFCFDFF);

  /// Used for "danger" actions only (discard ride, stop confirmation).
  /// Kept separate from the brand palette so yellow can stay the sole
  /// accent color for positive/primary actions.
  static const Color danger = Color(0xFFE5484D);

  /// Muted text color for secondary/less important labels, derived
  /// from white/black at reduced opacity so it adapts automatically
  /// if the base colors ever change.
  static Color mutedOnDark = white.withValues(alpha: 0.6);
  static Color mutedOnLight = black.withValues(alpha: 0.6);

  /// Used only for the route trail gradient — cycles smoothly between
  /// these two, kept separate from the core brand palette.
  static const Color routeTrailBlue = Color(0xFF2F6FED);
  static const Color routeTrailGreen = Color(0xFF2ED9A3);

  /// Planned (not yet ridden) route overlay — distinct from the
  /// recorded trail gradient.
  static const Color plannedRoute = yellow;
}
