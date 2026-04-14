import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';
import 'database_service.dart';
import '../models/event.dart';

class SupabaseService {

  static final _client = Supabase.instance.client;


  // INSCRIPTION
  static Future<AppUser?> verifyPhoneOtp({
    required String phone,
    required String otp,
    required String name,
    required String role,
  }) async {
    try {
      final reponse = await _client.auth.verifyOTP(
        phone: phone,
        token: otp,
        type: OtpType.sms,
      );

      if (reponse.user == null) return null;

      await _client.auth.updateUser(
        UserAttributes(data: {'name': name, 'phone': phone, 'role': role}),
      );

      await _client.from('profiles').insert({
        'phone': phone,
        'name': name,
        'role': role,
      });

      final utilisateur = AppUser(
        id: reponse.user!.id,
        email: reponse.user!.email ?? '',
        name: name,
        role: role,
        phone: phone,
        createdAt: DateTime.now(),
      );

      await DatabaseService.saveUser(utilisateur);
      return utilisateur;

    } catch (erreur) {
      print('Erreur inscription: $erreur');
      return null;
    }
  }


  // CONNEXION
  static Future<AppUser?> signInWithPhone({
    required String phone,
    required String otp,
  }) async {
    try {
      final reponse = await _client.auth.verifyOTP(
        phone: phone,
        token: otp,
        type: OtpType.sms,
      );

      if (reponse.user == null) return null;

      final profil = await _client
          .from('profiles')
          .select()
          .eq('phone', phone)
          .maybeSingle();

      final utilisateur = AppUser(
        id: reponse.user!.id,
        email: reponse.user!.email ?? '',
        name: profil?['name'] ?? 'Utilisateur',
        role: profil?['role'] ?? 'client',
        phone: phone,
        createdAt: DateTime.parse(reponse.user!.createdAt),
      );

      await DatabaseService.saveUser(utilisateur);
      return utilisateur;

    } catch (erreur) {
      print('Erreur connexion: $erreur');
      return null;
    }
  }


  // DÉCONNEXION
  static Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      await DatabaseService.deleteUser();
    } catch (erreur) {
      print('Erreur déconnexion: $erreur');
    }
  }


  // Vérifie si quelqu'un est connecté
  static Future<bool> isLoggedIn() async {
    final session = _client.auth.currentSession;
    if (session != null) return true;
    final utilisateurLocal = await DatabaseService.getUser();
    return utilisateurLocal != null;
  }


  // Récupère l'utilisateur connecté
  static Future<AppUser?> getCurrentUser() async {
    final utilisateurSupabase = _client.auth.currentUser;
    if (utilisateurSupabase != null) {
      final metadata = utilisateurSupabase.userMetadata ?? {};
      return AppUser(
        id: utilisateurSupabase.id,
        email: utilisateurSupabase.email ?? '',
        name: metadata['name'] ?? 'Utilisateur',
        role: metadata['role'] ?? 'client',
        phone: metadata['phone'] ?? '',
        createdAt: DateTime.parse(utilisateurSupabase.createdAt),
      );
    }
    return await DatabaseService.getUser();
  }


  // Sauvegarde une réservation
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
    } catch (erreur) {
      print('Erreur sauvegarde réservation: $erreur');
      return false;
    }
  }


  // Récupère les réservations d'un utilisateur
  static Future<List<Map<String, dynamic>>> getReservations({
    required String userPhone,
  }) async {
    try {
      final reponse = await _client
          .from('reservations')
          .select()
          .eq('user_phone', userPhone)
          .order('reserved_at', ascending: false);
      return List<Map<String, dynamic>>.from(reponse);
    } catch (erreur) {
      print('Erreur récupération réservations: $erreur');
      return [];
    }
  }


  // Compte les réservations d'un utilisateur
  static Future<int> countReservations({required String userPhone}) async {
    try {
      final reponse = await _client
          .from('reservations')
          .select()
          .eq('user_phone', userPhone);
      return (reponse as List).length;
    } catch (erreur) {
      return 0;
    }
  }


  // Crée un événement
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
    } catch (erreur) {
      print('Erreur création événement: $erreur');
      return false;
    }
  }


  // Récupère les événements créés par les organisateurs
  static Future<List<Event>> getCreatedEvents() async {
    try {
      final reponse = await _client
          .from('events')
          .select()
          .order('date', ascending: true);

      final List<Event> evenements = [];
      for (var ligne in reponse) {
        evenements.add(Event(
          id: 'sb_${ligne['id']}',
          title: ligne['title'] ?? '',
          description: ligne['description'] ?? '',
          address: ligne['address'] ?? '',
          imageUrl: '',
          date: DateTime.parse(ligne['date']),
          maxPlaces: ligne['max_places'] ?? 0,
          organizer: ligne['organizer_phone'] ?? '',
          source: 'supabase',
          url: '',
          price: (ligne['price'] ?? 0.0).toDouble(),
        ));
      }
      return evenements;

    } catch (erreur) {
      print('Erreur récupération événements: $erreur');
      return [];
    }
  }


  // Récupère les participants d'un événement
  static Future<List<Map<String, dynamic>>> getEventParticipants({
    required String eventTitle,
  }) async {
    try {
      final reponse = await _client
          .from('reservations')
          .select()
          .eq('event_title', eventTitle);
      return List<Map<String, dynamic>>.from(reponse);
    } catch (erreur) {
      print('Erreur récupération participants: $erreur');
      return [];
    }
  }
}