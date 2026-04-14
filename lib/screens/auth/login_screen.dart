import 'package:flutter/material.dart';
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

  // Les champs de texte
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _codeSmsController = TextEditingController();

  bool _chargement = false;
  bool _smsenvoye = false;


  // ETAPE 1 : passe directement à l'étape 2 (mode test)
  Future<void> _envoyerSms() async {
    setState(() { _smsenvoye = true; });
  }


  // ETAPE 2 : vérifie le code Supabase et connecte l'utilisateur
  Future<void> _seConnecter() async {
    setState(() { _chargement = true; }); // active le spinner

    // on envoie le numéro et le code à Supabase pour vérification
    AppUser? utilisateur = await SupabaseService.signInWithPhone(
      phone: _telephoneController.text.trim(),
      otp: _codeSmsController.text.trim(),
    );

    setState(() { _chargement = false; }); // désactive le spinner

    if (utilisateur != null) {
      // connexion réussie → on va sur l'accueil
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: utilisateur)),
      );
    } else {
      // code incorrect → message rouge en bas
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code incorrect'), backgroundColor: Colors.red),
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

            // titre de l'app
            const Center(
              child: Text('EventApp', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            ),

            const SizedBox(height: 40),

            // ── ETAPE 1 : saisie du numéro ──
            if (!_smsenvoye) ...[

              const Text('Numéro de téléphone'),
              const SizedBox(height: 8),

              // champ pour taper le numéro
              TextField(
                controller: _telephoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: '+33685603968',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              // bouton pour passer à l'étape 2
              ElevatedButton(
                onPressed: _envoyerSms,
                child: const Text('Continuer'),
              ),

              // lien vers l'inscription
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                },
                child: const Text('Pas de compte ? S\'inscrire'),
              ),
            ],

            // ── ETAPE 2 : saisie du code ──
            if (_smsenvoye) ...[

              const Text('Code à 6 chiffres'),
              const SizedBox(height: 8),

              // champ pour taper le code Supabase
              TextField(
                controller: _codeSmsController,
                maxLength: 6,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: '------',
                  counterText: '', // cache le compteur 0/6
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              // bouton pour se connecter
              ElevatedButton(
                onPressed: _chargement ? null : _seConnecter,
                child: _chargement
                    ? const CircularProgressIndicator() // spinner si chargement
                    : const Text('Se connecter'),
              ),

              // bouton pour revenir à l'étape 1
              TextButton(
                onPressed: () {
                  setState(() {
                    _smsenvoye = false;
                    _codeSmsController.clear(); // vide le champ code
                  });
                },
                child: const Text('Retour'),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}