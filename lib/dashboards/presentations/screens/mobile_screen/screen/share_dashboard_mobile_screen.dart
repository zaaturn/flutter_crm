import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widget/share_dashboard_cards.dart';
import '../widget/share_mobile_top_bar.dart';
import 'announcements_mobile_screen.dart';
import 'culture_boards_mobile_screen.dart';
import 'shared_items_mobile_screen.dart';

class ShareDashboardMobileScreen extends StatelessWidget {
  const ShareDashboardMobileScreen({super.key});

  static const Color _bgScreen = Color(0xFFFEF7F1);
  static const Color _textMain = Color(0xFF1A1C1E);
  static const Color _textMuted = Color(0xFF74777F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgScreen,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ShareMobileTopBar(
              title: 'Share',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard',
                      style: GoogleFonts.manrope(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: _textMain,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create and publish content for employee dashboards and feed.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                        color: _textMuted,
                      ),
                    ),
                    const SizedBox(height: 28),
                    ShareDashboardCards(
                      onAnnouncements: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const AnnouncementsMobileScreen(),
                        ),
                      ),
                      onSharedItems: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SharedItemsMobileScreen(),
                        ),
                      ),
                      onCultureBoards: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const CultureBoardsMobileScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}