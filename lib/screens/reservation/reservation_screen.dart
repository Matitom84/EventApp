import 'package:flutter/material.dart';
import '../../models/event.dart';
import '../../models/user.dart';
import '../../services/supabase_service.dart';

// page de réservation d'un événement
// StatefulWidget car le nombre de places peut changer
class ReservationScreen extends StatefulWidget {

  // l'événement qu'on veut réserver
  final Event event;

  // l'utilisateur connecté
  final AppUser user;

  const ReservationScreen({
    super.key,
    required this.event,
    required this.user,
  });

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {

  // pour lire le nom et le téléphone tapés par l'utilisateur
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  // nombre de places choisi, 1 par défaut
  int _numberOfPlaces = 1;

  // true = on attend la réponse de supabase
  bool _isLoading = false;

  // pour valider le formulaire
  final _formKey = GlobalKey<FormState>();

  // initState est appelé une seule fois quand la page s'ouvre
  @override
  void initState() {
    super.initState();
    // on pré-remplit les champs avec les infos de l'utilisateur
    // pour qu'il n'ait pas à tout retaper
    _nameController.text = widget.user.name;
    _phoneController.text = widget.user.phone;
  }

  // fonction appelée quand on appuie sur "Confirmer"
  Future<void> _reserve() async {

    // on vérifie que les champs sont bien remplis
    if (!_formKey.currentState!.validate()) return;

    // on active le spinner
    setState(() {
      _isLoading = true;
    });

    // on sauvegarde la réservation dans supabase
    // la fonction renvoie true si ca a marché, false sinon
    bool success = await SupabaseService.saveReservation(
      userPhone: widget.user.phone,
      eventId: widget.event.id,
      eventTitle: widget.event.title,
      numberOfPlaces: _numberOfPlaces,
    );

    // on désactive le spinner
    setState(() {
      _isLoading = false;
    });

    if (success) {

      // réservation réussie, on affiche une popup de confirmation
      // showDialog affiche une fenêtre par dessus la page
      showDialog(
        context: context,
        // barrierDismissible = false = l'utilisateur ne peut pas
        // fermer la popup en tapant à côté
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            // mainAxisSize.min = la popup prend le minimum d'espace
            mainAxisSize: MainAxisSize.min,
            children: [

              // cercle vert avec une coche
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.green,
                  size: 36,
                ),
              ),

              const SizedBox(height: 16),

              // message de confirmation
              const Text(
                'Réservation confirmée !',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // on affiche le titre de l'événement réservé
              // widget.event.title = le titre de l'événement
              Text(
                'Votre réservation pour "${widget.event.title}" a bien été enregistrée.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          actions: [

            // bouton pour retourner à la page d'accueil
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A73E8),
                  foregroundColor: Colors.white,
                ),
                // popUntil ferme toutes les pages jusqu'à la première
                // donc on revient directement à la page d'accueil
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

      // erreur lors de la sauvegarde
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la réservation'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // on libère la mémoire quand la page est fermée
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Réserver',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // résumé de l'événement en haut
              // pour rappeler à l'utilisateur ce qu'il réserve
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
                      child: const Icon(
                        Icons.event_rounded,
                        color: Color(0xFF1A73E8),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // titre et date de l'événement
                    // Expanded = prend tout l'espace restant
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.event.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${widget.event.date.day}/${widget.event.date.month}/${widget.event.date.year}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // prix de l'événement
                    Text(
                      widget.event.price == 0.0
                          ? 'Gratuit'
                          : '${widget.event.price.toStringAsFixed(0)} €',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A73E8),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // section coordonnées
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

                    const Text(
                      'Vos coordonnées',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // champ nom - pré-rempli avec le nom de l'utilisateur
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom complet',
                        prefixIcon: Icon(Icons.person_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ce champ est obligatoire';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // champ téléphone - pré-rempli avec le numéro de l'utilisateur
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Téléphone',
                        prefixIcon: Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ce champ est obligatoire';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // section pour choisir le nombre de places
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

                    const Text(
                      'Nombre de places',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    // boutons + et - pour choisir le nombre de places
                    Row(
                      children: [

                        // bouton moins - désactivé si on est déjà à 1
                        GestureDetector(
                          // si _numberOfPlaces > 1 on peut diminuer
                          // sinon null = bouton désactivé
                          onTap: _numberOfPlaces > 1
                              ? () {
                            setState(() {
                              _numberOfPlaces = _numberOfPlaces - 1;
                            });
                          }
                              : null,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              // bleu si actif, gris si désactivé
                              color: _numberOfPlaces > 1
                                  ? const Color(0xFFE8F0FE)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.remove_rounded,
                              color: _numberOfPlaces > 1
                                  ? const Color(0xFF1A73E8)
                                  : Colors.grey,
                            ),
                          ),
                        ),

                        // affichage du nombre de places
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            '$_numberOfPlaces',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // bouton plus - désactivé si on est déjà à 10
                        GestureDetector(
                          // maximum 10 places
                          onTap: _numberOfPlaces < 10
                              ? () {
                            setState(() {
                              _numberOfPlaces = _numberOfPlaces + 1;
                            });
                          }
                              : null,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _numberOfPlaces < 10
                                  ? const Color(0xFFE8F0FE)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.add_rounded,
                              color: _numberOfPlaces < 10
                                  ? const Color(0xFF1A73E8)
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // total à payer - affiché seulement si l'événement est payant
              if (widget.event.price > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0FE),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      // on multiplie le prix par le nombre de places
                      Text(
                        '${(widget.event.price * _numberOfPlaces).toStringAsFixed(2)} €',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A73E8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // bouton confirmer la réservation
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _reserve,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A73E8),
                    foregroundColor: Colors.white,
                  ),
                  // spinner si chargement, sinon texte avec le nombre de places
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    // affiche "place" ou "places" selon le nombre
                    'Confirmer $_numberOfPlaces place${_numberOfPlaces > 1 ? 's' : ''}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}