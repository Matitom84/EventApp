import 'package:flutter/material.dart'; // import flutter pour les widgets
import '../../services/supabase_service.dart'; // pour envoyer le sms et verifier le code
import '../../models/user.dart'; // le modele AppUser
import '../home/home_screen.dart'; // la page d'accueil
import 'register_screen.dart'; // la page d'inscription

// page de connexion - 2 etapes
// etape 1 = numero / etape 2 = code sms
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  TextEditingController _phoneController = TextEditingController(); // lit le numero tape
  TextEditingController _otpController = TextEditingController(); // lit le code tape

  bool _isLoading = false; // true = on attend supabase, affiche spinner
  bool _otpSent = false; // false = etape 1, true = etape 2
  final _formKey = GlobalKey<FormState>(); // pour valider les champs

  Future<void> _sendOtp() async { // envoie le code sms
    if (!_formKey.currentState!.validate()) return; // stop si champ vide
    setState(() { _isLoading = true; }); // active le spinner

    bool success = await SupabaseService.sendPhoneOtp( // appel supabase
      phone: _phoneController.text.trim(), // numero sans espaces
    );

    setState(() { _isLoading = false; }); // desactive le spinner

    if (success) { // si le sms est parti
      setState(() { _otpSent = true; }); // on passe a l'etape 2
      ScaffoldMessenger.of(context).showSnackBar( // message vert en bas
        const SnackBar(content: Text('Code envoyé !'), backgroundColor: Colors.green),
      );
    } else { // si ca a rate
      ScaffoldMessenger.of(context).showSnackBar( // message rouge en bas
        const SnackBar(content: Text('Erreur, vérifiez votre numéro'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _verifyOtp() async { // verifie le code sms
    if (!_formKey.currentState!.validate()) return; // stop si champ vide
    setState(() { _isLoading = true; }); // active le spinner

    AppUser? user = await SupabaseService.signInWithPhone( // on envoie le code a supabase
      phone: _phoneController.text.trim(), // numero sans espaces
      otp: _otpController.text.trim(), // code sans espaces
    ); // user = null si le code est faux

    setState(() { _isLoading = false; }); // desactive le spinner

    if (user != null) { // connexion reussie
      Navigator.pushReplacement( // on va sur l'accueil sans pouvoir revenir
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: user)), // on passe l'user a l'accueil
      );
    } else { // code faux
      ScaffoldMessenger.of(context).showSnackBar( // message rouge
        const SnackBar(content: Text('Code incorrect ou expiré'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() { // appelé quand la page se ferme
    _phoneController.dispose(); // libere la memoire
    _otpController.dispose(); // libere la memoire
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea( // evite que le contenu se cache derriere la barre en haut
        child: SingleChildScrollView( // permet de scroller si le clavier pousse le contenu
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey, // lie le formulaire a la cle de validation
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 60), // espace en haut

                Center(
                  child: Container( // logo de l'app
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A73E8), // bleu
                      borderRadius: BorderRadius.circular(20), // coins arrondis
                    ),
                    child: const Icon(Icons.event_rounded, color: Colors.white, size: 36),
                  ),
                ),

                const SizedBox(height: 20),

                const Center(
                  child: Text('EventApp', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)), // titre
                ),

                const SizedBox(height: 8),

                Center(
                  child: Text( // sous titre qui change selon l'etape
                    _otpSent ? 'Entrez le code reçu par SMS' : 'Connectez-vous avec votre téléphone',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),

                const SizedBox(height: 40),

                if (!_otpSent) ...[ // etape 1 visible si _otpSent = false

                  const Text('Numéro de téléphone'),
                  const SizedBox(height: 8),

                  TextFormField( // champ numero
                    controller: _phoneController, // lie le champ au controller
                    keyboardType: TextInputType.phone, // clavier numerique
                    decoration: const InputDecoration(
                      hintText: '06 85 60 39 68',
                      prefixIcon: Icon(Icons.phone_outlined),
                      prefixText: '+33 ', // affiche +33 avant le numero
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) { // verifie que le champ est rempli
                      if (value == null || value.isEmpty) return 'Veuillez entrer votre numéro';
                      return null; // null = pas d'erreur
                    },
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity, // prend toute la largeur
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendOtp, // desactive si chargement
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A73E8),
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading // spinner si chargement sinon texte
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Recevoir le code SMS'),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Center(
                    child: TextButton( // lien vers l'inscription
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                      },
                      child: const Text('Pas de compte ? S\'inscrire', style: TextStyle(color: Color(0xFF1A73E8))),
                    ),
                  ),
                ],

                if (_otpSent) ...[ // etape 2 visible si _otpSent = true

                  Container( // rappel du numero
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FE), // bleu clair
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.sms_rounded, color: Color(0xFF1A73E8)),
                        const SizedBox(width: 10),
                        Text('Code envoyé au +33 ${_phoneController.text}'), // affiche le numero tape
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text('Code à 6 chiffres'),
                  const SizedBox(height: 8),

                  TextFormField( // champ code sms
                    controller: _otpController,
                    keyboardType: TextInputType.number, // clavier numerique
                    maxLength: 6, // max 6 caracteres
                    textAlign: TextAlign.center, // chiffres centres
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 10), // espace entre chiffres
                    decoration: const InputDecoration(
                      hintText: '------',
                      counterText: '', // cache le compteur 0/6
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Entrez le code';
                      if (value.length != 6) return 'Le code fait 6 chiffres'; // doit faire exactement 6
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyOtp, // desactive si chargement
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

                  Center(
                    child: TextButton( // renvoyer le code = retour etape 1
                      onPressed: () {
                        setState(() {
                          _otpSent = false; // retour etape 1
                          _otpController.clear(); // vide le champ code
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