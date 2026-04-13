import 'package:flutter/material.dart';
import '../../models/event.dart';
import '../../models/user.dart';
import '../../services/supabase_service.dart';
import '../reservation/reservation_screen.dart';
import 'package:url_launcher/url_launcher.dart';

// page detail d'un evenement
class EventDetailScreen extends StatelessWidget {

  final Event event; // l'event a afficher
  final AppUser user; // le user connecte

  const EventDetailScreen({super.key, required this.event, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      // CustomScrollView pour que l'image se cache quand on scrolle
      body: CustomScrollView(
        slivers: [

          // la barre en haut avec l'image de l'event
          SliverAppBar(
            expandedHeight: 240,
            pinned: true, // reste visible quand on scrolle
            backgroundColor: const Color(0xFF1A73E8),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: event.imageUrl.isNotEmpty
                  ? Image.network(
                event.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
              )
                  : _placeholder(), // si pas d'image on met le fond bleu
            ),
          ),

          // tout le contenu en dessous de l'image
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // la carte blanche avec les infos
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // le badge et le titre sur la meme ligne
                        Row(
                          children: [
                            // badge couleur selon d'ou vient l'event
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                // bleu ticketmaster / vert local / orange eventbrite
                                color: event.source == 'ticketmaster'
                                    ? const Color(0xFFE8F0FE)
                                    : event.source == 'supabase'
                                    ? const Color(0xFFE8F5E9)
                                    : const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                event.source == 'ticketmaster' ? 'Ticketmaster'
                                    : event.source == 'supabase' ? 'Local'
                                    : 'Eventbrite',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: event.source == 'ticketmaster'
                                      ? const Color(0xFF1A73E8)
                                      : event.source == 'supabase'
                                      ? Colors.green
                                      : const Color(0xFFE65100),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // nom de l'event
                            Expanded(
                              child: Text(
                                event.title,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),
                        Divider(color: Colors.grey.shade100),
                        const SizedBox(height: 12),

                        // date et prix sur la meme ligne
                        Row(
                          children: [
                            Expanded(
                              child: _Info(
                                icon: Icons.calendar_today_rounded,
                                label: 'Date',
                                // padLeft met un 0 si les minutes font 1 chiffre
                                value: '${event.date.day}/${event.date.month}/${event.date.year} ${event.date.hour}h${event.date.minute.toString().padLeft(2, '0')}',
                              ),
                            ),
                            Expanded(
                              child: _Info(
                                icon: Icons.euro_rounded,
                                label: 'Prix',
                                value: event.price == 0.0 ? 'Gratuit' : '${event.price.toStringAsFixed(2)} €',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // lieu et places sur la meme ligne
                        Row(
                          children: [
                            Expanded(
                              child: _Info(
                                icon: Icons.location_on_rounded,
                                label: 'Lieu',
                                value: event.address,
                              ),
                            ),
                            Expanded(
                              child: _Info(
                                icon: Icons.people_rounded,
                                label: 'Places',
                                value: event.maxPlaces == 0 ? 'Illimité' : '${event.maxPlaces} max',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),
                        Divider(color: Colors.grey.shade100),
                        const SizedBox(height: 10),

                        // la description
                        Text(
                          event.description.isEmpty ? 'Aucune description disponible' : event.description,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.5),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 16),

                        // si c'est un organisateur et que c'est son event
                        // on affiche la liste des gens inscrits
                        if (user.role == 'organizer' && event.source == 'supabase')
                          _ParticipantsList(eventTitle: event.title),

                        const SizedBox(height: 8),

                        // bouton reserver seulement pour les participants
                        if (user.role == 'client')
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              // icone differente si c'est un event local ou pas
                              icon: Icon(event.source == 'supabase'
                                  ? Icons.check_circle_rounded
                                  : Icons.confirmation_number_rounded),
                              label: Text(event.source == 'supabase'
                                  ? 'Je participe !'
                                  : 'Réserver une place'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: event.source == 'supabase'
                                    ? Colors.green
                                    : const Color(0xFF1A73E8),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                // on va sur la page de reservation
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ReservationScreen(event: event, user: user),
                                  ),
                                );
                              },
                            ),
                          ),

                        if (user.role == 'client' && event.url.isNotEmpty)
                          const SizedBox(height: 8),

                        // bouton pour aller sur le site officiel
                        if (event.url.isNotEmpty)
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.open_in_new_rounded),
                              label: const Text('Voir sur le site officiel'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF1A73E8),
                                side: const BorderSide(color: Color(0xFF1A73E8)),
                              ),
                              onPressed: () async {
                                // on ouvre le lien
                                final uri = Uri.parse(event.url);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                }
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // fond bleu si pas d'image
  Widget _placeholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A73E8), Color(0xFF4A90E2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(child: Icon(Icons.event_rounded, size: 64, color: Colors.white)),
    );
  }
}

// petit widget pour afficher une info avec une icone
// je l'utilise pour la date le prix le lieu et les places
class _Info extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Info({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF1A73E8)),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // label en gris
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              // la valeur
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}

// widget pour voir les gens inscrits a un event
// visible que pour les organisateurs
class _ParticipantsList extends StatefulWidget {
  final String eventTitle;
  const _ParticipantsList({required this.eventTitle});

  @override
  State<_ParticipantsList> createState() => _ParticipantsListState();
}

class _ParticipantsListState extends State<_ParticipantsList> {

  List<Map<String, dynamic>> _participants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // je charge les participants depuis supabase
  Future<void> _load() async {
    List<Map<String, dynamic>> list = await SupabaseService.getEventParticipants(
      eventTitle: widget.eventTitle,
    );
    setState(() {
      _participants = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // titre avec le nombre de participants
          Row(
            children: [
              const Icon(Icons.people_rounded, color: Colors.green, size: 18),
              const SizedBox(width: 8),
              Text(
                'Participants (${_participants.length})',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // chargement
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.green)),

          // personne inscrit
          if (!_isLoading && _participants.isEmpty)
            Text('Aucun participant pour l\'instant',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),

          // la liste
          if (!_isLoading && _participants.isNotEmpty)
            ..._participants.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.person_rounded, size: 14, color: Colors.green),
                  const SizedBox(width: 6),
                  Text('+${p['user_phone']}', style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 8),
                  Text('— ${p['number_of_places']} place(s)',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            )),
        ],
      ),
    );
  }
}