// AppUser = le modele d'un utilisateur dans l'app
// on l'appelle AppUser et pas User pour eviter le conflit avec Supabase
// qui a deja une classe User
class AppUser {

  // infos de l'utilisateur
  final String id;        // id unique genere par Supabase
  final String email;     // email
  final String name;      // prenom et nom
  final String role;      // "client" ou "organizer"
  final String phone;     // numero de telephone
  final DateTime createdAt; // date de creation du compte

  // constructeur
  AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.phone,
    required this.createdAt,
  });

  // transforme l'user en dictionnaire pour le sauvegarder dans SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(), // date convertie en texte
    };
  }

  // recrée un AppUser depuis un dictionnaire SQLite
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'],
      email: map['email'],
      name: map['name'],
      role: map['role'],
      phone: map['phone'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // recrée un AppUser depuis les données de Supabase
  // Supabase renvoie un format un peu different donc methode separee
  factory AppUser.fromSupabase(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'],
      email: map['email'],
      // ?? = si c'est null on met une valeur par defaut
      name: map['name'] ?? 'Utilisateur',
      role: map['role'] ?? 'client',
      phone: map['phone'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}