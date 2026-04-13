import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../../models/user.dart';
import '../home/home_screen.dart';

// page d'inscription - 2 etapes
// etape 1 = nom + numero + role
// etape 2 = code sms
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  // pour lire ce que l'user tape
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _otpController = TextEditingController();

  bool _isLoading = false;
  bool _otpSent = false;
  String _selectedRole = 'client'; // role par defaut
  final _formKey = GlobalKey<FormState>();

  // envoie le sms
  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; });

    bool success = await SupabaseService.sendPhoneOtp(
      phone: _phoneController.text.trim(),
    );

    setState(() { _isLoading = false; });

    if (success) {
      setState(() { _otpSent = true; });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code envoyé !'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur, vérifiez votre numéro'), backgroundColor: Colors.red),
      );
    }
  }

  // verifie le code et cree le compte
  Future<void> _verifyAndRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; });

    // si le code est bon on recoit l'user cree, sinon null
    AppUser? user = await SupabaseService.verifyPhoneOtp(
      phone: _phoneController.text.trim(),
      otp: _otpController.text.trim(),
      name: _nameController.text.trim(),
      role: _selectedRole,
    );

    setState(() { _isLoading = false; });

    if (user != null) {
      // compte cree on va sur l'accueil
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Numéro déjà utilisé ou code incorrect'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    // liberation memoire
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Créer un compte', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // etape 1 : infos + numero
                if (!_otpSent) ...[

                  // champ nom
                  const Text('Nom complet'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      hintText: 'Mathys Robert',
                      prefixIcon: Icon(Icons.person_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Champ obligatoire';
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // champ telephone
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
                      if (value == null || value.isEmpty) return 'Champ obligatoire';
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // choix du role
                  const Text('Je suis :'),
                  const SizedBox(height: 12),

                  Row(
                    children: [

                      // bouton participant
                      Expanded(
                        child: GestureDetector(
                          onTap: () { setState(() { _selectedRole = 'client'; }); },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              // bleu si selectionne sinon transparent
                              color: _selectedRole == 'client' ? const Color(0xFFE8F0FE) : Colors.transparent,
                              border: Border.all(
                                color: _selectedRole == 'client' ? const Color(0xFF1A73E8) : Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.person_rounded,
                                    color: _selectedRole == 'client' ? const Color(0xFF1A73E8) : Colors.grey),
                                const SizedBox(height: 4),
                                Text('Participant',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: _selectedRole == 'client' ? const Color(0xFF1A73E8) : Colors.grey,
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // bouton organisateur
                      Expanded(
                        child: GestureDetector(
                          onTap: () { setState(() { _selectedRole = 'organizer'; }); },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _selectedRole == 'organizer' ? const Color(0xFFE8F0FE) : Colors.transparent,
                              border: Border.all(
                                color: _selectedRole == 'organizer' ? const Color(0xFF1A73E8) : Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.event_rounded,
                                    color: _selectedRole == 'organizer' ? const Color(0xFF1A73E8) : Colors.grey),
                                const SizedBox(height: 4),
                                Text('Organisateur',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: _selectedRole == 'organizer' ? const Color(0xFF1A73E8) : Colors.grey,
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

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

                  // retour connexion
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Déjà un compte ? Se connecter', style: TextStyle(color: Color(0xFF1A73E8))),
                    ),
                  ),
                ],

                // etape 2 : code sms
                if (_otpSent) ...[

                  // rappel du numero
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
                  const Text('Code à 6 chiffres'),
                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 10),
                    decoration: const InputDecoration(
                      hintText: '------',
                      counterText: '', // cache le compteur
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Entrez le code';
                      if (value.length != 6) return 'Le code fait 6 chiffres';
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

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

                  // renvoyer le code
                  Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _otpSent = false;
                          _otpController.clear();
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