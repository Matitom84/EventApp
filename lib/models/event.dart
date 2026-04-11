// Un "class" c'est comme un moule pour créer des objets
// Ici on crée le moule "Event" — chaque événement de l'app sera basé sur ce moule
class Event {

  // "final" signifie que ces valeurs ne changent pas une fois créées
  // C'est comme des cases d'un formulaire — une fois remplies, elles restent fixes

  final String id;
  // String = texte — l'id est un texte unique qui identifie chaque événement
  // Ex: "tm_123456" — comme un numéro de sécurité sociale mais pour un événement

  final String title;
  // Le nom de l'événement
  // Ex: "Concert de Jul à Bercy"

  final String description;
  // Le texte de description de l'événement
  // Ex: "Jul en tournée pour son nouvel album, venez nombreux !"

  final String address;
  // L'adresse physique où se passe l'événement
  // Ex: "Accor Arena, 8 Bd de Bercy, 75012 Paris"

  final String imageUrl;
  // Un lien internet vers la photo de l'événement
  // Ex: "https://ticketmaster.com/images/concert_jul.jpg"
  // C'est juste un lien texte — l'image elle-même est sur internet

  final DateTime date;
  // DateTime = un type spécial en Dart pour les dates ET les heures
  // Ex: 10 avril 2026 à 20h30
  // On utilise DateTime et pas String pour pouvoir faire des calculs de dates
  // Ex: trier les événements du plus proche au plus loin

  final int maxPlaces;
  // int = nombre entier (sans virgule)
  // Le nombre maximum de personnes qui peuvent assister à l'événement
  // Ex: 500

  final String organizer;
  // Le nom de la personne ou société qui organise l'événement
  // Ex: "Live Nation" ou "Albert Martin"

  final String source;
  // D'où vient l'événement — soit "ticketmaster" soit "eventbrite"
  // On garde cette info pour savoir quelle API a fourni l'événement
  // Utile si on veut afficher un logo différent selon la source

  final String url;
  // Le lien vers la page officielle de l'événement sur Ticketmaster ou Eventbrite
  // Ex: "https://www.ticketmaster.fr/event/concert-jul"
  // On en a besoin pour rediriger l'utilisateur vers la page de réservation officielle

  final double price;
  // double = nombre avec virgule
  // Le prix d'une place en euros
  // Ex: 49.99 ou 0.0 si l'événement est gratuit


  // LE CONSTRUCTEUR
  // C'est la fonction qui permet de CRÉER un événement
  // Quand on veut créer un événement dans l'app, on appelle Event(...)
  // "required" signifie que le champ est OBLIGATOIRE
  // On ne peut pas créer un événement sans donner toutes ces informations
  // Ex: Event(id: "123", title: "Concert", description: "Super concert", ...)
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


  // LA MÉTHODE toMap()
  // "Map" en Dart c'est comme un dictionnaire — des paires clé/valeur
  // Ex: {'title': 'Concert de Jul', 'price': 49.99}
  // On a besoin de cette méthode car la base de données locale (SQFLite)
  // ne comprend pas les objets Dart directement
  // Elle comprend uniquement des dictionnaires simples
  // Donc on "traduit" notre Event en dictionnaire avant de le sauvegarder
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'address': address,
      'imageUrl': imageUrl,
      // toIso8601String() convertit la date en texte standard
      // Ex: DateTime(2026, 4, 10, 20, 30) devient "2026-04-10T20:30:00"
      // La base de données ne peut pas stocker un DateTime directement
      // donc on le convertit en texte
      'date': date.toIso8601String(),
      'maxPlaces': maxPlaces,
      'organizer': organizer,
      'source': source,
      'url': url,
      'price': price,
    };
  }


  // LA MÉTHODE fromMap()
  // C'est l'exact opposé de toMap()
  // Quand on relit un événement depuis la base de données locale
  // on récupère un dictionnaire — mais on veut un objet Event
  // Cette méthode prend le dictionnaire et crée un Event à partir de lui
  // "factory" signifie que c'est une méthode spéciale qui retourne un objet
  // Ex: Event.fromMap({'id': '123', 'title': 'Concert'...}) → crée un Event
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      address: map['address'],
      imageUrl: map['imageUrl'],
      // DateTime.parse() fait l'inverse de toIso8601String()
      // Il reconvertit le texte "2026-04-10T20:30:00" en DateTime
      date: DateTime.parse(map['date']),
      maxPlaces: map['maxPlaces'],
      organizer: map['organizer'],
      source: map['source'],
      url: map['url'],
      price: map['price'],
    );
  }
}