import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/dashboards/domain/models/post_model.dart';
import 'package:my_app/dashboards/domain/repository/post_repository.dart';
import 'package:my_app/dashboards/data/models/user_model.dart';
import 'package:my_app/services/secure_storage_service.dart';

const Duration _kPostFreshness = Duration(hours: 24);

String _timeGreetingLine() {
  final h = DateTime.now().hour;
  if (h < 12) return 'Good morning';
  if (h < 17) return 'Good afternoon';
  return 'Good evening';
}

String _timeGreetingSubtitle() {
  final h = DateTime.now().hour;
  if (h < 12) return 'Hope you have a productive morning.';
  if (h < 17) return 'Keep the momentum going this afternoon.';
  return 'Wrap up well — you did great today.';
}

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

  static bool _isFresh(PostModel post) {
    final age = DateTime.now().difference(post.createdAt);
    return age <= _kPostFreshness;
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

      final freshAnnouncement =
          announcements.isNotEmpty && _isFresh(announcements.first)
              ? announcements.first
              : null;
      final freshQuote =
          quotes.isNotEmpty && _isFresh(quotes.first) ? quotes.first : null;

      final cards = <Widget>[
        freshAnnouncement != null
            ? _AnnouncementCard(announcement: freshAnnouncement)
            : const _EmptyAnnouncementSlide(),
        freshQuote != null
            ? _QuoteCard(quote: freshQuote)
            : const _EmptyQuoteSlide(),
        _TimeGreetingCard(user: user),
      ];

      setState(() {
        _displayCards = cards;
        _isLoading = false;
      });

      _carouselTimer?.cancel();
      if (_displayCards.length > 1) {
        _startAutoSlider();
      }
    } catch (e) {
      if (!mounted) return;
      final user = await _readUserSafe();
      if (!mounted) return;
      setState(() {
        _displayCards = [
          const _EmptyAnnouncementSlide(),
          const _EmptyQuoteSlide(),
          _TimeGreetingCard(user: user),
        ];
        _isLoading = false;
      });
      _carouselTimer?.cancel();
      if (_displayCards.length > 1) {
        _startAutoSlider();
      }
    }
  }

  Future<UserModel?> _readUserSafe() async {
    try {
      final raw = await SecureStorageService().readUser();
      if (raw == null) return null;
      return UserModel.fromJson(raw);
    } catch (_) {
      return null;
    }
  }

  void _startAutoSlider() {
    _carouselTimer?.cancel();
    final n = _displayCards.length;
    if (n <= 1) return;
    _carouselTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_pageController.hasClients || !mounted) return;
      final next = (_currentPage + 1) % n;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const _GreetingShimmer();
    if (_displayCards.isEmpty) return const SizedBox.shrink();

    final n = _displayCards.length;

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            itemCount: n,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _displayCards[index],
              );
            },
            onPageChanged: (index) => setState(() => _currentPage = index),
          ),
        ),
        if (n > 1) ...[
          const SizedBox(height: 12),
          _buildPageIndicator(n),
        ],
      ],
    );
  }

  Widget _buildPageIndicator(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = _currentPage == index;
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

class _EmptyAnnouncementSlide extends StatelessWidget {
  const _EmptyAnnouncementSlide();

  @override
  Widget build(BuildContext context) {
    return _BillboardBase(
      backgroundIcon: Icons.campaign_rounded,
      onTap: () => Navigator.of(context, rootNavigator: true).pushNamed('/feed'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'ANNOUNCEMENTS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.85),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No announcement today',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Let's catch up — check the feed for updates.",
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyQuoteSlide extends StatelessWidget {
  const _EmptyQuoteSlide();

  @override
  Widget build(BuildContext context) {
    return _BillboardBase(
      backgroundIcon: Icons.format_quote_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'DAILY QUOTE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.85),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No quote today',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Take a breath — small steps still move you forward.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontStyle: FontStyle.italic,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final PostModel announcement;
  const _AnnouncementCard({required this.announcement});

  @override
  Widget build(BuildContext context) {
    return _BillboardBase(
      backgroundIcon: Icons.campaign_rounded,
      onTap: () => Navigator.of(context, rootNavigator: true).pushNamed('/feed'),
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
          Text(
            'DAILY QUOTE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.85),
            ),
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
          ],
        ],
      ),
    );
  }
}

class _TimeGreetingCard extends StatelessWidget {
  final UserModel? user;
  const _TimeGreetingCard({this.user});

  @override
  Widget build(BuildContext context) {
    final line = _timeGreetingLine();
    final name = user?.displayLabel ?? 'there';

    return _BillboardBase(
      backgroundIcon: Icons.waving_hand_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            line.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.85),
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$line, $name!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            _timeGreetingSubtitle(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

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
