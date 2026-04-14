import 'package:flutter/material.dart';
import '../../models/event.dart';
import '../../models/user.dart';
import '../../services/supabase_service.dart';

class ReservationScreen extends StatefulWidget {
  final Event event; // l'événement à réserver
  final AppUser user; // l'utilisateur connecté

  const ReservationScreen({
    super.key,
    required this.event,
    required this.user,
  });

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {

  // Les champs de texte - pré-remplis avec les infos de l'utilisateur
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();

  int _nombrePlaces = 1;    // nombre de places choisi
  bool _chargement = false; // true = spinner affiché


  @override
  void initState() {
    super.initState();
    // on pré-remplit les champs avec les infos de l'utilisateur
    _nomController.text = widget.user.name;
    _telephoneController.text = widget.user.phone;
  }


  // Confirme la réservation et la sauvegarde dans Supabase
  Future<void> _reserver() async {
    setState(() { _chargement = true; }); // active le spinner

    // on envoie la réservation à Supabase
    bool succes = await SupabaseService.saveReservation(
      userPhone: widget.user.phone,
      eventId: widget.event.id,
      eventTitle: widget.event.title,
      numberOfPlaces: _nombrePlaces,
    );

    setState(() { _chargement = false; }); // désactive le spinner

    if (succes) {
      // réservation réussie → popup de confirmation
      showDialog(
        context: context,
        barrierDismissible: false, // on ne peut pas fermer en tapant à côté
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min, // popup prend le minimum d'espace
            children: [

              // cercle vert avec une coche
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Icon(Icons.check_rounded, color: Colors.green, size: 36),
              ),

              const SizedBox(height: 16),

              const Text(
                'Réservation confirmée !',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Text(
                'Votre réservation pour "${widget.event.title}" a bien été enregistrée.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A73E8),
                  foregroundColor: Colors.white,
                ),
                // popUntil ferme toutes les pages jusqu'à la première = accueil
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text('Retour à l\'accueil'),
              ),
            ),
          ],
        ),
      );

    } else {
      // erreur → message rouge
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la réservation'), backgroundColor: Colors.red),
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
        title: const Text('Réserver', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // résumé de l'événement
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                children: [

                  // icône calendrier
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.event_rounded, color: Color(0xFF1A73E8)),
                  ),

                  const SizedBox(width: 12),

                  // titre et date de l'événement
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.event.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${widget.event.date.day}/${widget.event.date.month}/${widget.event.date.year}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),

                  // prix de l'événement
                  Text(
                    widget.event.price == 0.0 ? 'Gratuit' : '${widget.event.price.toStringAsFixed(0)} €',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A73E8)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // coordonnées de l'utilisateur
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

                  const Text('Vos coordonnées', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),

                  // champ nom pré-rempli
                  TextField(
                    controller: _nomController,
                    decoration: const InputDecoration(
                      labelText: 'Nom complet',
                      prefixIcon: Icon(Icons.person_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // champ téléphone pré-rempli
                  TextField(
                    controller: _telephoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Téléphone',
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // sélecteur de nombre de places
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  const Text('Nombre de places', style: TextStyle(fontWeight: FontWeight.bold)),

                  Row(
                    children: [

                      // bouton moins - désactivé si on est à 1
                      GestureDetector(
                        onTap: _nombrePlaces > 1
                            ? () { setState(() { _nombrePlaces = _nombrePlaces - 1; }); }
                            : null,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _nombrePlaces > 1 ? const Color(0xFFE8F0FE) : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.remove_rounded,
                            color: _nombrePlaces > 1 ? const Color(0xFF1A73E8) : Colors.grey,
                          ),
                        ),
                      ),

                      // nombre de places affiché
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          '$_nombrePlaces',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),

                      // bouton plus - désactivé si on est à 10
                      GestureDetector(
                        onTap: _nombrePlaces < 10
                            ? () { setState(() { _nombrePlaces = _nombrePlaces + 1; }); }
                            : null,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _nombrePlaces < 10 ? const Color(0xFFE8F0FE) : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            color: _nombrePlaces < 10 ? const Color(0xFF1A73E8) : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),



            const SizedBox(height: 24),

            // bouton confirmer
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _chargement ? null : _reserver,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A73E8),
                  foregroundColor: Colors.white,
                ),
                child: _chargement
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                  // affiche "place" ou "places" selon le nombre
                  'Confirmer $_nombrePlaces place${_nombrePlaces > 1 ? 's' : ''}',
                  style: const TextStyle(fontSize: 16),
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