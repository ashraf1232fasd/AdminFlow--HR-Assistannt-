import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final appTheme = ThemeData(
  scaffoldBackgroundColor: const Color(0xFFE9EEF5),
  textTheme: GoogleFonts.poppinsTextTheme(),
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blueGrey,
    primary: const Color(0xFF1E3C72),
    secondary: const Color(0xFF2A5298),
  ),
  useMaterial3: true,
);
