import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF6DD47E);
  static const Color accentGreen = Color(0xFF219653);
  static const Color background = Color(0xFFF2FFF6);
  static const Color card = Color(0xFFFFFFFF);
  static const double borderRadius = 20.0;

  static ThemeData get themeData => ThemeData(
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: primaryGreen,
      secondary: accentGreen,
    ),
    textTheme: GoogleFonts.nunitoTextTheme(),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        ),
        textStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        borderSide: BorderSide.none,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      iconTheme: IconThemeData(color: accentGreen),
      titleTextStyle: GoogleFonts.nunito(
        color: accentGreen,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
