import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/supabase_service.dart';

class CreateEventScreen extends StatefulWidget {
  final AppUser user;
  const CreateEventScreen({super.key, required this.user});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {

  // Les champs de texte
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();
  final TextEditingController _placesController = TextEditingController();

  DateTime _dateChoisie = DateTime.now(); // date de l'événement
  bool _chargement = false; // true = spinner affiché


  // Ouvre le sélecteur de date
  Future<void> _choisirDate() async {
    DateTime? dateSelectionnee = await showDatePicker(
      context: context,
      initialDate: _dateChoisie,
      firstDate: DateTime.now(),
      lastDate: DateTime(2027),
    );

    if (dateSelectionnee != null) {
      setState(() { _dateChoisie = dateSelectionnee; });
    }
  }


  // Sauvegarde l'événement dans Supabase
  Future<void> _creerEvenement() async {
    setState(() { _chargement = true; });

    // on convertit le prix en nombre décimal, 0.0 si vide
    double prix = 0.0;
    if (_prixController.text.isNotEmpty) {
      prix = double.parse(_prixController.text.trim());
    }

    // on convertit les places en entier, 0 si vide
    int places = 0;
    if (_placesController.text.isNotEmpty) {
      places = int.parse(_placesController.text.trim());
    }

    // on envoie tout à Supabase
    bool succes = await SupabaseService.createEvent(
      title: _titreController.text.trim(),
      description: _descriptionController.text.trim(),
      address: _adresseController.text.trim(),
      date: _dateChoisie.toIso8601String(),
      price: prix,
      maxPlaces: places,
      organizerPhone: widget.user.phone,
    );

    setState(() { _chargement = false; });

    if (succes) {
      // événement créé → message vert et retour à l'accueil
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Événement créé !'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      // erreur → message rouge
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la création'), backgroundColor: Colors.red),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un événement')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Champ titre
            const Text('Titre'),
            const SizedBox(height: 8),
            TextField(
              controller: _titreController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 16),

            // Champ description
            const Text('Description'),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 16),

            // Champ adresse
            const Text('Adresse'),
            const SizedBox(height: 8),
            TextField(
              controller: _adresseController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 16),

            // Sélecteur de date
            const Text('Date'),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _choisirDate,
              child: Text('${_dateChoisie.day}/${_dateChoisie.month}/${_dateChoisie.year}'),
            ),

            const SizedBox(height: 16),

            // Champ prix
            const Text('Prix (laisser vide = gratuit)'),
            const SizedBox(height: 8),
            TextField(
              controller: _prixController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 16),

            // Champ nombre de places
            const Text('Nombre de places (vide = illimité)'),
            const SizedBox(height: 8),
            TextField(
              controller: _placesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 24),

            // Bouton créer
            ElevatedButton(
              onPressed: _chargement ? null : _creerEvenement,
              child: _chargement
                  ? const CircularProgressIndicator()
                  : const Text('Créer l\'événement'),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}