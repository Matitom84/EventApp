import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';

class TicketmasterService {
  static const String _apiKey = 'Q9CJf5zyaUJjENwXJ67GwqeOZQgphTbA';
  static const String _baseUrl = 'https://app.ticketmaster.com/discovery/v2';

  // Récupère une liste d'événements pour une ville donnée
  static Future<List<Event>> getEvents({
    required String city,
    String keyword = '',
  }) async {
    try {
      // On construit l'URL
      final url = Uri.parse(
        '$_baseUrl/events.json?apikey=$_apiKey&city=$city&keyword=$keyword&locale=fr-FR&size=20',
      );

      // On envoie la requête et on attend la réponse
      final response = await http.get(url);

      // Si la requête a réussi
      if (response.statusCode == 200) {
        // On transforme le JSON reçu en dictionnaire Dart
        final data = json.decode(response.body);

        // On récupère la liste d'événements
        final List? events = data['_embedded']?['events'];

        // Si aucun événement trouvé
        if (events == null) return [];

        // On convertit chaque événement en objet Event
        final List<Event> resultat = [];
        for (var evenement in events) {
          final Event? monEvenement = _parseEvent(evenement);
          if (monEvenement != null) resultat.add(monEvenement);
        }
        return resultat;
      }

      return [];

    } catch (erreur) {
      print('Erreur Ticketmaster: $erreur');
      return [];
    }
  }

  // Convertit un événement JSON en objet Event
  static Event? _parseEvent(Map<String, dynamic> evenement) {
    try {
      // On extrait les infos de base
      final String id = evenement['id'] ?? '';
      final String title = evenement['name'] ?? 'Événement sans titre';
      final String description = evenement['info'] ?? evenement['pleaseNote'] ?? 'Aucune description disponible';

      // On prend la première image de la liste
      final List images = evenement['images'] ?? [];
      final String imageUrl = images.isNotEmpty ? images[0]['url'] ?? '' : '';

      // On récupère la date et on la convertit en objet DateTime
      final String dateStr = evenement['dates']?['start']?['dateTime'] ?? '';
      final DateTime date = dateStr.isNotEmpty ? DateTime.parse(dateStr) : DateTime.now();

      // On construit l'adresse depuis le nom de la salle et la ville
      final List venues = evenement['_embedded']?['venues'] ?? [];
      final String address = venues.isNotEmpty
          ? '${venues[0]['name'] ?? ''}, ${venues[0]['city']?['name'] ?? ''}'
          : 'Adresse non disponible';

      // On prend le prix minimum
      final List priceRanges = evenement['priceRanges'] ?? [];
      final double price = priceRanges.isNotEmpty ? (priceRanges[0]['min'] ?? 0.0).toDouble() : 0.0;

      // Le lien vers la page de l'événement sur Ticketmaster
      final String url = evenement['url'] ?? '';

      // On crée et retourne l'objet Event
      return Event(
        id: 'tm_$id',
        title: title,
        description: description,
        address: address,
        imageUrl: imageUrl,
        date: date,
        maxPlaces: 0,
        organizer: 'Ticketmaster',
        source: 'ticketmaster',
        url: url,
        price: price,
      );
    } catch (erreur) {
      print('Erreur parsing événement Ticketmaster: $erreur');
      return null;
    }
  }
}