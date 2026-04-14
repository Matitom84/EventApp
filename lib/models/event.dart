// Un Event = un événement (concert, festival, etc.)
class Event {

  // ====== VARIABLES ======
  // "final" = la valeur ne change plus après création

  final String id;          // identifiant unique
  final String title;       // nom de l'événement
  final String description; // description
  final String address;     // lieu
  final String imageUrl;    // image
  final DateTime date;      // date + heure
  final int maxPlaces;      // nombre de places (0 = illimité)
  final String organizer;   // organisateur
  final String source;      // d'où ça vient (API)
  final String url;         // lien site
  final double price;       // prix

  // ====== CONSTRUCTEUR ======
  // Obligé de donner toutes les infos quand on crée un Event
  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.address,
    required this.imageUrl,
    required this.date,
    required this.maxPlaces,
    required this.organizer,
    required this.source,
    required this.url,
    required this.price,
  });

  // ====== CONVERTIR EN MAP ======
  // Sert à enregistrer dans la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'address': address,
      'imageUrl': imageUrl,

      // Date transformée en texte (SQLite ne comprend pas DateTime)
      'date': date.toIso8601String(),

      'maxPlaces': maxPlaces,
      'organizer': organizer,
      'source': source,
      'url': url,
      'price': price,
    };
  }

  // ====== CREER UN EVENT A PARTIR D'UNE MAP ======
  // Sert quand on récupère les données depuis la base
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      address: map['address'],
      imageUrl: map['imageUrl'],

      // On reconvertit le texte en DateTime
      date: DateTime.parse(map['date']),

      maxPlaces: map['maxPlaces'],
      organizer: map['organizer'],
      source: map['source'],
      url: map['url'],
      price: map['price'],
    );
  }
}