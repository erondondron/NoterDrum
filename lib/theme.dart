import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeColors {
  static const white = Color(0xFFEEEEEE);
  static const orange = Color(0xFFE28C52);
  static const grey = Color(0xFF1F1F1F);
  static const lightGrey = Color(0xFF454545);
  static const darkGrey = Color(0xFF181818);
  static const red = Colors.red;
}

final textTheme = GoogleFonts.baloo2TextTheme(ThemeData.dark().textTheme)
    .apply(bodyColor: ThemeColors.white)
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
  scaffoldBackgroundColor: ThemeColors.grey,
  colorScheme: const ColorScheme.dark(
    primary: ThemeColors.orange,
    surface: ThemeColors.grey,
    onSurface: ThemeColors.white,
    secondaryContainer: ThemeColors.darkGrey,
    onSecondaryContainer: ThemeColors.lightGrey,
    error: ThemeColors.red,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: ThemeColors.grey,
    titleTextStyle: textTheme.titleLarge,
  ),
  popupMenuTheme: PopupMenuThemeData(
    color: ThemeColors.darkGrey,
    labelTextStyle: WidgetStatePropertyAll(textTheme.bodyMedium),
  ),
  dividerTheme: DividerThemeData(
    color: ThemeColors.lightGrey,
    indent: 10,
    endIndent: 10,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: ThemeColors.darkGrey,
    contentPadding: EdgeInsets.all(10),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(
        color: ThemeColors.lightGrey,
        width: 1.5,
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(ThemeColors.darkGrey),
      foregroundColor: WidgetStatePropertyAll(ThemeColors.white),
      side: WidgetStatePropertyAll(
        BorderSide(
          color: ThemeColors.lightGrey,
          width: 1.5,
        ),
      ),
    ),
  ),
);
