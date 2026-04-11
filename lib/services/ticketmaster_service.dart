import 'dart:convert';
// dart:convert permet de décoder le JSON reçu de Ticketmaster
// Ex: transforme le texte JSON en dictionnaire Dart qu'on peut utiliser

import 'package:http/http.dart' as http;
// http c'est la librairie qu'on a installée pour faire des appels internet
// "as http" signifie qu'on l'appelle "http" dans ce fichier

import '../models/event.dart';
// On importe notre modèle Event pour créer des objets Event
// à partir des données reçues de Ticketmaster


// Cette classe gère TOUT ce qui concerne l'API Ticketmaster
// Elle envoie les requêtes et convertit les réponses en objets Event
class TicketmasterService {

  // La clé API Ticketmaster — c'est comme un mot de passe
  // qui prouve à Ticketmaster que c'est bien notre app qui demande
  // IMPORTANT : on mettra la vraie clé ici après — pour l'instant
  // on la laisse en constante, on la sécurisera avec flutter_secure_storage
  static const String _apiKey = 'Q9CJf5zyaUJjENwXJ67GwqeOZQgphTbA';

  // L'URL de base de l'API Ticketmaster
  // Toutes nos requêtes commenceront par cette URL
  static const String _baseUrl = 'https://app.ticketmaster.com/discovery/v2';


  // RÉCUPÉRER LES ÉVÉNEMENTS PRÈS D'UNE VILLE
  // Cette méthode envoie une requête à Ticketmaster et retourne
  // une liste d'événements
  // "city" = la ville recherchée, ex: "Paris"
  // "keyword" = mot clé optionnel, ex: "concert" ou "sport"
  static Future<List<Event>> getEvents({
    required String city,
    String keyword = '',
    // keyword a une valeur par défaut vide — il est donc optionnel
  }) async {

    try {
      // On construit l'URL complète de la requête
      // Uri.parse transforme le texte en URL utilisable
      final url = Uri.parse(
        // On demande les événements avec nos paramètres
          '$_baseUrl/events.json?'
              'apikey=$_apiKey&'      // Notre clé API
              'city=$city&'           // La ville recherchée
              'keyword=$keyword&'     // Le mot clé (vide si pas précisé)
              'locale=fr-FR&'         // On veut les résultats en français
              'size=20'               // On veut maximum 20 événements
      );

      // On envoie la requête GET à Ticketmaster
      // C'est comme taper une URL dans un navigateur mais depuis le code
      // "await" signifie qu'on attend la réponse avant de continuer
      final response = await http.get(url);

      // Si le code de réponse est 200, ça signifie que tout s'est bien passé
      // C'est le code HTTP standard pour "succès"
      if (response.statusCode == 200) {

        // On décode le JSON reçu en dictionnaire Dart
        // response.body c'est le texte JSON brut reçu de Ticketmaster
        final data = json.decode(response.body);

        // On navigue dans le JSON pour trouver la liste d'événements
        // Ticketmaster range ses événements dans _embedded > events
        final events = data['_embedded']?['events'] as List?;

        // Si pas d'événements trouvés on retourne une liste vide
        if (events == null) return [];

        // On convertit chaque événement JSON en objet Event
        // "map" applique une fonction sur chaque élément de la liste
        return events
            .map((e) => _parseEvent(e))
        // whereType filtre les null — si un événement n'a pas pu
        // être converti on l'ignore
            .whereType<Event>()
            .toList();
      }

      // Si le code n'est pas 200 (erreur serveur, clé invalide...)
      // on retourne une liste vide
      return [];

    } catch (e) {
      print('Erreur Ticketmaster: $e');
      return [];
    }
  }


  // CONVERTIR UN ÉVÉNEMENT JSON EN OBJET EVENT
  // Cette méthode prend un dictionnaire JSON de Ticketmaster
  // et le transforme en notre objet Event
  // Elle est "privée" (le _ devant) car on l'utilise uniquement ici
  static Event? _parseEvent(Map<String, dynamic> e) {
    try {
      // On extrait chaque information du JSON Ticketmaster
      // Le "?" signifie que la valeur peut être null
      // Le "?? ''" signifie "si c'est null, utilise ce texte par défaut"

      final String id = e['id'] ?? '';
      final String title = e['name'] ?? 'Événement sans titre';

      // La description est dans "info" ou "pleaseNote" dans le JSON Ticketmaster
      final String description = e['info'] ?? e['pleaseNote'] ?? 'Aucune description disponible';

      // L'image — Ticketmaster donne plusieurs images, on prend la première
      final List images = e['images'] ?? [];
      final String imageUrl = images.isNotEmpty ? images[0]['url'] ?? '' : '';

      // La date — elle est dans dates > start > dateTime
      final String dateStr = e['dates']?['start']?['dateTime'] ?? '';
      // Si pas de date on met la date d'aujourd'hui par défaut
      final DateTime date = dateStr.isNotEmpty
          ? DateTime.parse(dateStr)
          : DateTime.now();

      // L'adresse — elle est dans _embedded > venues (les salles)
      final List venues = e['_embedded']?['venues'] ?? [];
      final String address = venues.isNotEmpty
          ? '${venues[0]['name'] ?? ''}, ${venues[0]['city']?['name'] ?? ''}'
          : 'Adresse non disponible';

      // Le prix — Ticketmaster donne une fourchette de prix
      // On prend le prix minimum
      final List priceRanges = e['priceRanges'] ?? [];
      final double price = priceRanges.isNotEmpty
          ? (priceRanges[0]['min'] ?? 0.0).toDouble()
          : 0.0;

      // Le lien vers la page officielle de l'événement
      final String url = e['url'] ?? '';

      // On retourne un objet Event avec toutes ces informations
      return Event(
        id: 'tm_$id',
        // On préfixe l'id avec "tm_" pour savoir que ça vient de Ticketmaster
        title: title,
        description: description,
        address: address,
        imageUrl: imageUrl,
        date: date,
        maxPlaces: 0,
        // Ticketmaster ne donne pas toujours le nombre de places
        organizer: 'Ticketmaster',
        source: 'ticketmaster',
        url: url,
        price: price,
      );

    } catch (e) {
      // Si la conversion échoue pour un événement on retourne null
      // whereType<Event>() dans getEvents() filtrera ce null
      print('Erreur parsing événement Ticketmaster: $e');
      return null;
    }
  }
}