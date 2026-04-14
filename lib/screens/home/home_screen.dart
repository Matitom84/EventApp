import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../models/event.dart';
import '../../services/event_service.dart';
import '../event/event_detail_screen.dart';
import '../profile/profile_screen.dart';
import '../create_event/create_event_screen.dart';

// page d'accueil
class HomeScreen extends StatefulWidget {
  final AppUser user; // l'user connecte
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<Event> _events = []; // liste des events
  bool _isLoading = false; // spinner
  int _currentIndex = 0; // onglet actif : 0 accueil / 1 profil
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEvents(); // on charge les events a l'ouverture
  }

  // charge les events depuis les API
  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);

    // on recupere les events, keyword = ce que l'user a tape
    final events = await EventService.getEvents(
      city: _searchController.text.isNotEmpty ? _searchController.text.trim() : 'Paris',
      keyword: _searchController.text.trim(),
    );

    setState(() {
      _events = events;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose(); // liberation memoire
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      // barre de navigation en bas
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: const Color(0xFF1A73E8),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
        ],
      ),

      // IndexedStack garde les 2 pages en memoire
      // et affiche celle qui correspond a _currentIndex
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomePage(),
          ProfileScreen(user: widget.user),
        ],
      ),

      // bouton creer visible uniquement pour les organisateurs
      floatingActionButton: _currentIndex == 0 && widget.user.role == 'organizer'
          ? FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Créer'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreateEventScreen(user: widget.user)),
          );
        },
      )
          : null,
    );
  }

  // la page d'accueil dans une methode separee pour garder le build lisible
  Widget _buildHomePage() {
    return SafeArea(
      child: Column(
        children: [

          // header avec degrade bleu
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A73E8), Color(0xFF4A90E2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // prenom de l'user
                // split(' ')[0] = prend juste le prenom
                Text(
                  'Bonjour ${widget.user.name.split(' ')[0]} 👋',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  widget.user.role == 'organizer' ? 'Organisateur' : 'Participant',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),

                const SizedBox(height: 12),

                // barre de recherche
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Rechercher un événement...',
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFFF8F9FA),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1A73E8))),
                        ),
                        // recherche quand l'user appuie sur entree
                        onSubmitted: (_) => _loadEvents(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _loadEvents,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A73E8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      child: const Text('Go'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // liste des events
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A73E8)))
                : _events.isEmpty
                ? Center(child: Text('Aucun événement trouvé', style: TextStyle(color: Colors.grey.shade500)))
                : RefreshIndicator(
              onRefresh: _loadEvents,
              color: const Color(0xFF1A73E8),
              // grille 2 colonnes
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  mainAxisExtent: 260, // hauteur fixe de chaque carte
                ),
                itemCount: _events.length,
                itemBuilder: (_, i) => _EventCard(
                  event: _events[i],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EventDetailScreen(event: _events[i], user: widget.user),
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

// carte d'un event dans la grille
class _EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const _EventCard({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // image de l'event
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: event.imageUrl.isNotEmpty
                  ? Image.network(
                event.imageUrl,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                // fond bleu si l'image plante
                errorBuilder: (_, __, ___) => _placeholder(),
              )
                  : _placeholder(),
            ),

            // infos de l'event
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // badge source + prix
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: event.source == 'ticketmaster' ? const Color(0xFFE8F0FE) : const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            event.source == 'ticketmaster' ? 'TM' : 'EB',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: event.source == 'ticketmaster' ? const Color(0xFF1A73E8) : const Color(0xFFE65100),
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

                    // titre
                    Text(
                      event.title,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // date
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 11, color: Colors.grey.shade400),
                        const SizedBox(width: 3),
                        Text('${event.date.day}/${event.date.month}/${event.date.year}',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                      ],
                    ),

                    const SizedBox(height: 2),

                    // lieu
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

  // fond bleu si pas d'image
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
      child: const Center(child: Icon(Icons.event_rounded, size: 32, color: Colors.white)),
    );
  }
}