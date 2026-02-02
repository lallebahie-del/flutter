import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../app_language.dart';
import '../app_theme_manager.dart';

class MapPage extends StatefulWidget {
  final AppLanguage appLanguage;
  final AppThemeManager themeManager;

  const MapPage({
    super.key,
    required this.appLanguage,
    required this.themeManager,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _controller;
  final Set<Marker> _markers = {};
  bool _loading = true;
  
  // Default position (e.g., city center) if GPS fails
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(33.5731, -7.5898), // Casablanca example
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    _loadSignalements();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      _controller?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          14,
        ),
      );
    } catch (e) {
      // Ignore location errors, just stay on default
    }
  }

  Future<void> _loadSignalements() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('signalements').get();
      final markers = <Marker>{};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['latitude'] != null && data['longitude'] != null) {
          final lat = data['latitude'] as double;
          final lng = data['longitude'] as double;
          final status = data['status'] ?? 'En attente';
          final type = data['type'] ?? 'Signalement';

          markers.add(
            Marker(
              markerId: MarkerId(doc.id),
              position: LatLng(lat, lng),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                _getHueForStatus(status),
              ),
              infoWindow: InfoWindow(
                title: type,
                snippet: "$status - ${data['description'] ?? ''}",
              ),
            ),
          );
        }
      }

      if (mounted) {
        setState(() {
          _markers.addAll(markers);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  double _getHueForStatus(String status) {
    switch (status) {
      case 'En cours':
        return BitmapDescriptor.hueBlue;
      case 'Résolu':
        return BitmapDescriptor.hueGreen;
      case 'En attente':
      default:
        return BitmapDescriptor.hueOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Carte des Signalements"),
         backgroundColor: const Color(0xFF386641),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (controller) => _controller = controller,
          ),
          if (_loading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
