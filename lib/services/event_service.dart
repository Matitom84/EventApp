import 'package:flutter/foundation.dart';
// kIsWeb permet de savoir si on est sur le web ou sur mobile

import '../models/event.dart';
import 'ticketmaster_service.dart';
import 'eventbrite_service.dart';
import 'database_service.dart';
import 'supabase_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


// Chef d'orchestre des événements
// Les pages appellent uniquement cette classe
// Elle décide si on va chercher sur internet ou en local
class EventService {

  static Future<List<Event>> getEvents({
    required String city,
    String keyword = '',
  }) async {

    final hasInternet = await _checkInternet();

    if (hasInternet) {
      // On lance les deux API en même temps pour aller plus vite
      final results = await Future.wait([
        TicketmasterService.getEvents(city: city, keyword: keyword),
        EventbriteService.getEvents(city: city, keyword: keyword),
      ]);

      // On combine les deux listes en une seule
      List<Event> allEvents = [...results[0], ...results[1]];

      // On récupère aussi les événements créés par les organisateurs
      // dans notre base Supabase et on les ajoute à la liste
      List<Event> supabaseEvents = await SupabaseService.getCreatedEvents();
      allEvents = [...allEvents, ...supabaseEvents];

      // On supprime les doublons par titre
      final seen = <String>{};
      final uniqueEvents = allEvents.where((e) {
        // Si le titre a déjà été vu on l'ignore
        // sinon on l'ajoute à la liste des titres vus
        return seen.add(e.title);
      }).toList();

      // On trie par date — le plus proche en premier
      uniqueEvents.sort((a, b) => a.date.compareTo(b.date));

      // On sauvegarde en local pour le mode hors connexion
      for (final event in uniqueEvents) {
        await DatabaseService.saveEvent(event);
      }

      return uniqueEvents;

    } else {
      print('Pas internet — chargement depuis la base locale');
      return await DatabaseService.getEvents();
    }
  }


  static Future<bool> _checkInternet() async {
    // Sur le web on considère toujours qu'il y a internet
    // car connectivity_plus ne fonctionne pas bien sur web
    if (kIsWeb) return true;

    // Sur mobile on vérifie vraiment la connexion
    final connectivity = await Connectivity().checkConnectivity();
    return connectivity == ConnectivityResult.wifi ||
        connectivity == ConnectivityResult.mobile;
  }
}