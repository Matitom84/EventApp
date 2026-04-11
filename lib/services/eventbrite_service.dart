import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';

class EventbriteService {

  // La clé privée Eventbrite — permet de s'authentifier auprès de l'API
  static const String _apiKey = '7VFZB4ASHEZHEU5UAW2H';

  // URL de base de l'API Eventbrite
  static const String _baseUrl = 'https://www.eventbriteapi.com/v3';


  static Future<List<Event>> getEvents({
    required String city,
    String keyword = '',
  }) async {

    try {
      // Eventbrite utilise le header Authorization avec "Bearer"
      // C'est différent de Ticketmaster qui met la clé dans l'URL
      // "Bearer" = "porteur du token" — standard de sécurité HTTP
      final headers = {
        'Authorization': 'Bearer $_apiKey',
      };

      final url = Uri.parse(
          '$_baseUrl/events/search/?'
              'location.address=$city&'
              'q=$keyword&'
              'locale=fr_FR&'
              'expand=venue,ticket_classes&'
          // expand = on demande des infos supplémentaires en un seul appel
          // venue = le lieu de l'événement
          // ticket_classes = les types de billets et leurs prix
              'page_size=20'
      );

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Eventbrite range ses événements dans "events"
        // Différent de Ticketmaster qui utilisait "_embedded > events"
        final events = data['events'] as List?;
        if (events == null) return [];
        return events.map((e) => _parseEvent(e)).whereType<Event>().toList();
      }

      return [];

    } catch (e) {
      print('Erreur Eventbrite: $e');
      return [];
    }
  }


  static Event? _parseEvent(Map<String, dynamic> e) {
    try {

      final String id = e['id'] ?? '';

      // Eventbrite met le titre dans "name > text"
      // Ticketmaster mettait juste "name" — chaque API a son format
      final String title = e['name']?['text'] ?? 'Événement sans titre';

      // La description est dans "description > text"
      final String description = e['description']?['text']
          ?? 'Aucune description disponible';

      // L'image est dans "logo > url"
      final String imageUrl = e['logo']?['url'] ?? '';

      // La date est dans "start > utc"
      // utc = temps universel coordonné — format standard international
      final String dateStr = e['start']?['utc'] ?? '';
      final DateTime date = dateStr.isNotEmpty
          ? DateTime.parse(dateStr)
          : DateTime.now();

      // L'adresse vient du "venue" qu'on a demandé avec expand=venue
      final venue = e['venue'];
      final String address = venue != null
          ? '${venue['name'] ?? ''}, ${venue['address']?['city'] ?? ''}'
          : 'Adresse non disponible';

      // Le prix vient de "ticket_classes" demandé avec expand
      // On prend le prix minimum du premier type de billet
      final List ticketClasses = e['ticket_classes'] ?? [];
      double price = 0.0;
      if (ticketClasses.isNotEmpty) {
        // "major_value" = prix en euros (pas en centimes)
        final costStr = ticketClasses[0]['cost']?['major_value'] ?? '0';
        price = double.tryParse(costStr) ?? 0.0;
        // tryParse retourne null si la conversion échoue
        // ?? 0.0 met 0 par défaut si c'est null
      }

      final String url = e['url'] ?? '';
      final int maxPlaces = e['capacity'] ?? 0;

      return Event(
        id: 'eb_$id',
        // Préfixe "eb_" pour distinguer les événements Eventbrite
        // des événements Ticketmaster qui ont le préfixe "tm_"
        title: title,
        description: description,
        address: address,
        imageUrl: imageUrl,
        date: date,
        maxPlaces: maxPlaces,
        organizer: 'Eventbrite',
        source: 'eventbrite',
        url: url,
        price: price,
      );

    } catch (e) {
      print('Erreur parsing Eventbrite: $e');
      return null;
    }
  }
}