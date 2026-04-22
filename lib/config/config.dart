import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized color theme used across the Umrah and Hajj Campaign app
class Nakhwa {
  // Rich brown background used throughout splash and welcome screens
  static const Color background = Color(0xFF063432); // Deep Mocha Brown

  // Card or overlay surface for text (used behind welcome message)
  static const Color surface = Color(0xFFebece7); // Warm Cocoa

  // Main text color (title white on brown background)
  static const Color textPrimary = Color(0xFFFFFFFF); // White

  // Secondary text color (subtext on welcome page)
  static const Color textSecondary = Color(0xFFDDCBB3); // Sand Beige

  // Primary call-to-action button (Create Account)
  static const Color buttonPrimary = Color(0xFFD6BA8A); // Soft Gold

  // Secondary button (Sign in)
  static const Color buttonSecondary = Color(0xFF4B2E19); // Same as background

  // Accent color for highlights/icons
  static const Color accent = Color(0xFFF4E6C1); // Light Cream

  // Divider or border color
  static const Color border = Color(0xFFB68D61); // Muted Bronze

  // Error or alert color
  static const Color error = Color(0xFFE76F51); // Coral Red

  static const Color greenColor = Color(0xFF81a87e); // Coral Red

  static SharedPreferences? sharedPreferences;

  static String googleKey = "AIzaSyBpLzaDvyWfvVvxD9xO3fM1i5FfCbjJ9nE";

  /// Default admin email used to receive SOS notifications
  static const String adminEmail = 'admin@example.com';
}
