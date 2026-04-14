import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../../models/user.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _codeSmsController = TextEditingController();

  bool _chargement = false;
  bool _smsenvoye = false;


  // ETAPE 1 : envoie le code SMS
  Future<void> _envoyerSms() async {
    setState(() { _chargement = true; });

    try {
      await Supabase.instance.client.auth.signInWithOtp(
        phone: _telephoneController.text.trim(),
      );
      setState(() { _smsenvoye = true; });
    } catch (erreur) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur, vérifiez votre numéro'), backgroundColor: Colors.red),
      );
    }

    setState(() { _chargement = false; });
  }


  // ETAPE 2 : vérifie le code et connecte l'utilisateur
  Future<void> _seConnecter() async {
    setState(() { _chargement = true; });

    AppUser? utilisateur = await SupabaseService.signInWithPhone(
      phone: _telephoneController.text.trim(),
      otp: _codeSmsController.text.trim(),
    );

    setState(() { _chargement = false; });

    if (utilisateur != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: utilisateur)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code incorrect ou expiré'), backgroundColor: Colors.red),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 60),

            const Center(
              child: Text('EventApp', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            ),

            const SizedBox(height: 40),

            // ── ETAPE 1 ──
            if (!_smsenvoye) ...[

              const Text('Numéro de téléphone'),
              const SizedBox(height: 8),
              TextField(
                controller: _telephoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: '+33685603968',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _chargement ? null : _envoyerSms,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A73E8), foregroundColor: Colors.white),
                  child: _chargement
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Recevoir le code SMS'),
                ),
              ),

              const SizedBox(height: 16),

              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                  },
                  child: const Text('Pas de compte ? S\'inscrire'),
                ),
              ),
            ],

            // ── ETAPE 2 ──
            if (_smsenvoye) ...[

              Text('Code envoyé au ${_telephoneController.text}'),
              const SizedBox(height: 16),

              const Text('Code à 6 chiffres'),
              const SizedBox(height: 8),
              TextField(
                controller: _codeSmsController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 10),
                decoration: const InputDecoration(
                  hintText: '------',
                  counterText: '',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _chargement ? null : _seConnecter,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A73E8), foregroundColor: Colors.white),
                  child: _chargement
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Se connecter'),
                ),
              ),

              const SizedBox(height: 12),

              Center(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _smsenvoye = false;
                      _codeSmsController.clear();
                    });
                  },
                  child: const Text('Renvoyer le code'),
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}