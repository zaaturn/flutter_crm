import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/dashboards/domain/models/post_model.dart';
import 'package:my_app/dashboards/domain/repository/post_repository.dart';
import 'package:my_app/dashboards/data/models/user_model.dart';
import 'package:my_app/services/secure_storage_service.dart';

class DashboardGreeting extends StatefulWidget {
  const DashboardGreeting({super.key});

  @override
  State<DashboardGreeting> createState() => _DashboardGreetingState();
}

class _DashboardGreetingState extends State<DashboardGreeting> {
  late PageController _pageController;
  Timer? _carouselTimer;
  int _currentPage = 0;

  List<Widget> _displayCards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _initData();
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    try {
      final postRepo = context.read<PostRepository>();
      final storage = SecureStorageService();

      final results = await Future.wait([
        postRepo.fetchPosts(category: 'quote', pageSize: 1),
        postRepo.fetchPosts(category: 'announcement', pageSize: 1),
        storage.readUser(),
      ]);

      final quotes = results[0] as List<PostModel>;
      final announcements = results[1] as List<PostModel>;
      final rawUser = results[2] as Map<String, dynamic>?;

      if (!mounted) return;

      final user = rawUser != null ? UserModel.fromJson(rawUser) : null;
      List<Widget> cards = [];

      // 1. Add Announcement if exists (Purple Theme)
      if (announcements.isNotEmpty) {
        cards.add(_AnnouncementCard(announcement: announcements.first));
      }

      // 2. Add Quote if exists (Purple Theme)
      if (quotes.isNotEmpty) {
        cards.add(_QuoteCard(quote: quotes.first));
      }

      // 3. Add Default Greeting (Purple Theme)
      cards.add(_GreetingCard(user: user));

      setState(() {
        _displayCards = cards;
        _isLoading = false;
      });

      if (_displayCards.length > 1) {
        _startAutoSlider();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startAutoSlider() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const _GreetingShimmer();
    if (_displayCards.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _displayCards[index % _displayCards.length],
              );
            },
            onPageChanged: (index) => setState(() => _currentPage = index),
          ),
        ),
        if (_displayCards.length > 1) ...[
          const SizedBox(height: 12),
          _buildPageIndicator(),
        ]
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_displayCards.length, (index) {
        bool isActive = (_currentPage % _displayCards.length) == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 6,
          width: isActive ? 22 : 6,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF7B39FD) : Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}

// ─── Shared Base Design (Restored Purple Gradient) ───────────────────────────
class _BillboardBase extends StatelessWidget {
  final Widget child;
  final IconData backgroundIcon;
  final VoidCallback? onTap;

  const _BillboardBase({
    required this.child,
    required this.backgroundIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          // RESTORED PURPLE THEME
          gradient: const LinearGradient(
            colors: [Color(0xFF8E44AD), Color(0xFF7B39FD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7B39FD).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: -15,
              bottom: -15,
              child: Icon(
                backgroundIcon,
                size: 140,
                color: Colors.white.withOpacity(0.12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Announcement Card ───────────────────────────────────────────────────────
class _AnnouncementCard extends StatelessWidget {
  final PostModel announcement;
  const _AnnouncementCard({required this.announcement});

  @override
  Widget build(BuildContext context) {
    return _BillboardBase(
      backgroundIcon: Icons.campaign_rounded,
      onTap: () => Navigator.of(context).pushNamed('/feed'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'IMPORTANT ANNOUNCEMENT',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.8),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _body(announcement),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Read More',
              style: TextStyle(
                color: Color(0xFF7B39FD),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quote Card ──────────────────────────────────────────────────────────────
class _QuoteCard extends StatelessWidget {
  final PostModel quote;
  const _QuoteCard({required this.quote});

  @override
  Widget build(BuildContext context) {
    return _BillboardBase(
      backgroundIcon: Icons.format_quote_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'DAILY QUOTE',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Text(
            '"${_body(quote)}"',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if ((quote.createdByFullName ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '— ${quote.createdByFullName}',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ]
        ],
      ),
    );
  }
}

// ─── Default Greeting ────────────────────────────────────────────────────────
class _GreetingCard extends StatelessWidget {
  final UserModel? user;
  const _GreetingCard({this.user});

  @override
  Widget build(BuildContext context) {
    return _BillboardBase(
      backgroundIcon: Icons.waving_hand_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'WELCOME BACK',
            style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Hello, ${user?.fullName ?? user?.username ?? "User"}!',
            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          const Text('You have new updates to check.', style: TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }
}

// ─── Utilities ───────────────────────────────────────────────────────────────
String _body(PostModel post) {
  final t = (post.title ?? '').trim();
  if (t.isNotEmpty) return t;
  final c = post.content.trim();
  return c.isNotEmpty ? c : 'New update posted.';
}

class _GreetingShimmer extends StatelessWidget {
  const _GreetingShimmer();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}
