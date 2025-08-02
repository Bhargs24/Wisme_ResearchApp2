import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF246BFD);
  static const Color primaryDark = Color(0xFF181A20);
  static const Color primaryLight = Color(0xFF23272F);

  // Primary Color Variants (Replace withOpacity usage)
  static const Color primaryBlueLight = Color(0x1A246BFD); // 10% opacity
  static const Color primaryBlueMedium = Color(0x33246BFD); // 20% opacity
  static const Color primaryBlueHeavy = Color(0x80246BFD); // 50% opacity
  static const Color primaryBlueVeryLight = Color(0x0D246BFD); // 5% opacity

  // Accent Colors
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentGreen = Color(0xFF00BFAE);
  static const Color accentRed = Color(0xFFFF5370);

  // Accent Color Variants
  static const Color accentOrangeLight = Color(0x1AFF9800); // 10% opacity
  static const Color accentGreenLight = Color(0x1A00BFAE); // 10% opacity
  static const Color accentRedLight = Color(0x1AFF5370); // 10% opacity

  // Neutral Colors
  static const Color backgroundDark = Color(0xFF181A20);
  static const Color backgroundCard = Color(0xFF23272F);
  static const Color cardBackground = Color(0xFF23272F); // Alias for compatibility
  static const Color textPrimary = Color(0xFFF5F6FA);
  static const Color textSecondary = Color(0xFFA0A4B8);

  // Text Color Variants
  static const Color textPrimaryLight = Color(0x80F5F6FA); // 50% opacity
  static const Color textSecondaryLight = Color(0x66A0A4B8); // 40% opacity
  static const Color textTertiary = Color(0x4DA0A4B8); // 30% opacity

  // Overlay Colors (for modals, loading states, etc.)
  static const Color overlayLight = Color(0x1A000000); // 10% black
  static const Color overlayMedium = Color(0x4D000000); // 30% black
  static const Color overlayHeavy = Color(0x80000000); // 50% black

  // Interaction States
  static const Color hoverLight = Color(0x0DF5F6FA); // 5% white
  static const Color pressedLight = Color(0x1AF5F6FA); // 10% white
  static const Color focusLight = Color(0x33246BFD); // 20% primary blue

  // Status Colors
  static const Color success = Color(0xFF00BFAE);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFFF5370);
  static const Color info = Color(0xFF246BFD);

  // Status Color Variants
  static const Color successBackground = Color(0x1A00BFAE);
  static const Color warningBackground = Color(0x1AFF9800);
  static const Color errorBackground = Color(0x1AFF5370);
  static const Color infoBackground = Color(0x1A246BFD);
} 