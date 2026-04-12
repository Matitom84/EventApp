import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../models/event.dart';
import '../../services/event_service.dart';
import '../event/event_detail_screen.dart';
import '../profile/profile_screen.dart';
import '../create_event/create_event_screen.dart';


// StatefulWidget car la page a des données qui changent
// ex: la liste d'événements, le chargement...
class HomeScreen extends StatefulWidget {
  // On reçoit l'utilisateur connecté depuis la page de connexion
  final AppUser user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // Liste vide au départ, elle sera remplie après le chargement
  List<Event> _events = [];

  // true = on attend la réponse de l'API, false = données reçues
  bool _isLoading = false;

  // Onglet actif : 0 = Accueil, 1 = Profil
  int _currentIndex = 0;

  // Controller = objet qui lit ce que l'utilisateur tape dans un champ
  final _searchController = TextEditingController();

  // initState est appelé une seule fois quand la page s'ouvre
  @override
  void initState() {
    super.initState();
    _loadEvents(); // On charge les événements dès l'ouverture
  }

  // Appelle l'API et met à jour la liste d'événements
  Future<void> _loadEvents() async {
    // setState redessine la page avec les nouvelles valeurs
    setState(() => _isLoading = true);

    // On récupère les événements depuis Ticketmaster et Eventbrite
    // keyword = ce que l'utilisateur a tapé dans la recherche
    final events = await EventService.getEvents(
      city: 'Paris', // Ville fixe pour simplifier
      keyword: _searchController.text.trim(),
      // trim() enlève les espaces avant et après le texte
    );

    // On met à jour la liste et on arrête le chargement
    setState(() {
      _events = events;
      _isLoading = false;
    });
  }

  // Libère la mémoire du controller quand la page est fermée
  // Important pour éviter les fuites mémoire
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold = structure de base d'une page Flutter
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      // Barre de navigation en bas avec 2 onglets
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Onglet actif
        // Quand on tape un onglet, on met à jour _currentIndex
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: const Color(0xFF1A73E8), // Bleu si sélectionné
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),

      // IndexedStack affiche une page à la fois selon _currentIndex
      // Les deux pages restent en mémoire pour ne pas recharger
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomePage(), // Page 0 = Accueil
          ProfileScreen(user: widget.user), // Page 1 = Profil
        ],
      ),

      // Bouton "Créer" visible uniquement pour les organisateurs
      // et uniquement sur l'onglet Accueil
      floatingActionButton: _currentIndex == 0 &&
          widget.user.role == 'organizer'
          ? FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Créer'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateEventScreen(user: widget.user),
            ),
          );
        },
      )
          : null, // null = pas de bouton
    );
  }

  // La page d'accueil est dans une méthode séparée
  // pour garder le build() plus lisible
  Widget _buildHomePage() {
    // SafeArea évite que le contenu se cache derrière
    // la barre de statut ou le bouton home du téléphone
    return SafeArea(
      child: Column(
        children: [

          // ── HEADER ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Prénom de l'utilisateur
                // widget.user = l'utilisateur reçu en paramètre
                // split(' ')[0] = prend le premier mot (le prénom)
                Text(
                  'Bonjour ${widget.user.name.split(' ')[0]} 👋',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Rôle de l'utilisateur
                Text(
                  widget.user.role == 'organizer'
                      ? 'Organisateur' // Si rôle = organisateur
                      : 'Participant', // Sinon = participant
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),

                const SizedBox(height: 12), // Espace vertical

                // Barre de recherche
                Row(
                  children: [
                    // Champ de texte qui prend tout l'espace disponible
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Rechercher un événement...',
                          // Icône de loupe à gauche
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          // Style du champ
                          filled: true,
                          fillColor: const Color(0xFFF8F9FA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF1A73E8)),
                          ),
                        ),
                        // Lance la recherche quand l'utilisateur appuie sur Entrée
                        onSubmitted: (_) => _loadEvents(),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Bouton de recherche
                    ElevatedButton(
                      onPressed: _loadEvents,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A73E8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                      child: const Text('Go'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── LISTE DES ÉVÉNEMENTS ──
          // Expanded = prend tout l'espace restant
          Expanded(
            child: _isLoading
            // Si chargement en cours → spinner au centre
                ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1A73E8),
              ),
            )
                : _events.isEmpty
            // Si pas d'événements → message
                ? Center(
              child: Text(
                'Aucun événement trouvé',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            )
            // Sinon → grille des événements (2 colonnes)
                : RefreshIndicator(
              // Pull to refresh = tirer vers le bas pour recharger
              onRefresh: _loadEvents,
              color: const Color(0xFF1A73E8),
              // GridView.builder = comme ListView mais en grille
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                // gridDelegate définit comment la grille est organisée
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 colonnes
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  mainAxisExtent: 260, // hauteur fixe de chaque carte en pixels
                ),
                itemCount: _events.length,
                // itemBuilder crée une carte pour chaque événement
                itemBuilder: (_, i) => _EventCard(
                  event: _events[i],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EventDetailScreen(
                        event: _events[i],
                        user: widget.user,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// Widget pour afficher un événement dans la liste
// StatelessWidget car la carte ne change jamais d'état
class _EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const _EventCard({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // on retire le margin bottom qui causait le débordement
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Image de l'événement — hauteur réduite pour la grille
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: event.imageUrl.isNotEmpty
                  ? Image.network(
                event.imageUrl,
                height: 100, // réduit pour rentrer dans la carte
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
              )
                  : _placeholder(),
            ),

            // Infos — Expanded pour prendre le reste de la place
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Badge source + prix
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: event.source == 'ticketmaster'
                                ? const Color(0xFFE8F0FE)
                                : const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            event.source == 'ticketmaster' ? 'TM' : 'EB',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: event.source == 'ticketmaster'
                                  ? const Color(0xFF1A73E8)
                                  : const Color(0xFFE65100),
                            ),
                          ),
                        ),
                        Text(
                          event.price == 0.0 ? 'Gratuit' : '${event.price.toStringAsFixed(0)} €',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: event.price == 0.0 ? Colors.green : const Color(0xFF1A73E8),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Titre
                    Text(
                      event.title,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Date
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 11, color: Colors.grey.shade400),
                        const SizedBox(width: 3),
                        Text(
                          '${event.date.day}/${event.date.month}/${event.date.year}',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                      ],
                    ),

                    const SizedBox(height: 2),

                    // Lieu
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, size: 11, color: Colors.grey.shade400),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            event.address,
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 100,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A73E8), Color(0xFF4A90E2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.event_rounded, size: 32, color: Colors.white),
      ),
    );
  }
}