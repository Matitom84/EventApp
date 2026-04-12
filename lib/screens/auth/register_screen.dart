import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../../models/user.dart';
import '../home/home_screen.dart';

// page d'inscription
// comme la page de connexion, on a 2 étapes
// étape 1 = on remplit ses infos et son numéro
// étape 2 = on entre le code reçu par SMS
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  // controllers pour lire ce que l'utilisateur tape
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _otpController = TextEditingController();

  // variables d'état
  bool _isLoading = false; // true = on attend supabase
  bool _otpSent = false; // false = étape 1, true = étape 2

  // le rôle choisi par l'utilisateur, "client" par défaut
  String _selectedRole = 'client';

  // pour valider le formulaire
  final _formKey = GlobalKey<FormState>();

  // étape 1 : on envoie le code SMS au numéro tapé
  Future<void> _sendOtp() async {

    // on vérifie que tous les champs sont remplis
    if (!_formKey.currentState!.validate()) return;

    // on active le spinner
    setState(() {
      _isLoading = true;
    });

    // on demande à supabase d'envoyer le SMS
    bool success = await SupabaseService.sendPhoneOtp(
      phone: _phoneController.text.trim(),
    );

    // on désactive le spinner
    setState(() {
      _isLoading = false;
    });

    // si le SMS est bien parti
    if (success) {

      // on passe à l'étape 2
      setState(() {
        _otpSent = true;
      });

      // message de confirmation en vert
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code envoyé par SMS !'),
          backgroundColor: Colors.green,
        ),
      );

    } else {

      // message d'erreur en rouge
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur, vérifiez votre numéro'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // étape 2 : on vérifie le code et on crée le compte
  Future<void> _verifyAndRegister() async {

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // on envoie tout à supabase pour créer le compte
    // si le code est bon on reçoit l'utilisateur créé
    // si le numéro est déjà utilisé ou le code faux on reçoit null
    AppUser? user = await SupabaseService.verifyPhoneOtp(
      phone: _phoneController.text.trim(),
      otp: _otpController.text.trim(),
      name: _nameController.text.trim(),
      role: _selectedRole,
    );

    setState(() {
      _isLoading = false;
    });

    // si le compte est créé on va sur la page d'accueil
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
      );
    } else {

      // erreur : numéro déjà utilisé ou code faux
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Numéro déjà utilisé ou code incorrect'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // on libère la mémoire quand la page est fermée
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // flèche retour pour revenir à la page de connexion
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Créer un compte',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ─────────────────────────────
                // ÉTAPE 1 : infos + numéro
                // visible seulement si _otpSent = false
                // ─────────────────────────────
                if (!_otpSent) ...[

                  // champ nom complet
                  const Text('Nom complet'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    // met la première lettre de chaque mot en majuscule
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      hintText: 'Mathys Robert',
                      prefixIcon: Icon(Icons.person_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ce champ est obligatoire';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // champ numéro de téléphone
                  const Text('Numéro de téléphone'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: '06 85 60 39 68',
                      prefixIcon: Icon(Icons.phone_outlined),
                      prefixText: '+33 ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ce champ est obligatoire';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // choix du rôle : participant ou organisateur
                  const Text('Je suis :'),
                  const SizedBox(height: 12),

                  // deux boutons côte à côte pour choisir le rôle
                  Row(
                    children: [

                      // bouton participant
                      Expanded(
                        child: GestureDetector(
                          // quand on tape dessus on sélectionne "client"
                          onTap: () {
                            setState(() {
                              _selectedRole = 'client';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              // fond bleu clair si sélectionné sinon transparent
                              color: _selectedRole == 'client'
                                  ? const Color(0xFFE8F0FE)
                                  : Colors.transparent,
                              border: Border.all(
                                // bordure bleue si sélectionné sinon grise
                                color: _selectedRole == 'client'
                                    ? const Color(0xFF1A73E8)
                                    : Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                // icône bleue si sélectionné sinon grise
                                Icon(
                                  Icons.person_rounded,
                                  color: _selectedRole == 'client'
                                      ? const Color(0xFF1A73E8)
                                      : Colors.grey,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Participant',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: _selectedRole == 'client'
                                        ? const Color(0xFF1A73E8)
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // bouton organisateur
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedRole = 'organizer';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _selectedRole == 'organizer'
                                  ? const Color(0xFFE8F0FE)
                                  : Colors.transparent,
                              border: Border.all(
                                color: _selectedRole == 'organizer'
                                    ? const Color(0xFF1A73E8)
                                    : Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.event_rounded,
                                  color: _selectedRole == 'organizer'
                                      ? const Color(0xFF1A73E8)
                                      : Colors.grey,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Organisateur',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: _selectedRole == 'organizer'
                                        ? const Color(0xFF1A73E8)
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // bouton pour recevoir le code SMS
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A73E8),
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Recevoir le code SMS'),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // lien pour revenir à la connexion
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Déjà un compte ? Se connecter',
                        style: TextStyle(color: Color(0xFF1A73E8)),
                      ),
                    ),
                  ),
                ],

                // ─────────────────────────────
                // ÉTAPE 2 : saisie du code OTP
                // visible seulement si _otpSent = true
                // ─────────────────────────────
                if (_otpSent) ...[

                  // on rappelle le numéro auquel on a envoyé le code
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.sms_rounded, color: Color(0xFF1A73E8)),
                        const SizedBox(width: 10),
                        Text('Code envoyé au +33 ${_phoneController.text}'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // champ pour taper le code à 6 chiffres
                  const Text('Code à 6 chiffres'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6, // maximum 6 caractères
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 10, // espace entre les chiffres
                    ),
                    decoration: const InputDecoration(
                      hintText: '------',
                      counterText: '', // cache le compteur 0/6
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Entrez le code';
                      }
                      if (value.length != 6) {
                        return 'Le code fait 6 chiffres';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // bouton pour créer le compte
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyAndRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A73E8),
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Créer mon compte'),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // bouton pour renvoyer le code et revenir à l'étape 1
                  Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _otpSent = false; // retour à l'étape 1
                          _otpController.clear(); // on vide le champ code
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
        ),
      ),
    );
  }
}