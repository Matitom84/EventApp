import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../../models/user.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

// page de connexion de l'app
// on utilise StatefulWidget car la page a 2 etapes qui changent
// etape 1 = on saisit son numéro de téléphone
// etape 2 = on saisit le code reçu par SMS
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  // TextEditingController permet de lire ce que l'utilisateur tape dans un champ
  // _phoneController = pour le champ numéro de téléphone
  TextEditingController _phoneController = TextEditingController();

  // _otpController = pour le champ code SMS
  TextEditingController _otpController = TextEditingController();

  // _isLoading = true quand on attend une réponse de Supabase
  // ca permet d'afficher un spinner à la place du bouton
  bool _isLoading = false;

  // _otpSent = false au départ (étape 1)
  // quand le SMS est envoyé on passe à true (étape 2)
  bool _otpSent = false;

  // _formKey sert à valider le formulaire
  // par exemple vérifier que le champ n'est pas vide
  final _formKey = GlobalKey<FormState>();

  // cette fonction est appelée quand on appuie sur "Recevoir le code SMS"
  // elle envoie le code OTP au numéro de téléphone
  Future<void> _sendOtp() async {

    // on vérifie que le champ numéro est bien rempli
    // si le formulaire n'est pas valide on s'arrête là
    if (!_formKey.currentState!.validate()) return;

    // on active le spinner
    setState(() {
      _isLoading = true;
    });

    // on appelle Supabase pour envoyer le SMS
    // trim() supprime les espaces avant et après le texte
    bool success = await SupabaseService.sendPhoneOtp(
      phone: _phoneController.text.trim(),
    );

    // on désactive le spinner
    setState(() {
      _isLoading = false;
    });

    // si le SMS a bien été envoyé
    if (success) {

      // on passe à l'étape 2 en mettant _otpSent à true
      // setState redessine la page avec la nouvelle valeur
      setState(() {
        _otpSent = true;
      });

      // on affiche un message vert en bas de l'écran
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code envoyé par SMS !'),
          backgroundColor: Colors.green,
        ),
      );

    } else {

      // si ca a raté on affiche un message rouge
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur, vérifiez votre numéro'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // cette fonction est appelée quand on appuie sur "Se connecter"
  // elle vérifie le code OTP et connecte l'utilisateur
  Future<void> _verifyOtp() async {

    // on vérifie que le champ code est bien rempli
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // on envoie le numéro et le code à Supabase pour vérification
    // si le code est bon, Supabase nous renvoie l'utilisateur connecté
    // si le code est faux, on reçoit null
    AppUser? user = await SupabaseService.signInWithPhone(
      phone: _phoneController.text.trim(),
      otp: _otpController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    // si user n'est pas null = connexion réussie
    if (user != null) {

      // on redirige vers la page d'accueil
      // pushReplacement remplace la page actuelle
      // donc l'utilisateur ne peut pas revenir en arrière
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
      );

    } else {

      // code faux ou expiré
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code incorrect ou expiré'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // dispose est appelé quand la page est fermée
  // on libère la mémoire des controllers pour éviter les fuites mémoire
  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // Scaffold = la structure de base d'une page Flutter
    return Scaffold(
      backgroundColor: Colors.white,

      // SafeArea évite que le contenu se cache derrière
      // la barre de statut en haut du téléphone
      body: SafeArea(

        // SingleChildScrollView permet de scroller si le clavier
        // pousse le contenu vers le haut
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),

          // Form regroupe tous les champs pour les valider ensemble
          child: Form(
            key: _formKey,

            // Column empile les widgets les uns sous les autres
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 60), // espace en haut

                // logo de l'app - un carré bleu avec une icône
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A73E8), // bleu
                      borderRadius: BorderRadius.circular(20), // coins arrondis
                    ),
                    child: const Icon(
                      Icons.event_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // nom de l'app
                const Center(
                  child: Text(
                    'EventApp',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // petit texte sous le titre qui change selon l'étape
                Center(
                  child: Text(
                    // si _otpSent est true on est à l'étape 2
                    _otpSent
                        ? 'Entrez le code reçu par SMS'
                        : 'Connectez-vous avec votre téléphone',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),

                const SizedBox(height: 40),

                // ─────────────────────────────────────
                // ÉTAPE 1 : saisie du numéro de téléphone
                // on affiche cette partie seulement si _otpSent = false
                // ─────────────────────────────────────
                if (!_otpSent) ...[

                  const Text('Numéro de téléphone'),
                  const SizedBox(height: 8),

                  // champ pour taper le numéro
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone, // clavier numérique
                    decoration: const InputDecoration(
                      hintText: '06 85 60 39 68',
                      prefixIcon: Icon(Icons.phone_outlined),
                      prefixText: '+33 ', // on affiche +33 avant le numéro
                      border: OutlineInputBorder(),
                    ),
                    // validator vérifie le champ quand on appuie sur le bouton
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre numéro';
                      }
                      return null; // null = pas d'erreur
                    },
                  ),

                  const SizedBox(height: 24),

                  // bouton pour recevoir le code SMS
                  SizedBox(
                    width: double.infinity, // prend toute la largeur
                    height: 50,
                    child: ElevatedButton(
                      // si _isLoading est true on désactive le bouton
                      onPressed: _isLoading ? null : _sendOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A73E8),
                        foregroundColor: Colors.white,
                      ),
                      // si ca charge on affiche un spinner sinon le texte
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Recevoir le code SMS'),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // lien pour aller sur la page d'inscription
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // push = on ajoute une page par dessus
                        // l'utilisateur peut revenir en arrière
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                      child: const Text(
                        'Pas de compte ? S\'inscrire',
                        style: TextStyle(color: Color(0xFF1A73E8)),
                      ),
                    ),
                  ),
                ],

                // ─────────────────────────────────────
                // ÉTAPE 2 : saisie du code OTP reçu par SMS
                // on affiche cette partie seulement si _otpSent = true
                // ─────────────────────────────────────
                if (_otpSent) ...[

                  // on affiche le numéro auquel on a envoyé le code
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FE), // bleu clair
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.sms_rounded, color: Color(0xFF1A73E8)),
                        const SizedBox(width: 10),
                        // on affiche le numéro tapé à l'étape 1
                        Text('Code envoyé au +33 ${_phoneController.text}'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text('Code à 6 chiffres'),
                  const SizedBox(height: 8),

                  // champ pour taper le code reçu par SMS
                  TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number, // clavier numérique
                    maxLength: 6, // on bloque à 6 caractères maximum
                    textAlign: TextAlign.center, // les chiffres sont centrés
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 10, // espace entre les chiffres
                    ),
                    decoration: const InputDecoration(
                      hintText: '------',
                      counterText: '', // on cache le compteur "0/6"
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Entrez le code';
                      }
                      // le code doit faire exactement 6 chiffres
                      if (value.length != 6) {
                        return 'Le code fait 6 chiffres';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // bouton pour valider le code et se connecter
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A73E8),
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Se connecter'),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // bouton pour revenir à l'étape 1 et renvoyer le code
                  Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _otpSent = false; // on revient à l'étape 1
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