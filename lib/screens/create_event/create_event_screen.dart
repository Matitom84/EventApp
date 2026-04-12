import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/supabase_service.dart';

// page de création d'un événement
// uniquement accessible aux organisateurs
// StatefulWidget car on a des champs qui changent
class CreateEventScreen extends StatefulWidget {
  final AppUser user; // l'organisateur connecté
  const CreateEventScreen({super.key, required this.user});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {

  // controllers pour lire ce que l'organisateur tape
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _maxPlacesController = TextEditingController();

  // date choisie par l'organisateur
  DateTime _selectedDate = DateTime.now();

  // true = on attend la réponse de supabase
  bool _isLoading = false;

  // pour valider le formulaire
  final _formKey = GlobalKey<FormState>();

  // ouvre le sélecteur de date
  Future<void> _pickDate() async {
    // showDatePicker affiche une popup pour choisir une date
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(), // on ne peut pas choisir une date passée
      lastDate: DateTime(2027),
    );

    // si l'utilisateur a choisi une date on la sauvegarde
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // sauvegarde l'événement dans supabase
  Future<void> _createEvent() async {

    // on vérifie que tous les champs sont remplis
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // on convertit le prix en nombre décimal
    // si le champ est vide on met 0.0 (gratuit)
    double price = 0.0;
    if (_priceController.text.isNotEmpty) {
      price = double.parse(_priceController.text.trim());
    }

    // on convertit le nombre de places en entier
    // si le champ est vide on met 0 (illimité)
    int maxPlaces = 0;
    if (_maxPlacesController.text.isNotEmpty) {
      maxPlaces = int.parse(_maxPlacesController.text.trim());
    }

    // on sauvegarde dans la table events de supabase
    bool success = await SupabaseService.createEvent(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      address: _addressController.text.trim(),
      date: _selectedDate.toIso8601String(),
      price: price,
      maxPlaces: maxPlaces,
      organizerPhone: widget.user.phone,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      // événement créé, on affiche une confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Événement créé avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
      // on revient à la page d'accueil
      Navigator.pop(context);
    } else {
      // erreur
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la création'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // on libère la mémoire quand la page est fermée
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _maxPlacesController.dispose();
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
          'Créer un événement',
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

              // section infos principales
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
                      'Informations',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // champ titre
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Titre de l\'événement',
                        prefixIcon: Icon(Icons.event_rounded),
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

                    // champ description
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3, // plusieurs lignes pour la description
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        prefixIcon: Icon(Icons.description_rounded),
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

                    // champ adresse
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Adresse / Lieu',
                        prefixIcon: Icon(Icons.location_on_rounded),
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

              // section date
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
                      'Date',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // bouton pour ouvrir le sélecteur de date
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                color: Color(0xFF1A73E8)),
                            const SizedBox(width: 12),
                            // affiche la date choisie
                            Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // section prix et places
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
                      'Prix et places',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // champ prix - optionnel, laisser vide = gratuit
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Prix (laisser vide = gratuit)',
                        prefixIcon: Icon(Icons.euro_rounded),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // champ nombre de places - optionnel, laisser vide = illimité
                    TextFormField(
                      controller: _maxPlacesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de places (vide = illimité)',
                        prefixIcon: Icon(Icons.people_rounded),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // bouton créer l'événement
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A73E8),
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Créer l\'événement',
                    style: TextStyle(fontSize: 16),
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