import 'package:flutter/material.dart';
import '../../models/event.dart';
import '../../models/user.dart';
import '../reservation/reservation_screen.dart';
import 'package:url_launcher/url_launcher.dart';

// page de détail d'un événement
// StatelessWidget car on affiche juste des infos, rien ne change
class EventDetailScreen extends StatelessWidget {

  // l'événement à afficher, reçu depuis la page d'accueil
  final Event event;

  // l'utilisateur connecté, pour savoir si c'est un client ou organisateur
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

      // CustomScrollView permet d'avoir une image qui se réduit
      // quand on fait défiler la page vers le haut
      body: CustomScrollView(
        slivers: [

          // SliverAppBar = barre du haut avec l'image de l'événement
          // quand on scrolle vers le haut l'image se réduit et la barre reste
          SliverAppBar(
            expandedHeight: 280, // hauteur de l'image au départ
            pinned: true, // la barre reste visible même quand on scrolle
            backgroundColor: const Color(0xFF1A73E8),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              // on affiche l'image de l'événement
              // si pas d'image on affiche un fond bleu à la place
              background: event.imageUrl.isNotEmpty
                  ? Image.network(
                event.imageUrl,
                fit: BoxFit.cover, // l'image remplit tout l'espace
                // si l'image ne charge pas on affiche le fond bleu
                errorBuilder: (_, __, ___) => _placeholder(),
              )
                  : _placeholder(),
            ),
          ),

          // SliverToBoxAdapter permet de mettre du contenu normal
          // dans un CustomScrollView
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // carte blanche avec les infos principales
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

                      // badge qui indique d'où vient l'événement
                      // bleu = Ticketmaster, orange = Eventbrite
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
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

                      // titre de l'événement
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // on utilise le widget _InfoRow pour afficher
                      // chaque info avec une icône, un label et une valeur
                      // c'est de la factorisation : on code une fois, on réutilise

                      // date et heure
                      // padLeft(2, '0') ajoute un 0 devant si besoin
                      // ex: 8 devient "08" pour afficher "20h08"
                      _InfoRow(
                        icon: Icons.calendar_today_rounded,
                        label: 'Date',
                        value: '${event.date.day}/${event.date.month}/${event.date.year} à ${event.date.hour}h${event.date.minute.toString().padLeft(2, '0')}',
                      ),

                      // lieu de l'événement
                      _InfoRow(
                        icon: Icons.location_on_rounded,
                        label: 'Lieu',
                        value: event.address,
                      ),

                      // prix - gratuit si 0.0
                      _InfoRow(
                        icon: Icons.euro_rounded,
                        label: 'Prix',
                        value: event.price == 0.0
                            ? 'Gratuit'
                            : '${event.price.toStringAsFixed(2)} €',
                      ),

                      // nombre de places disponibles
                      _InfoRow(
                        icon: Icons.people_rounded,
                        label: 'Places',
                        value: event.maxPlaces == 0
                            ? 'Non limité'
                            : '${event.maxPlaces} places max',
                      ),

                      // nom de l'organisateur
                      _InfoRow(
                        icon: Icons.person_rounded,
                        label: 'Organisateur',
                        value: event.organizer,
                      ),
                    ],
                  ),
                ),

                // carte blanche avec la description
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
                      // titre de la section
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // texte de la description
                      // height: 1.6 = interlignage pour que ce soit lisible
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

                // boutons en bas de la page
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  child: Column(
                    children: [

                      // bouton réserver visible uniquement pour les participants
                      // les organisateurs ne réservent pas d'événements
                      if (user.role == 'client')
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            // icône différente selon la source de l'événement
                            icon: Icon(event.source == 'supabase'
                                ? Icons.check_circle_rounded
                                : Icons.confirmation_number_rounded),
                            // texte différent selon la source
                            label: Text(event.source == 'supabase'
                                ? 'Je participe !'
                                : 'Réserver une place'),
                            style: ElevatedButton.styleFrom(
                              // vert pour les événements créés par un organisateur
                              // bleu pour les événements Ticketmaster et Eventbrite
                              backgroundColor: event.source == 'supabase'
                                  ? Colors.green
                                  : const Color(0xFF1A73E8),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            // quand on appuie on va sur la page de réservation
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

                      // espace entre les deux boutons
                      if (user.role == 'client') const SizedBox(height: 12),

                      // bouton pour voir la page officielle de l'événement
                      // visible seulement si l'événement a une URL
                      if (event.url.isNotEmpty)
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.open_in_new_rounded),
                            label: const Text('Voir sur le site officiel'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1A73E8),
                              side: const BorderSide(color: Color(0xFF1A73E8)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              // on convertit le lien en Uri pour pouvoir l'ouvrir
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
        ],
      ),
    );
  }

  // image bleue affichée quand l'événement n'a pas d'image
  Widget _placeholder() {
    return Container(
      decoration: const BoxDecoration(
        // dégradé de bleu de gauche à droite
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

// widget réutilisable pour afficher une ligne d'information
// on l'utilise pour la date, le lieu, le prix, les places et l'organisateur
// StatelessWidget car les données ne changent jamais
class _InfoRow extends StatelessWidget {

  final IconData icon; // l'icône à afficher
  final String label; // le texte gris en haut ex: "Date"
  final String value; // la valeur en dessous ex: "23/04/2026"

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

          // carré bleu avec l'icône
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

          // label et valeur empilés verticalement
          // Expanded = prend tout l'espace restant sur la ligne
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // label en gris et petit
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                // valeur en noir et un peu plus grande
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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