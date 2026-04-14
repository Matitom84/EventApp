import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../../models/user.dart';
import '../home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _codeSmsController = TextEditingController();
  final TextEditingController _codeOrganisateurController = TextEditingController();

  bool _chargement = false;
  bool _smsenvoye = false;
  String _roleChoisi = 'client';


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


  // ETAPE 2 : vérifie le code et crée le compte
  Future<void> _creerCompte() async {
    setState(() { _chargement = true; });

    AppUser? utilisateur = await SupabaseService.verifyPhoneOtp(
      phone: _telephoneController.text.trim(),
      otp: _codeSmsController.text.trim(),
      name: _nomController.text.trim(),
      role: _roleChoisi,
    );

    setState(() { _chargement = false; });

    if (utilisateur != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: utilisateur)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code incorrect'), backgroundColor: Colors.red),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Créer un compte'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── ETAPE 1 ──
            if (!_smsenvoye) ...[

              const Text('Nom complet'),
              const SizedBox(height: 8),
              TextField(
                controller: _nomController,
                decoration: const InputDecoration(
                  hintText: 'Mathys Robert',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

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

              const SizedBox(height: 16),

              const Text('Je suis :'),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () { setState(() { _roleChoisi = 'client'; }); },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _roleChoisi == 'client' ? const Color(0xFFE8F0FE) : Colors.transparent,
                          border: Border.all(
                            color: _roleChoisi == 'client' ? const Color(0xFF1A73E8) : Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('Participant', textAlign: TextAlign.center),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: GestureDetector(
                      onTap: () { setState(() { _roleChoisi = 'organizer'; }); },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _roleChoisi == 'organizer' ? const Color(0xFFE8F0FE) : Colors.transparent,
                          border: Border.all(
                            color: _roleChoisi == 'organizer' ? const Color(0xFF1A73E8) : Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('Organisateur', textAlign: TextAlign.center),
                      ),
                    ),
                  ),
                ],
              ),

              if (_roleChoisi == 'organizer') ...[
                const SizedBox(height: 16),
                const Text('Code organisateur'),
                const SizedBox(height: 8),
                TextField(
                  controller: _codeOrganisateurController,
                  decoration: const InputDecoration(
                    hintText: 'Entrez le code',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],

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

              const SizedBox(height: 12),

              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Déjà un compte ? Se connecter'),
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
                  onPressed: _chargement ? null : _creerCompte,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A73E8), foregroundColor: Colors.white),
                  child: _chargement
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Créer mon compte'),
                ),
              ),

              const SizedBox(height: 12),

              Center(
                child: TextButton(
                  onPressed: () { setState(() { _smsenvoye = false; }); },
                  child: const Text('Renvoyer le code'),
                ),
              ),
            ],

          ],
        ),
      ),
    );
  }
}