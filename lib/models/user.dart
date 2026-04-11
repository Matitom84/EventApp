// On renomme notre classe en "AppUser" pour éviter le conflit avec
// la classe "User" de Supabase qui porte le même nom
// Sans ce renommage Flutter ne sait pas lequel des deux utiliser et plante
class AppUser {

  final String id;
  // L'identifiant unique de l'utilisateur
  // Supabase génère automatiquement cet id quand quelqu'un s'inscrit
  // Ex: "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
  // C'est un UUID — un identifiant universel unique

  final String email;
  // L'adresse email de l'utilisateur
  // Ex: "albert.martin@email.com"
  // C'est aussi ce qu'il utilise pour se connecter

  final String name;
  // Le prénom et nom de l'utilisateur
  // Ex: "Albert Martin"

  final String role;
  // Le rôle de l'utilisateur dans l'app — deux valeurs possibles :
  // "organizer" = il peut créer des événements
  // "client" = il peut uniquement réserver des places
  // C'est grâce à ce champ qu'on affiche un écran différent
  // selon le type d'utilisateur

  final String phone;
  // Le numéro de téléphone de l'utilisateur
  // Ex: "+33612345678"
  // Utile pour que l'organisateur puisse contacter les participants

  final DateTime createdAt;
  // La date à laquelle l'utilisateur a créé son compte
  // Supabase remplit automatiquement cette information à l'inscription


  // LE CONSTRUCTEUR
  // Pour créer un utilisateur on appelle AppUser(...)
  // et on donne toutes les informations obligatoires
  AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.phone,
    required this.createdAt,
  });


  // toMap() — transforme l'utilisateur en dictionnaire
  // Utilisé pour sauvegarder l'utilisateur dans la base de données locale
  // Comme ça si l'utilisateur n'a pas internet, on se souvient quand même de lui
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'phone': phone,
      // On convertit la date en texte pour pouvoir la stocker
      'createdAt': createdAt.toIso8601String(),
    };
  }


  // fromMap() — recrée un utilisateur depuis un dictionnaire
  // Utilisé quand on relit l'utilisateur depuis la base de données locale
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'],
      email: map['email'],
      name: map['name'],
      role: map['role'],
      phone: map['phone'],
      // On reconvertit le texte en date
      createdAt: DateTime.parse(map['createdAt']),
    );
  }


  // fromSupabase() — crée un AppUser depuis les données de Supabase
  // Supabase renvoie les données dans un format légèrement différent
  // donc on a une méthode spéciale pour ça
  // C'est cette méthode qu'on utilisera juste après la connexion
  factory AppUser.fromSupabase(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'],
      email: map['email'],
      // ?? signifie "si c'est null, utilise cette valeur par défaut"
      // Si le nom n'est pas encore rempli on met "Utilisateur"
      name: map['name'] ?? 'Utilisateur',
      // Si le rôle n'est pas encore défini on met "client" par défaut
      role: map['role'] ?? 'client',
      // Si le téléphone n'est pas renseigné on met une chaîne vide
      phone: map['phone'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}