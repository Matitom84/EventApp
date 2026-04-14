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

  // Les champs de texte
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _codeSmsController = TextEditingController();
  final TextEditingController _codeOrganisateurController = TextEditingController();

  bool _chargement = false;    // true = spinner affiché
  bool _smsenvoye = false;     // false = étape 1, true = étape 2
  String _roleChoisi = 'client'; // rôle par défaut


  // ETAPE 1 : passe à l'étape 2 (mode test)
  Future<void> _envoyerSms() async {
    setState(() { _chargement = true; });
    setState(() { _smsenvoye = true; });
    setState(() { _chargement = false; });
  }


  // ETAPE 2 : vérifie le code et crée le compte
  Future<void> _creerCompte() async {
    setState(() { _chargement = true; }); // active le spinner

    // on envoie tout à Supabase pour créer le compte
    AppUser? utilisateur = await SupabaseService.verifyPhoneOtp(
      phone: _telephoneController.text.trim(),
      otp: _codeSmsController.text.trim(),
      name: _nomController.text.trim(),
      role: _roleChoisi,
    );

    setState(() { _chargement = false; }); // désactive le spinner

    if (utilisateur != null) {
      // compte créé → on va sur l'accueil sans pouvoir revenir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: utilisateur)),
      );
    } else {
      // code incorrect → message rouge
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
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Créer un compte', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── ETAPE 1 : infos + numéro ──
            if (!_smsenvoye) ...[

              // champ nom
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

              // champ téléphone
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

              // choix du rôle
              const Text('Je suis :'),
              const SizedBox(height: 12),

              Row(
                children: [

                  // bouton participant
                  Expanded(
                    child: GestureDetector(
                      onTap: () { setState(() { _roleChoisi = 'client'; }); },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          // fond bleu si sélectionné, transparent sinon
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

                  // bouton organisateur
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

              // champ code organisateur visible seulement si organisateur sélectionné
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

              const SizedBox(height: 32),

              // bouton pour passer à l'étape 2
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _chargement ? null : _envoyerSms,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A73E8),
                    foregroundColor: Colors.white,
                  ),
                  child: _chargement
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Continuer'),
                ),
              ),

              const SizedBox(height: 16),

              // lien vers la connexion
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Déjà un compte ? Se connecter'),
                ),
              ),
            ],

            // ── ETAPE 2 : saisie du code Supabase ──
            if (_smsenvoye) ...[

              // rappel du numéro
              Text('Code envoyé au ${_telephoneController.text}'),
              const SizedBox(height: 24),

              // champ pour taper le code
              const Text('Code à 6 chiffres'),
              const SizedBox(height: 8),
              TextField(
                controller: _codeSmsController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: '------',
                  counterText: '', // cache le compteur 0/6
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              // bouton pour créer le compte
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _chargement ? null : _creerCompte,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A73E8),
                    foregroundColor: Colors.white,
                  ),
                  child: _chargement
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Créer mon compte'),
                ),
              ),

              const SizedBox(height: 12),

              // bouton pour revenir à l'étape 1
              Center(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _smsenvoye = false; // retour étape 1
                      _codeSmsController.clear(); // vide le champ code
                    });
                  },
                  child: const Text('Retour'),
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