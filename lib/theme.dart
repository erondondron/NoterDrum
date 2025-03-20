import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final textTheme = GoogleFonts.baloo2TextTheme(ThemeData.dark().textTheme)
    .apply(bodyColor: const Color(0xFFEEEEEE))
    .copyWith(
      titleLarge: GoogleFonts.baloo2(
        fontSize: 30,
        fontWeight: FontWeight.w500,
      ),
    );

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  textTheme: textTheme,
  scaffoldBackgroundColor: const Color(0xFF1F1F1F),
  colorScheme: const ColorScheme.dark(
    surface: Color(0xFF1F1F1F),
    onSurface: Color(0xFFEEEEEE),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF1F1F1F),
    titleTextStyle: textTheme.titleLarge,
  ),
);
