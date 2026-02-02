import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/signalement.dart';
import '../widgets/premium_layout.dart';
import '../app_theme_manager.dart';

class SignalementDetailScreen extends StatelessWidget {
  final Signalement signalement;
  final AppThemeManager themeManager;

  const SignalementDetailScreen({
    super.key,
    required this.signalement,
    required this.themeManager,
  });

  void setStatus(BuildContext context, String status) {
    Navigator.pop(context, status);
  }

  @override
  Widget build(BuildContext context) {
    return PremiumLayout(
      title: "Détails du Signalement",
      themeManager: themeManager,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📸 IMAGE (if available)
            if (signalement.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  signalement.imageUrl!,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Image non disponible', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),
            
            if (signalement.imageUrl != null) const SizedBox(height: 24),

            // 📋 INFO CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    signalement.type,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.person_outline, "Utilisateur", signalement.userName),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.calendar_today, "Date", 
                    "${signalement.date.day}/${signalement.date.month}/${signalement.date.year} à ${signalement.date.hour}:${signalement.date.minute.toString().padLeft(2, '0')}"),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.info_outline, "Statut", signalement.status),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    signalement.description,
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 🗺️ MAP (if location available)
            if (signalement.latitude != null && signalement.longitude != null)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(signalement.latitude!, signalement.longitude!),
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId(signalement.id),
                        position: LatLng(signalement.latitude!, signalement.longitude!),
                      ),
                    },
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                  ),
                ),
              ),

            if (signalement.latitude != null && signalement.longitude != null)
              const SizedBox(height: 24),

            // 🎯 STATUS ACTIONS
            const Text(
              "Changer le statut",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatusButton(
                    context,
                    "En attente",
                    Colors.orange,
                    Icons.schedule,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatusButton(
                    context,
                    "En cours",
                    Colors.blue,
                    Icons.construction,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatusButton(
                    context,
                    "Résolu",
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF386641)),
        const SizedBox(width: 12),
        Text(
          "$label: ",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusButton(BuildContext context, String status, Color color, IconData icon) {
    final isCurrentStatus = signalement.status == status;
    
    return ElevatedButton(
      onPressed: isCurrentStatus ? null : () => setStatus(context, status),
      style: ElevatedButton.styleFrom(
        backgroundColor: isCurrentStatus ? color.withOpacity(0.3) : color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(
            status,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
