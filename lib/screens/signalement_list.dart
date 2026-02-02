import 'package:flutter/material.dart';
import '../models/signalement.dart';
import '../widgets/premium_layout.dart';
import '../widgets/status_chip.dart';
import '../app_theme_manager.dart';
import 'signalement_detail.dart';

class SignalementListScreen extends StatefulWidget {
  final AppThemeManager themeManager;

  const SignalementListScreen({
    super.key,
    required this.themeManager,
  });

  @override
  State<SignalementListScreen> createState() =>
      _SignalementListScreenState();
}

class _SignalementListScreenState extends State<SignalementListScreen> {
  final List<Signalement> signalements = [
    Signalement(
      id: '',
      userName: 'Ahmed Ali',
      type: 'Voirie',
      date: DateTime.now(),
      status: 'En attente',
      description: 'Route endommagée',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return PremiumLayout(
      title: "Signalements",
      themeManager: widget.themeManager,
      child: ListView.builder(
        itemCount: signalements.length,
        itemBuilder: (_, i) {
          final s = signalements[i];

          return GestureDetector(
            onTap: () async {
              final newStatus = await Navigator.push<String>(
                context,
                MaterialPageRoute(
                  builder: (_) => SignalementDetailScreen(
                    signalement: s,
                    themeManager: widget.themeManager,
                  ),
                ),
              );

              if (newStatus != null) {
                setState(() => s.status = newStatus);
              }
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.type,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text("Utilisateur : ${s.userName}"),
                  Text("Date : ${s.date.toString().split(' ')[0]}"),
                  const SizedBox(height: 8),
                  StatusChip(status: s.status),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
