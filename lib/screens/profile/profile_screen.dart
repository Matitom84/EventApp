import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/supabase_service.dart';
import '../auth/login_screen.dart';

// Page de profil de l'utilisateur
class ProfileScreen extends StatefulWidget {
  final AppUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  // mes variables
  int _reservationCount = 0;
  List<Map<String, dynamic>> _reservations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // je charge les réservations depuis supabase
  Future<void> _loadData() async {
    int count = await SupabaseService.countReservations(
      userPhone: widget.user.phone,
    );
    List<Map<String, dynamic>> list = await SupabaseService.getReservations(
      userPhone: widget.user.phone,
    );
    setState(() {
      _reservationCount = count;
      _reservations = list;
      _isLoading = false;
    });
  }

  // je calcule le total des places réservées avec une boucle
  int _getTotalPlaces() {
    int total = 0;
    for (var r in _reservations) {
      total = total + (r['number_of_places'] as int);
    }
    return total;
  }

  // je prends les initiales du nom
  // ex: "Mathys Robert" donne "MR"
  String _getInitials() {
    List<String> parts = widget.user.name.split(' ');
    if (parts.length >= 2) {
      String initials = parts[0][0] + parts[1][0];
      return initials.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  // déconnexion et retour à la page de connexion
  Future<void> _logout() async {
    await SupabaseService.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mon profil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ),
      // si ca charge on affiche un spinner sinon le contenu
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xFF1A73E8)),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // bannière avec les infos de l'utilisateur
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [

                  // cercle bleu avec les initiales
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFF1A73E8),
                    child: Text(
                      _getInitials(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // nom, téléphone et rôle
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // nom complet
                      Text(
                        widget.user.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0C447C),
                        ),
                      ),

                      // numéro de téléphone
                      Text(
                        '+${widget.user.phone}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF185FA5),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // badge avec le rôle
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A73E8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.user.role == 'organizer'
                              ? 'Organisateur'
                              : 'Participant',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // les 2 stats côte à côte
            Row(
              children: [

                // nombre de réservations
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$_reservationCount',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A73E8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Réservations',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // total de places réservées
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      children: [
                        Text(
                          // j'appelle ma fonction pour calculer le total
                          '${_getTotalPlaces()}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A73E8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Places réservées',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // liste des réservations si y'en a
            if (_reservations.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
                      child: Text(
                        'Mes réservations',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    // j'affiche max 3 réservations
                    ..._reservations.take(3).map((r) => ListTile(
                      leading: const Icon(
                        Icons.confirmation_number_rounded,
                        color: Color(0xFF1A73E8),
                      ),
                      title: Text(
                        r['event_title'] ?? '',
                        style: const TextStyle(fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${r['number_of_places']} place(s)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    )),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // bouton déconnexion
            GestureDetector(
              onTap: _logout,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      color: Colors.red.shade400,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Se déconnecter',
                      style: TextStyle(
                        color: Colors.red.shade400,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}