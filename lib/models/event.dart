// un Event c'est le modele d'un evenement dans l'app
// chaque concert, expo ou festival sera un objet Event
class Event {

  // les infos d'un evenement
  // final = ca ne change pas une fois cree
  final String id;          // identifiant unique ex: "tm_123"
  final String title;       // nom de l'evenement
  final String description; // description
  final String address;     // adresse du lieu
  final String imageUrl;    // lien vers la photo
  final DateTime date;      // date et heure
  final int maxPlaces;      // nombre de places max (0 = illimite)
  final String organizer;   // nom de l'organisateur
  final String source;      // "ticketmaster" ou "eventbrite"
  final String url;         // lien vers le site officiel
  final double price;       // prix en euros (0.0 = gratuit)

  // constructeur - obligatoire de tout remplir
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

  // convertit l'event en dictionnaire pour le sauvegarder dans SQLite
  // SQLite ne comprend pas les objets Dart donc on transforme en Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'address': address,
      'imageUrl': imageUrl,
      'date': date.toIso8601String(), // on convertit la date en texte
      'maxPlaces': maxPlaces,
      'organizer': organizer,
      'source': source,
      'url': url,
      'price': price,
    };
  }

  // fait l'inverse de toMap()
  // prend un dictionnaire et cree un objet Event
  // utilise quand on relit les events depuis SQLite
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      address: map['address'],
      imageUrl: map['imageUrl'],
      date: DateTime.parse(map['date']), // on reconvertit le texte en date
      maxPlaces: map['maxPlaces'],
      organizer: map['organizer'],
      source: map['source'],
      url: map['url'],
      price: map['price'],
    );
  }
}