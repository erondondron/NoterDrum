import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final textTheme = GoogleFonts.baloo2TextTheme(ThemeData.dark().textTheme)
    .apply(bodyColor: const Color(0xFFEEEEEE))
    .copyWith(
      titleLarge: GoogleFonts.baloo2(
        fontSize: 30,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: GoogleFonts.baloo2(
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
    );

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  textTheme: textTheme,
  scaffoldBackgroundColor: const Color(0xFF1F1F1F),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFFE28C52),
    surface: Color(0xFF1F1F1F),
    onSurface: Color(0xFFEEEEEE),
    secondaryContainer: Color(0xFF181818),
    onSecondaryContainer: Color(0xFF454545),
    error: Colors.red,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF1F1F1F),
    titleTextStyle: textTheme.titleLarge,
  ),
  popupMenuTheme: PopupMenuThemeData(
    color: Color(0xFF181818),
    labelTextStyle: WidgetStatePropertyAll(textTheme.bodyMedium),
  ),
  dividerTheme: DividerThemeData(
    color: Color(0xFF454545),
    indent: 10,
    endIndent: 10,
  ),
);
