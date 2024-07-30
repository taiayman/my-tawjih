import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final Color primaryColor = Color(0xFF3498db);
final Color secondaryColor = Color(0xFFe74c3c);
final Color accentColor = Color(0xFFf39c12);
final Color backgroundColorLight = Color(0xFFecf0f1);
final Color backgroundColorDark = Color.fromARGB(255, 255, 255, 255);
final Color textColorLight = Color.fromARGB(255, 255, 255, 255);
final Color textColorDark = Color(0xFFecf0f1);

ThemeData lightTheme = ThemeData(
  primaryColor: primaryColor,
  colorScheme: ColorScheme.light(
    primary: primaryColor,
    secondary: secondaryColor,
  ),
  backgroundColor: backgroundColorLight,
  scaffoldBackgroundColor: backgroundColorLight,
  textTheme: GoogleFonts.robotoTextTheme(
    TextTheme(
      headline1: TextStyle(color: textColorLight, fontFamily: 'Poppins', fontWeight: FontWeight.bold),
      headline2: TextStyle(color: textColorLight, fontFamily: 'Poppins', fontWeight: FontWeight.bold),
      bodyText1: TextStyle(color: textColorLight),
      bodyText2: TextStyle(color: textColorLight),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
);

ThemeData darkTheme = ThemeData(
  primaryColor: primaryColor,
  colorScheme: ColorScheme.dark(
    primary: primaryColor,
    secondary: secondaryColor,
  ),
  backgroundColor: backgroundColorDark,
  scaffoldBackgroundColor: backgroundColorDark,
  textTheme: GoogleFonts.robotoTextTheme(
    TextTheme(
      headline1: TextStyle(color: textColorDark, fontFamily: 'Poppins', fontWeight: FontWeight.bold),
      headline2: TextStyle(color: textColorDark, fontFamily: 'Poppins', fontWeight: FontWeight.bold),
      bodyText1: TextStyle(color: textColorDark),
      bodyText2: TextStyle(color: textColorDark),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
);