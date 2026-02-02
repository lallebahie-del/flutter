import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_language.dart';
import '../app_theme_manager.dart';

class ReportPage extends StatefulWidget {
  final AppLanguage appLanguage;
  final AppThemeManager themeManager;

  const ReportPage({
    super.key,
    required this.appLanguage,
    required this.themeManager,
  });

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();
  
  File? _imageFile;
  String? _selectedCategory;
  bool _loading = false;
  Position? _currentPosition;
  String? _error;

  final List<String> _categories = [
    'Voirie',
    'Éclairage',
    'Déchets',
    'Eau',
    'Électricité',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the 
      // App to enable the location services.
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return;
    } 

    _currentPosition = await Geolocator.getCurrentPosition();
    if (mounted) setState(() {});
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      setState(() => _error = "Erreur lors de la sélection de l'image");
    }
  }

  Future<void> _submitReport() async {
    if (_selectedCategory == null || _descriptionController.text.isEmpty) {
      setState(() => _error = "Veuillez remplir tous les champs");
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Utilisateur non connecté");

      String? imageUrl;

      // Upload Image if selected
      if (_imageFile != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('reports')
            .child('${DateTime.now().millisecondsSinceEpoch}_${user.uid}.jpg');
            
        await ref.putFile(_imageFile!);
        imageUrl = await ref.getDownloadURL();
      }

      // Save to Firestore
      await FirebaseFirestore.instance.collection('signalements').add({
        'userId': user.uid,
        'userName': user.displayName ?? user.email ?? 'Anonyme', // Fallback
        'type': _selectedCategory,
        'description': _descriptionController.text.trim(),
        'imageUrl': imageUrl,
        'latitude': _currentPosition?.latitude,
        'longitude': _currentPosition?.longitude,
        'status': 'En attente',
        'date': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signalement envoyé avec succès !")),
        );
      }
    } catch (e) {
      setState(() => _error = "Erreur lors de l'envoi : $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Basic scaffold for now, can be upgraded to PremiumLayout if desired but simpler for form
    final isDark = widget.themeManager.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nouveau Signalement"),
        backgroundColor: const Color(0xFF386641),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),

            // 📸 Photo Section
            GestureDetector(
              onTap: () => _showImageSourceModal(context),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _imageFile != null ? const Color(0xFF386641) : Colors.transparent,
                    width: 2,
                  ),
                  image: _imageFile != null
                      ? DecorationImage(
                          image: FileImage(_imageFile!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _imageFile == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_rounded,
                            size: 48,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Ajouter une photo",
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
            
            const SizedBox(height: 24),

            // 📍 Location Status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _currentPosition != null 
                    ? Colors.green.withOpacity(0.1) 
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                   Icon(
                    _currentPosition != null ? Icons.location_on : Icons.location_off,
                    color: _currentPosition != null ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _currentPosition != null 
                          ? "Position GPS acquise"
                          : "Recherche de la position...",
                      style: TextStyle(
                        color: _currentPosition != null ? Colors.green : Colors.orange[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_currentPosition == null)
                    const SizedBox(
                      width: 16, 
                      height: 16, 
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 📋 Category
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: "Catégorie",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF386641), width: 2),
                ),
              ),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _selectedCategory = v),
            ),

            const SizedBox(height: 16),

            // 📝 Description
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Description du problème",
                alignLabelWithHint: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF386641), width: 2),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 🚀 Submit Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF386641),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "ENVOYER LE SIGNALEMENT",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourceModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galerie'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Caméra'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }
}
