import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShareDashboardCards extends StatelessWidget {
  const ShareDashboardCards({
    super.key,
    required this.onAnnouncements,
    required this.onSharedItems,
    required this.onCultureBoards,
  });

  final VoidCallback onAnnouncements;
  final VoidCallback onSharedItems;
  final VoidCallback onCultureBoards;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HeroCard(
          title: 'Announcements',
          subtitle: 'Broadcast important updates to the entire company.',
          icon: Icons.campaign_rounded,
          onTap: onAnnouncements,
          baseColor: const Color(0xFFE6A97A), // Your Orange
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _MiniCard(
                title: 'Shared Items',
                subtitle: 'Resources & docs',
                icon: Icons.folder_shared_rounded,
                onTap: onSharedItems,
                baseColor: const Color(0xFFB6C6E8), // Your Blue
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _MiniCard(
                title: 'Culture Boards',
                subtitle: 'Community feed',
                icon: Icons.groups_2_rounded,
                onTap: onCultureBoards,
                baseColor: const Color(0xFFAAD0B3), // Your Green
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.baseColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color baseColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: baseColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: const Color(0xFF1A1C1E), size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1A1C1E),
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1C1E).withOpacity(0.7),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.baseColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color baseColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: baseColor.withOpacity(0.25),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF1A1C1E), size: 22),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1A1C1E),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1C1E).withOpacity(0.6),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}