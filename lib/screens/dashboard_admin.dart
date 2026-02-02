import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../models/signalement.dart';
import '../widgets/premium_layout.dart';
import '../widgets/status_chip.dart';
import '../app_theme_manager.dart';
import 'signalement_detail.dart';

class DashboardAdmin extends StatelessWidget {
  final AppThemeManager themeManager;

  const DashboardAdmin({
    super.key,
    required this.themeManager,
  });

  Stream<List<Signalement>> getSignalements() {
    return FirebaseFirestore.instance
        .collection('signalements')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Signalement.fromFirestore(doc.id, doc.data());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PremiumLayout(
      title: "Dashboard Admin",
      themeManager: themeManager,
      actions: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            tooltip: "Déconnexion",
            icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 22),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                    (route) => false,
              );
            },
          ),
        ),
      ],
      child: StreamBuilder<List<Signalement>>(
        stream: getSignalements(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF386641),
                          Color(0xFF4FD1A5),

                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Chargement des signalements...",
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color:Color(0xFF386641).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.inbox_outlined,
                      size: 60,
                      color: Color(0xFF1BA37A).withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Aucun signalement",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Les nouveaux signalements apparaîtront ici",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final signalements = snapshot.data!;
          final total = signalements.length;
          final resolved = signalements.where((s) => s.status == 'Résolu').length;
          final inProgress = signalements.where((s) => s.status == 'En cours').length;

          return RefreshIndicator(
            backgroundColor: Color(0xFF1BA37A),
            color: Colors.white,
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 800));
            },
            child: CustomScrollView(
              slivers: [

                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF1BA37A).withOpacity(0.1),
                          Color(0xFF4FD1A5).withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Color(0xFF1BA37A).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Statistiques",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatCard(
                              context,
                              "Total",
                              "$total",
                              Icons.list_alt_rounded,
                              Color(0xFF1BA37A),
                            ),
                            _buildStatCard(
                              context,
                              "En cours",
                              "$inProgress",
                              Icons.schedule_rounded,
                              Color(0xFF2196F3),
                            ),
                            _buildStatCard(
                              context,
                              "Résolus",
                              "$resolved",
                              Icons.check_circle_rounded,
                              Color(0xFF4CAF50),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 📋 LISTE DES SIGNALEMENTS
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final s = signalements[index];
                        return _buildSignalementCard(context, s, index);
                      },
                      childCount: signalements.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignalementCard(BuildContext context, Signalement s, int index) {
    final formattedDate = DateFormat('dd MMM yyyy', 'fr_FR').format(s.date);
    final formattedTime = DateFormat('HH:mm', 'fr_FR').format(s.date);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTapDown: (_) => HapticFeedback.lightImpact(),
        onTap: () async {
          final newStatus = await Navigator.push<String>(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 300),
              pageBuilder: (_, __, ___) => SignalementDetailScreen(
                signalement: s,
                themeManager: themeManager,
              ),
              transitionsBuilder: (_, animation, __, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                );
              },
            ),
          );

          if (newStatus != null) {
            FirebaseFirestore.instance
                .collection('signalements')
                .doc(s.id)
                .update({'status': newStatus});
          }
        },
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 400 + (index * 100)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🎨 INDICATEUR DE TYPE
                  Container(
                    width: 4,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF1BA37A),
                          Color(0xFF4FD1A5),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // 📸 IMAGE THUMBNAIL (if available)
                  if (s.imageUrl != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        s.imageUrl!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],

                  // 📝 CONTENU
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                s.type,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            StatusChip(status: s.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              size: 16,
                              color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.5),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              s.userName,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 16,
                              color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.5),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$formattedDate à $formattedTime',
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 🔽 INDICATEUR D'ACTION
                  const SizedBox(width: 12),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}