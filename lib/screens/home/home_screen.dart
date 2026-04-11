import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../models/event.dart';
import '../../services/event_service.dart';
import '../../services/supabase_service.dart';
import '../event/event_detail_screen.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppUser user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<Event> _events = [];
  bool _isLoading = false;
  final _searchController = TextEditingController();

  // Ville et pays sélectionnés par l'utilisateur
  String _city = 'Paris';
  String _country = 'France';

  // Catégorie sélectionnée — vide = tout afficher
  String _selectedCategory = 'Tout';

  // Liste des catégories disponibles dans les filtres
  final List<String> _categories = [
    'Tout', 'Concert', 'Sport', 'Festival', 'Théâtre', 'Expo'
  ];

  // Liste des villes disponibles par pays
  // Map = dictionnaire — clé = pays, valeur = liste de villes
  final Map<String, List<String>> _citiesByCountry = {
    'France': ['Paris', 'Lyon', 'Marseille', 'Bordeaux', 'Lille'],
    'Belgique': ['Bruxelles', 'Anvers', 'Gand', 'Liège'],
    'Suisse': ['Genève', 'Zurich', 'Lausanne', 'Berne'],
    'Espagne': ['Madrid', 'Barcelone', 'Séville', 'Valencia'],
    'UK': ['London', 'Manchester', 'Birmingham', 'Liverpool'],
  };


  @override
  void initState() {
    super.initState();
    // On charge les événements dès que l'écran s'ouvre
    _loadEvents();
  }


  // Charge les événements depuis les API
  // keyword = mot clé de recherche — on combine la catégorie et la recherche
  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);

    // Si catégorie = "Tout" on envoie juste le texte de recherche
    // Sinon on combine catégorie + recherche
    // Ex: "Concert" + "Jul" → keyword = "Concert Jul"
    final keyword = _selectedCategory == 'Tout'
        ? _searchController.text.trim()
        : '$_selectedCategory ${_searchController.text.trim()}'.trim();

    final events = await EventService.getEvents(
      city: _city,
      keyword: keyword,
    );

    setState(() {
      _events = events;
      _isLoading = false;
    });
  }


  Future<void> _logout() async {
    await SupabaseService.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }


  // Affiche une boîte de dialogue pour choisir le pays
  // showDialog = affiche une fenêtre par-dessus l'écran
  void _showCountryPicker() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Choisir un pays',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          // mainAxisSize.min = la boîte prend le minimum d'espace nécessaire
          children: _citiesByCountry.keys.map((country) {
            // On génère un bouton pour chaque pays de la Map
            return ListTile(
              title: Text(country),
              trailing: _country == country
                  ? const Icon(Icons.check_rounded,
                  color: Color(0xFF1A73E8))
                  : null,
              // trailing = widget affiché à droite du ListTile
              // On affiche une coche si c'est le pays sélectionné
              onTap: () {
                setState(() {
                  _country = country;
                  // On remet la première ville du pays sélectionné par défaut
                  _city = _citiesByCountry[country]!.first;
                });
                Navigator.pop(context);
                // pop() ferme la boîte de dialogue
                _loadEvents();
              },
            );
          }).toList(),
        ),
      ),
    );
  }


  // Affiche une boîte de dialogue pour choisir la ville
  void _showCityPicker() {
    // On récupère les villes du pays actuellement sélectionné
    final cities = _citiesByCountry[_country] ?? ['Paris'];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Choisir une ville',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: cities.map((city) {
            return ListTile(
              title: Text(city),
              trailing: _city == city
                  ? const Icon(Icons.check_rounded,
                  color: Color(0xFF1A73E8))
                  : null,
              onTap: () {
                setState(() => _city = city);
                Navigator.pop(context);
                _loadEvents();
              },
            );
          }).toList(),
        ),
      ),
    );
  }


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [

            // HEADER BLANC
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // LIGNE NOM + BOUTON DÉCONNEXION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // On affiche le vrai prénom de l'utilisateur
                          // split(' ')[0] prend uniquement le prénom
                          // Ex: "Mathys Robert" → "Mathys"
                          Text(
                            'Bonjour, ${widget.user.name.split(' ')[0]} 👋',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          Text(
                            widget.user.role == 'organizer'
                                ? 'Compte organisateur'
                                : 'Compte participant',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      // BOUTON DÉCONNEXION
                      GestureDetector(
                        onTap: _logout,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: const Icon(
                            Icons.logout_rounded,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // BARRE DE RECHERCHE
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Icon(Icons.search_rounded,
                            color: Colors.grey.shade400, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Concert, artiste, sport...',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onSubmitted: (_) => _loadEvents(),
                          ),
                        ),
                        GestureDetector(
                          onTap: _loadEvents,
                          child: Container(
                            margin: const EdgeInsets.all(5),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A73E8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Rechercher',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // SÉLECTEURS PAYS ET VILLE
                  Row(
                    children: [
                      // BOUTON PAYS
                      GestureDetector(
                        onTap: _showCountryPicker,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.public_rounded,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                _country,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.keyboard_arrow_down_rounded,
                                  size: 14, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // BOUTON VILLE
                      GestureDetector(
                        onTap: _showCityPicker,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F0FE),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF1A73E8).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on_rounded,
                                  size: 14,
                                  color: Color(0xFF1A73E8)),
                              const SizedBox(width: 4),
                              Text(
                                _city,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF1A73E8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.keyboard_arrow_down_rounded,
                                  size: 14,
                                  color: Color(0xFF1A73E8)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // FILTRES PAR CATÉGORIE — scroll horizontal
                  SizedBox(
                    height: 34,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = _selectedCategory == category;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedCategory = category);
                            _loadEvents();
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF1A73E8)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF1A73E8)
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 14),
                ],
              ),
            ),

            // LISTE DES ÉVÉNEMENTS
            Expanded(
              child: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF1A73E8),
                ),
              )
                  : _events.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.event_busy_rounded,
                        size: 32,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Aucun événement trouvé',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Essayez une autre ville ou catégorie',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              )
                  : RefreshIndicator(
                onRefresh: _loadEvents,
                color: const Color(0xFF1A73E8),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    return _EventCard(
                      event: _events[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EventDetailScreen(
                              event: _events[index],
                              user: widget.user,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),

      // BOUTON FLOTTANT — uniquement pour les organisateurs
      floatingActionButton: widget.user.role == 'organizer'
          ? FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Créer',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        onPressed: () {},
      )
          : null,
    );
  }
}


// CARTE D'ÉVÉNEMENT
class _EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const _EventCard({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // IMAGE
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child: event.imageUrl.isNotEmpty
                  ? Image.network(
                event.imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
              )
                  : _placeholder(),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // BADGE SOURCE + PRIX
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: event.source == 'ticketmaster'
                              ? const Color(0xFFE8F0FE)
                              : const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          event.source == 'ticketmaster'
                              ? 'Ticketmaster'
                              : 'Eventbrite',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: event.source == 'ticketmaster'
                                ? const Color(0xFF1A73E8)
                                : const Color(0xFFE65100),
                          ),
                        ),
                      ),
                      Text(
                        event.price == 0.0
                            ? 'Gratuit'
                            : '${event.price.toStringAsFixed(0)} €',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: event.price == 0.0
                              ? Colors.green
                              : const Color(0xFF1A73E8),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // TITRE
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // DATE ET LIEU
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 12, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        '${event.date.day}/${event.date.month}/${event.date.year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.location_on_rounded,
                          size: 12, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.address,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 150,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A73E8), Color(0xFF4A90E2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.event_rounded, size: 40, color: Colors.white),
      ),
    );
  }
}