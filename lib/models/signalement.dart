import 'package:cloud_firestore/cloud_firestore.dart';

class Signalement {
  final String id;
  final String userName;
  final String type;
  final DateTime date;
  String status;
  final String description;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;

  Signalement({
    required this.id,
    required this.userName,
    required this.type,
    required this.date,
    required this.status,
    required this.description,
    this.imageUrl,
    this.latitude,
    this.longitude,
  });

  factory Signalement.fromFirestore(String id, Map<String, dynamic> data) {
    return Signalement(
      id: id,
      userName: data['userName'] ?? 'Anonyme',
      type: data['type'] ?? 'Non spécifié',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'En attente',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'type': type,
      'date': Timestamp.fromDate(date),
      'status': status,
      'description': description,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
