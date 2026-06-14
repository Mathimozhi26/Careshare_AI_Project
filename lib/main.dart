import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const CareShareApp());
}

class CareShareApp extends StatelessWidget {
  const CareShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareShare AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFC9A84C),
          secondary: Color(0xFFC9A84C),
          surface: Color(0xFF141414),
          background: Color(0xFF0A0A0A),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A0A0A),
          foregroundColor: Color(0xFFF0EDE6),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(color: Color(0xFFF0EDE6), fontSize: 18, fontWeight: FontWeight.w600),
          systemOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC9A84C),
            foregroundColor: const Color(0xFF0A0A0A),
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5),
            elevation: 0,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFC9A84C), width: 1.5)),
          labelStyle: const TextStyle(color: Color(0xFF666666)),
          hintStyle: const TextStyle(color: Color(0xFF444444)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF111111),
          indicatorColor: const Color(0xFF1C1507),
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) return const TextStyle(color: Color(0xFFC9A84C), fontSize: 11, fontWeight: FontWeight.w600);
            return const TextStyle(color: Color(0xFF444444), fontSize: 11);
          }),
          iconTheme: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) return const IconThemeData(color: Color(0xFFC9A84C), size: 22);
            return const IconThemeData(color: Color(0xFF444444), size: 22);
          }),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
