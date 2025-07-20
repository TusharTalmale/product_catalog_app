import 'package:flutter/material.dart';
// Updated Light Mode Colors - More modern and vibrant
const Color kLightPrimaryColor = Color(0xFF4361EE); // Vibrant blue
const Color kLightAccentColor = Color(0xFF3A0CA3); // Deep purple-blue
const Color kLightBackgroundColor = Color(0xFFF8F9FA); // Very light grey
const Color kLightCardColor = Colors.white;
const Color kLightTextColor = Color(0xFF212529); // Dark grey for text
const Color kLightSecondaryTextColor = Color(0xFF495057); // Medium grey
const Color kLightSurfaceColor = Color(0xFFE9ECEF); // Light grey for surfaces
const Color kLightErrorColor = Color(0xFFE5383B); // Vibrant red for errors

// Updated Light Theme
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: kLightPrimaryColor,
  colorScheme: ColorScheme.light(
    primary: kLightPrimaryColor,
    secondary: kLightAccentColor,
    background: kLightBackgroundColor,
    surface: kLightCardColor,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: kLightTextColor,
    onSurface: kLightTextColor,
    error: kLightErrorColor,
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: kLightBackgroundColor,
  appBarTheme: AppBarTheme(
    backgroundColor: kLightPrimaryColor,
    foregroundColor: Colors.white,
    elevation: 2,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: kLightCardColor,
    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    surfaceTintColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kLightPrimaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      elevation: 1,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: kLightPrimaryColor,
      textStyle: TextStyle(fontWeight: FontWeight.w600),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: kLightPrimaryColor,
      side: BorderSide(color: kLightPrimaryColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: kLightPrimaryColor,
    foregroundColor: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: BorderSide(color: kLightSurfaceColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: BorderSide(color: kLightSurfaceColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: BorderSide(color: kLightPrimaryColor, width: 2),
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    hintStyle: TextStyle(color: kLightSecondaryTextColor),
    labelStyle: TextStyle(color: kLightPrimaryColor),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: kLightPrimaryColor,
    unselectedItemColor: Color(0xFF6C757D),
    selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
    unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
    elevation: 2,
    type: BottomNavigationBarType.fixed,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: kLightSurfaceColor,
    selectedColor: kLightPrimaryColor.withOpacity(0.2),
    labelStyle: TextStyle(color: kLightTextColor),
    secondaryLabelStyle: TextStyle(color: kLightPrimaryColor),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    side: BorderSide.none,
    padding: EdgeInsets.symmetric(horizontal: 8),
  ),
  dividerTheme: DividerThemeData(
    color: kLightSurfaceColor,
    thickness: 1,
    space: 1,
  ),
  // Enhanced Text Theme
  textTheme: TextTheme(
    displayLarge: TextStyle(
        color: kLightTextColor, fontSize: 32, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(
        color: kLightTextColor, fontSize: 28, fontWeight: FontWeight.bold),
    displaySmall: TextStyle(
        color: kLightTextColor, fontSize: 24, fontWeight: FontWeight.bold),
    headlineLarge: TextStyle(
        color: kLightTextColor, fontSize: 22, fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(
        color: kLightTextColor, fontSize: 20, fontWeight: FontWeight.bold),
    headlineSmall: TextStyle(
        color: kLightTextColor, fontSize: 18, fontWeight: FontWeight.bold),
    titleLarge: TextStyle(
        color: kLightTextColor, fontSize: 16, fontWeight: FontWeight.bold),
    titleMedium: TextStyle(
        color: kLightTextColor, fontSize: 14, fontWeight: FontWeight.bold),
    titleSmall: TextStyle(
        color: kLightTextColor, fontSize: 12, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(color: kLightTextColor, fontSize: 16),
    bodyMedium: TextStyle(color: kLightSecondaryTextColor, fontSize: 14),
    bodySmall: TextStyle(color: kLightSecondaryTextColor, fontSize: 12),
    labelLarge: TextStyle(
        color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
    labelMedium: TextStyle(
        color: kLightPrimaryColor, fontSize: 12, fontWeight: FontWeight.bold),
    labelSmall: TextStyle(
        color: kLightSecondaryTextColor, fontSize: 11),
  ),
);
// Dark Mode Colors
const Color kDarkPrimaryColor = Color(0xFFBB86FC); // Lighter Purple
const Color kDarkAccentColor = Color(0xFF03DAC6); // Teal (same as light for consistency)
const Color kDarkBackgroundColor = Color(0xFF121212); // Deep Dark Grey
const Color kDarkCardColor = Color(0xFF1E1E1E); // Slightly lighter dark grey for cards
const Color kDarkTextColor = Colors.white;
const Color kDarkSecondaryTextColor = Colors.white70;


// Dark Theme
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: kDarkPrimaryColor,
  colorScheme:const ColorScheme.dark(
    primary: kDarkPrimaryColor,
    secondary: kDarkAccentColor,
    background: kDarkBackgroundColor,
    surface: kDarkCardColor,
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onBackground: kDarkTextColor,
    onSurface: kDarkTextColor,
    error: Colors.redAccent,
    onError: Colors.black,
  ),
  scaffoldBackgroundColor: kDarkBackgroundColor,
  appBarTheme: const AppBarTheme(
    backgroundColor: kDarkBackgroundColor,
    foregroundColor: kDarkTextColor,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: kDarkTextColor,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  cardTheme: CardTheme(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: kDarkCardColor,
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kDarkPrimaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: kDarkAccentColor,
    foregroundColor: Colors.black,
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    ),
    filled: true,
    fillColor: Colors.grey[800], // Dark fill for text fields
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    hintStyle:const TextStyle(color: kDarkSecondaryTextColor),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: kDarkCardColor,
    selectedItemColor: kDarkPrimaryColor,
    unselectedItemColor: Colors.grey[400],
    selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
    elevation: 8,
  ),
  chipTheme: ChipThemeData(
    selectedColor: kDarkAccentColor.withOpacity(0.2),
    backgroundColor: Colors.grey[700],
    labelStyle:const TextStyle(color: kDarkTextColor),
    secondaryLabelStyle: TextStyle(color: kDarkPrimaryColor),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  sliderTheme: SliderThemeData(
    activeTrackColor: kDarkAccentColor,
    inactiveTrackColor: kDarkAccentColor.withOpacity(0.3),
    thumbColor: kDarkAccentColor,
    overlayColor: kDarkAccentColor.withOpacity(0.2),
    valueIndicatorColor: kDarkAccentColor,
    valueIndicatorTextStyle: const TextStyle(color: Colors.black),
  ),
  // Text themes for better control
  textTheme: const TextTheme(
    headlineLarge: TextStyle(color: kDarkTextColor, fontSize: 32, fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(color: kDarkTextColor, fontSize: 24, fontWeight: FontWeight.bold),
    headlineSmall: TextStyle(color: kDarkTextColor, fontSize: 20, fontWeight: FontWeight.bold),
    titleLarge: TextStyle(color: kDarkTextColor, fontSize: 22, fontWeight: FontWeight.bold),
    titleMedium: TextStyle(color: kDarkTextColor, fontSize: 18, fontWeight: FontWeight.bold),
    titleSmall: TextStyle(color: kDarkTextColor, fontSize: 16, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(color: kDarkTextColor, fontSize: 16),
    bodyMedium: TextStyle(color: kDarkSecondaryTextColor, fontSize: 14),
    bodySmall: TextStyle(color: kDarkSecondaryTextColor, fontSize: 12),
    labelLarge: TextStyle(color: kDarkTextColor, fontSize: 14, fontWeight: FontWeight.bold),
  ),
);
