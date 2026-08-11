import 'package:flutter/material.dart';
import '../../services/location/isar_service.dart';
import '../../services/scoring/profile_service.dart';
import '../../services/scoring/user_profile.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// The Games tab: shows this month's XP, the (currently non-
/// functional) game mode cards, and a leaderboard placeholder.
class GamesScreen extends StatefulWidget {
  final IsarService isarService;

  const GamesScreen({super.key, required this.isarService});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  late Future<UserProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = ProfileService(widget.isarService.isar).getProfile();
  }

  Future<void> _refresh() async {
    setState(() {
      _profileFuture = ProfileService(widget.isarService.isar).getProfile();
    });
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature — coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.yellow,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<UserProfile>(
            future: _profileFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.black),
                );
              }

              final profile = snapshot.data!;

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: AppColors.black,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Center(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Monthly xp: ',
                              style: AppTypography.body(
                                color: AppColors.white,
                                fontSize: 14,
                              ),
                            ),
                            TextSpan(
                              text: '${profile.xp} xp',
                              style: AppTypography.heading(
                                color: AppColors.white,
                                fontSize: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: Text(
                      'Mods',
                      style: AppTypography.heading(
                        color: AppColors.black,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _ModCard(
                          title: 'Ghost Map',
                          onTap: () => _showComingSoon('Ghost Map'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ModCard(
                          title: 'Blind Ride',
                          onTap: () => _showComingSoon('Blind Ride'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () => _showComingSoon('Leaderboard'),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      decoration: BoxDecoration(
                        color: AppColors.black,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Text(
                          'Leaderboard',
                          style: AppTypography.heading(
                            color: AppColors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ModCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _ModCard({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.only(top: 20),
        child: Text(
          title,
          style: AppTypography.heading(color: AppColors.black, fontSize: 18),
        ),
      ),
    );
  }
}
