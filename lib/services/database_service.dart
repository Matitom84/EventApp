import 'package:flutter/foundation.dart';
import '../models/event.dart';
import '../models/user.dart';

// Sur le web on ne peut pas utiliser SQFLite
// On stocke les données en mémoire temporairement
// Sur mobile (Android/iOS) SQFLite sera utilisé normalement
class DatabaseService {

  // Stockage en mémoire pour le web
  static List<Event> _events = [];
  static AppUser? _user;

  static Future<void> saveEvent(Event event) async {
    if (kIsWeb) {
      // Sur web on stocke en mémoire
      _events.removeWhere((e) => e.id == event.id);
      _events.add(event);
    } else {
      // Sur mobile on utilisera SQFLite — à implémenter plus tard
      _events.add(event);
    }
  }

  static Future<List<Event>> getEvents() async {
    return _events;
  }

  static Future<void> deleteEvent(String id) async {
    _events.removeWhere((e) => e.id == id);
  }

  static Future<void> saveUser(AppUser user) async {
    _user = user;
  }

  static Future<AppUser?> getUser() async {
    return _user;
  }

  static Future<void> deleteUser() async {
    _user = null;
  }
}