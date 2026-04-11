import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';
import 'database_service.dart';

class SupabaseService {

  static final _client = Supabase.instance.client;

  // Formate le numéro de téléphone
  // Ex: "0685603968" → "33685603968"
  static String _formatPhone(String phone) {
    phone = phone.replaceAll(' ', '').replaceAll('-', '');
    if (phone.startsWith('0')) {
      return '33${phone.substring(1)}';
    }
    if (phone.startsWith('+33')) {
      return phone.substring(1);
    }
    return phone;
  }


  // VÉRIFIE SI LE NUMÉRO EXISTE DÉJÀ DANS LA TABLE PROFILES
  // Retourne true si le numéro est déjà utilisé
  static Future<bool> phoneExists(String phone) async {
    try {
      final formattedPhone = _formatPhone(phone);
      final response = await _client
          .from('profiles')
          .select()
          .eq('phone', formattedPhone)
          .maybeSingle();
      // maybeSingle() retourne null si aucun résultat
      // Si on trouve quelque chose → le numéro existe déjà
      return response != null;
    } catch (e) {
      print('Erreur vérification numéro: $e');
      return false;
    }
  }


  // ENVOI DU CODE SMS
  static Future<bool> sendPhoneOtp({required String phone}) async {
    try {
      final formattedPhone = _formatPhone(phone);
      await _client.auth.signInWithOtp(phone: '+$formattedPhone');
      return true;
    } catch (e) {
      print('Erreur envoi OTP: $e');
      return false;
    }
  }


  // INSCRIPTION — crée le compte ET sauvegarde dans profiles
  static Future<AppUser?> verifyPhoneOtp({
    required String phone,
    required String otp,
    required String name,
    required String role,
  }) async {
    try {
      final formattedPhone = _formatPhone(phone);

      // On vérifie si le numéro existe déjà
      final exists = await phoneExists(phone);
      if (exists) {
        // Le numéro est déjà utilisé — on retourne null
        print('Numéro déjà utilisé');
        return null;
      }

      final response = await _client.auth.verifyOTP(
        phone: '+$formattedPhone',
        token: otp,
        type: OtpType.sms,
      );

      if (response.user == null) return null;

      // On met à jour les metadata Supabase
      await _client.auth.updateUser(
        UserAttributes(
          data: {
            'name': name,
            'phone': formattedPhone,
            'role': role,
          },
        ),
      );

      // On sauvegarde dans la table profiles pour éviter les doublons
      await _client.from('profiles').insert({
        'phone': formattedPhone,
        'name': name,
        'role': role,
      });

      final user = AppUser(
        id: response.user!.id,
        email: response.user!.email ?? '',
        name: name,
        role: role,
        phone: formattedPhone,
        createdAt: DateTime.now(),
      );

      await DatabaseService.saveUser(user);
      return user;

    } catch (e) {
      print('Erreur inscription: $e');
      return null;
    }
  }


  // CONNEXION — récupère le profil depuis la table profiles
  static Future<AppUser?> signInWithPhone({
    required String phone,
    required String otp,
  }) async {
    try {
      final formattedPhone = _formatPhone(phone);

      final response = await _client.auth.verifyOTP(
        phone: '+$formattedPhone',
        token: otp,
        type: OtpType.sms,
      );

      if (response.user == null) return null;

      // On récupère le profil depuis la table profiles
      // C'est ici qu'on retrouve le vrai nom et rôle de l'utilisateur
      final profile = await _client
          .from('profiles')
          .select()
          .eq('phone', formattedPhone)
          .maybeSingle();

      final user = AppUser(
        id: response.user!.id,
        email: response.user!.email ?? '',
        name: profile?['name'] ?? 'Utilisateur',
        role: profile?['role'] ?? 'client',
        phone: formattedPhone,
        createdAt: DateTime.parse(response.user!.createdAt),
      );

      await DatabaseService.saveUser(user);
      return user;

    } catch (e) {
      print('Erreur connexion: $e');
      return null;
    }
  }


  // DÉCONNEXION
  static Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      await DatabaseService.deleteUser();
    } catch (e) {
      print('Erreur déconnexion: $e');
    }
  }


  // VÉRIFIER SI QUELQU'UN EST CONNECTÉ
  static Future<bool> isLoggedIn() async {
    final session = _client.auth.currentSession;
    if (session != null) return true;
    final localUser = await DatabaseService.getUser();
    return localUser != null;
  }


  // RÉCUPÉRER L'UTILISATEUR CONNECTÉ
  static Future<AppUser?> getCurrentUser() async {
    final supabaseUser = _client.auth.currentUser;
    if (supabaseUser != null) {
      final metadata = supabaseUser.userMetadata ?? {};
      return AppUser(
        id: supabaseUser.id,
        email: supabaseUser.email ?? '',
        name: metadata['name'] ?? 'Utilisateur',
        role: metadata['role'] ?? 'client',
        phone: metadata['phone'] ?? '',
        createdAt: DateTime.parse(supabaseUser.createdAt),
      );
    }
    return await DatabaseService.getUser();
  }
}