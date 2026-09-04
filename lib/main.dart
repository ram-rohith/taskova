import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taskova/screens/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Taskova',
      themeMode: ThemeMode.system,
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: GoogleFonts.poppins().fontFamily,
        colorScheme: .fromSeed(
          seedColor: Colors.black38,
          brightness: .dark,
          primary: Color(0xFF81C784),
          error: Color(0xFFE57373),
        ),
      ),
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: GoogleFonts.poppins().fontFamily,
        colorScheme: .fromSeed(
          seedColor: Colors.white24,
          brightness: .light,
          primary: Color(0xFF2E7D32),
          error: Color(0xFFD32F2F),
        ),
      ),
      home: HomeScreen(),
    );
  }
}
