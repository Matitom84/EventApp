import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';
import 'database_service.dart';
import '../models/event.dart';

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
  // SAUVEGARDER UNE RÉSERVATION DANS SUPABASE
// Appelée quand l'utilisateur confirme sa réservation
  static Future<bool> saveReservation({
    required String userPhone,
    required String eventId,
    required String eventTitle,
    required int numberOfPlaces,
  }) async {
    try {
      await _client.from('reservations').insert({
        'user_phone': userPhone,
        'event_id': eventId,
        'event_title': eventTitle,
        'number_of_places': numberOfPlaces,
        'reserved_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Erreur sauvegarde réservation: $e');
      return false;
    }
  }


// RÉCUPÉRER LES RÉSERVATIONS D'UN UTILISATEUR
  static Future<List<Map<String, dynamic>>> getReservations({
    required String userPhone,
  }) async {
    try {
      final response = await _client
          .from('reservations')
          .select()
          .eq('user_phone', userPhone)
          .order('reserved_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erreur récupération réservations: $e');
      return [];
    }
  }


// COMPTER LES RÉSERVATIONS D'UN UTILISATEUR
  static Future<int> countReservations({required String userPhone}) async {
    try {
      final response = await _client
          .from('reservations')
          .select()
          .eq('user_phone', userPhone);
      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }
  // CRÉER UN ÉVÉNEMENT DANS SUPABASE
  static Future<bool> createEvent({
    required String title,
    required String description,
    required String address,
    required String date,
    required double price,
    required int maxPlaces,
    required String organizerPhone,
  }) async {
    try {
      // on insère l'événement dans la table events
      await _client.from('events').insert({
        'title': title,
        'description': description,
        'address': address,
        'date': date,
        'price': price,
        'max_places': maxPlaces,
        'organizer_phone': organizerPhone,
      });
      return true;
    } catch (e) {
      print('Erreur création événement: $e');
      return false;
    }
  }
  // RÉCUPÉRER LES ÉVÉNEMENTS CRÉÉS PAR LES ORGANISATEURS
// on les convertit en objets Event pour les afficher comme les autres
  static Future<List<Event>> getCreatedEvents() async {
    try {
      // on récupère tous les événements depuis la table supabase
      final response = await _client
          .from('events')
          .select()
          .order('date', ascending: true);

      List<Event> events = [];

      // on parcourt chaque ligne et on crée un objet Event
      for (var row in response) {
        Event event = Event(
          id: 'sb_${row['id']}',
          title: row['title'] ?? '',
          description: row['description'] ?? '',
          address: row['address'] ?? '',
          imageUrl: '',
          date: DateTime.parse(row['date']),
          maxPlaces: row['max_places'] ?? 0,
          organizer: row['organizer_phone'] ?? '',
          source: 'supabase',
          url: '',
          price: (row['price'] ?? 0.0).toDouble(),
        );
        events.add(event);
      }

      return events;

    } catch (e) {
      print('Erreur récupération événements supabase: $e');
      return [];
    }
  }
}