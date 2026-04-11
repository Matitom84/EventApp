import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../../models/user.dart';
import '../home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _otpSent = false;
  String _selectedRole = 'client';
  final _formKey = GlobalKey<FormState>();


  // ÉTAPE 1 — Envoyer le code SMS
  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final success = await SupabaseService.sendPhoneOtp(
      phone: _phoneController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success) {
      setState(() => _otpSent = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Code envoyé par SMS !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur — vérifiez votre numéro'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  // ÉTAPE 2 — Vérifier le code et créer le compte
  Future<void> _verifyAndRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final AppUser? user = await SupabaseService.verifyPhoneOtp(
      phone: _phoneController.text.trim(),
      otp: _otpController.text.trim(),
      name: _nameController.text.trim(),
      role: _selectedRole,
    );

    setState(() => _isLoading = false);

    if (user != null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ce numéro est déjà utilisé ou code incorrect'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Créer un compte',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.bold,
          ),
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

                // ÉTAPE 1 — INFOS + NUMÉRO
                if (!_otpSent) ...[

                  const Text('Nom complet',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      hintText: 'Mathys Robert',
                      prefixIcon: Icon(Icons.person_outlined,
                          color: Colors.grey),
                    ),
                    validator: (v) =>
                    v == null || v.isEmpty ? 'Champ obligatoire' : null,
                  ),

                  const SizedBox(height: 20),

                  const Text('Numéro de téléphone',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: '06 85 60 39 68',
                      prefixIcon: Icon(Icons.phone_outlined,
                          color: Colors.grey),
                      prefixText: '+33 ',
                    ),
                    validator: (v) =>
                    v == null || v.isEmpty ? 'Champ obligatoire' : null,
                  ),

                  const SizedBox(height: 24),

                  // CHOIX DU RÔLE
                  const Text('Je suis :',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedRole = 'client'),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _selectedRole == 'client'
                                  ? const Color(0xFFE8F0FE)
                                  : Colors.transparent,
                              border: Border.all(
                                color: _selectedRole == 'client'
                                    ? const Color(0xFF1A73E8)
                                    : Colors.grey.shade300,
                                width: _selectedRole == 'client' ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.person_rounded,
                                    color: _selectedRole == 'client'
                                        ? const Color(0xFF1A73E8)
                                        : Colors.grey),
                                const SizedBox(height: 4),
                                Text('Participant',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: _selectedRole == 'client'
                                          ? const Color(0xFF1A73E8)
                                          : Colors.grey,
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedRole = 'organizer'),
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
                                width: _selectedRole == 'organizer' ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.event_rounded,
                                    color: _selectedRole == 'organizer'
                                        ? const Color(0xFF1A73E8)
                                        : Colors.grey),
                                const SizedBox(height: 4),
                                Text('Organisateur',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: _selectedRole == 'organizer'
                                          ? const Color(0xFF1A73E8)
                                          : Colors.grey,
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
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A73E8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
                        'Recevoir le code SMS',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                ],

                // ÉTAPE 2 — CODE OTP
                if (_otpSent) ...[

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.sms_rounded,
                            color: Color(0xFF1A73E8), size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'Code envoyé au +33 ${_phoneController.text}',
                          style: const TextStyle(
                            color: Color(0xFF1A73E8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text('Code à 6 chiffres',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 10,
                    ),
                    decoration: const InputDecoration(
                      hintText: '------',
                      counterText: '',
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Entrez le code reçu par SMS';
                      }
                      if (v.length != 6) return 'Code à 6 chiffres';
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyAndRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A73E8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
                        'Créer mon compte',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Center(
                    child: TextButton(
                      onPressed: () => setState(() {
                        _otpSent = false;
                        _otpController.clear();
                      }),
                      child: const Text(
                        'Renvoyer le code',
                        style: TextStyle(color: Color(0xFF1A73E8)),
                      ),
                    ),
                  ),

                ],

                const SizedBox(height: 16),

                if (!_otpSent)
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Déjà un compte ? Se connecter',
                        style: TextStyle(color: Color(0xFF1A73E8)),
                      ),
                    ),
                  ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}