import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  Color getColor(BuildContext context) {
    switch (status) {
      case 'Résolu':
        return Color(0xFF4CAF50);
      case 'En cours':
        return Color(0xFF2196F3);
      case 'En attente':
        return Color(0xFFFF9800);
      default:
        return Theme.of(context).colorScheme.secondary;
    }
  }

  Color getTextColor() {
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: getColor(context).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: getColor(context).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: getColor(context),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: getColor(context),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}