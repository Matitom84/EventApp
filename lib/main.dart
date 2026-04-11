import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // On force l'orientation portrait — plus propre sur mobile
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Barre de statut transparente — effet moderne
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await Supabase.initialize(
    url: 'https://jxrmuctztdiobgpptxeb.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp4cm11Y3R6dGRpb2JncHB0eGViIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU4NTc0MzgsImV4cCI6MjA5MTQzMzQzOH0.YrbMbtYBf9gzktxaCCc4Yw0AgTGYBSYZ9nIfHK--XgA',
  );

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EventApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // COULEUR PRINCIPALE — Bleu moderne
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A73E8),
          // 0xFF1A73E8 = le bleu Google — moderne et propre
          brightness: Brightness.light,
        ),
        // POLICE — on garde la police par défaut de Flutter
        // qui est déjà propre et lisible

        // BOUTONS
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A73E8),
            foregroundColor: Colors.white,
            elevation: 0,
            // elevation 0 = pas d'ombre — style plat moderne
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),

        // CHAMPS DE SAISIE
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          // Fond légèrement grisé — moderne
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF1A73E8),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),

        // CARTES
        cardTheme: CardThemeData(
          elevation: 0,
          // Pas d'ombre — style moderne flat
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
            // Bordure légère au lieu d'une ombre
          ),
          color: Colors.white,
        ),

        // APP BAR
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1A1A1A),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        // SCAFFOLD
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        // Fond légèrement grisé — plus doux que le blanc pur
      ),
      home: const LoginScreen(),
    );
  }
}