import 'package:flutter/material.dart';
import '../../models/event.dart';
import '../../models/user.dart';
import '../reservation/reservation_screen.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;
  final AppUser user;

  const EventDetailScreen({
    super.key,
    required this.event,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [

          // BARRE DU HAUT AVEC IMAGE
          // Se réduit quand on scrolle — effet moderne
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF1A73E8),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: event.imageUrl.isNotEmpty
                  ? Image.network(
                event.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
              )
                  : _placeholder(),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // CARTE PRINCIPALE
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // BADGE SOURCE
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: event.source == 'ticketmaster'
                              ? const Color(0xFFE8F0FE)
                              : const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          event.source == 'ticketmaster'
                              ? 'Ticketmaster'
                              : 'Eventbrite',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: event.source == 'ticketmaster'
                                ? const Color(0xFF1A73E8)
                                : const Color(0xFFE65100),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // TITRE
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // INFOS
                      _InfoRow(
                        icon: Icons.calendar_today_rounded,
                        label: 'Date',
                        value:
                        '${event.date.day}/${event.date.month}/${event.date.year} à ${event.date.hour}h${event.date.minute.toString().padLeft(2, '0')}',
                      ),
                      _InfoRow(
                        icon: Icons.location_on_rounded,
                        label: 'Lieu',
                        value: event.address,
                      ),
                      _InfoRow(
                        icon: Icons.euro_rounded,
                        label: 'Prix',
                        value: event.price == 0.0
                            ? 'Gratuit'
                            : '${event.price.toStringAsFixed(2)} €',
                      ),
                      _InfoRow(
                        icon: Icons.people_rounded,
                        label: 'Places',
                        value: event.maxPlaces == 0
                            ? 'Non limité'
                            : '${event.maxPlaces} places max',
                      ),
                      _InfoRow(
                        icon: Icons.person_rounded,
                        label: 'Organisateur',
                        value: event.organizer,
                      ),
                    ],
                  ),
                ),

                // CARTE DESCRIPTION
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        event.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),

                // BOUTONS
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  child: Column(
                    children: [

                      // BOUTON RÉSERVER — uniquement pour les clients
                      if (user.role == 'client')
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.confirmation_number_rounded),
                            label: const Text(
                              'Réserver une place',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A73E8),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ReservationScreen(
                                    event: event,
                                    user: user,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      if (user.role == 'client') const SizedBox(height: 12),

                      // BOUTON SITE OFFICIEL
                      if (event.url.isNotEmpty)
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.open_in_new_rounded),
                            label: const Text(
                              'Voir sur le site officiel',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1A73E8),
                              side: const BorderSide(
                                  color: Color(0xFF1A73E8)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {},
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A73E8), Color(0xFF4A90E2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.event_rounded, size: 64, color: Colors.white),
      ),
    );
  }
}

// LIGNE D'INFO RÉUTILISABLE
// Factorisation — on code une seule fois et on réutilise partout
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF1A73E8)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}