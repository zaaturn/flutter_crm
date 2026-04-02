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
  Timer? _expiryTimer;
  late Future<_GreetingData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    super.dispose();
  }

  bool _isFresh(PostModel p) {
    final now = DateTime.now();
    final difference = now.difference(p.createdAt);
    // Post is fresh if it was created less than 24 hours ago
    return difference.inHours < 24 && !difference.isNegative;
  }

  Future<_GreetingData> _loadData() async {
    final postRepo = context.read<PostRepository>();
    final storage = SecureStorageService();

    // Fetch posts and user data in parallel
    final results = await Future.wait([
      postRepo.fetchPosts(category: 'quote', pageSize: 1),
      postRepo.fetchPosts(category: 'announcement', pageSize: 1),
      storage.readUser(),
      storage.readUserId(),
    ]);

    final quotes = results[0] as List<PostModel>;
    final announcements = results[1] as List<PostModel>;

    final rawUser = results[2] as Map<String, dynamic>?;
    final rawUserId = results[3] as String?;

    final user = rawUser != null
        ? UserModel.fromJson(rawUser)
        : UserModel(
      id: int.tryParse(rawUserId ?? '') ?? 0,
      username: 'User',
      email: '',
      fullName: null,
    );

    final quote = quotes.isNotEmpty && _isFresh(quotes.first) ? quotes.first : null;
    final ann = announcements.isNotEmpty && _isFresh(announcements.first) ? announcements.first : null;

    // Calculate the next time we need to refresh (when the current post expires)
    _setupRefreshTimer(quote, ann);

    return _GreetingData(user: user, quote: quote, announcement: ann);
  }

  void _setupRefreshTimer(PostModel? q, PostModel? a) {
    _expiryTimer?.cancel();
    final now = DateTime.now();
    List<DateTime> expiryTimes = [];

    if (q != null) expiryTimes.add(q.createdAt.add(const Duration(hours: 24)));
    if (a != null) expiryTimes.add(a.createdAt.add(const Duration(hours: 24)));

    if (expiryTimes.isNotEmpty) {
      expiryTimes.sort();
      final nextExpiry = expiryTimes.first;
      final delay = nextExpiry.difference(now);

      if (delay > Duration.zero) {
        _expiryTimer = Timer(delay, () {
          if (mounted) setState(() => _dataFuture = _loadData());
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_GreetingData>(
      future: _dataFuture,
      builder: (context, snap) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          child: _buildState(snap),
        );
      },
    );
  }

  Widget _buildState(AsyncSnapshot<_GreetingData> snap) {
    if (snap.connectionState == ConnectionState.waiting) return const _GreetingShimmer();
    if (snap.hasError || snap.data == null) return const _GreetingError();

    final data = snap.data!;

    if (data.announcement != null) {
      return _AnnouncementCard(announcement: data.announcement!);
    } else if (data.quote != null) {
      return _QuoteCard(quote: data.quote!);
    } else {
      return _GreetingCard(user: data.user);
    }
  }
}

// ─── Data bundle ─────────────────────────────────────────────────────────────
class _GreetingData {
  const _GreetingData({required this.user, this.quote, this.announcement});
  final UserModel user;
  final PostModel? quote;
  final PostModel? announcement;
}

// ─── Modern Card Base ────────────────────────────────────────────────────────
class _ModernBase extends StatelessWidget {
  const _ModernBase({
    required this.colors,
    required this.icon,
    required this.child,
    this.onTap,
  });

  final List<Color> colors;
  final IconData icon;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(icon, size: 140, color: Colors.white.withOpacity(0.12)),
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

// ─── State 1: Default Greeting (Morning/Afternoon/Evening) ──────────────────
class _GreetingCard extends StatelessWidget {
  const _GreetingCard({required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final String label;
    final List<Color> palette;
    final IconData icon;

    if (hour < 12) {
      label = 'Good morning';
      palette = [const Color(0xFFFF9A8B), const Color(0xFFFF6A88)];
      icon = Icons.wb_twilight_rounded;
    } else if (hour < 18) {
      label = 'Good afternoon';
      palette = [const Color(0xFFF6D365), const Color(0xFFFDA085)];
      icon = Icons.wb_sunny_rounded;
    } else {
      label = 'Good evening';
      palette = [const Color(0xFF2E3192), const Color(0xFF1BFFFF)];
      icon = Icons.nights_stay_rounded;
    }

    return _ModernBase(
      colors: palette,
      icon: icon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.white.withOpacity(0.8),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hello, ${user.fullName ?? user.username}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Welcome back! Check your latest updates below.",
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

// ─── State 2: Quote of the Day ───────────────────────────────────────────────
class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.quote});
  final PostModel quote;

  @override
  Widget build(BuildContext context) {
    return _ModernBase(
      colors: [const Color(0xFF6A11CB), const Color(0xFF2575FC)],
      icon: Icons.format_quote_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'QUOTE OF THE DAY',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '"${_body(quote)}"',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              color: Colors.white,
              height: 1.4,
            ),
          ),
          if ((quote.createdByFullName ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              '— ${quote.createdByFullName}',
              style: const TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w500),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── State 3: Announcements ──────────────────────────────────────────────────
class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({required this.announcement});
  final PostModel announcement;

  @override
  Widget build(BuildContext context) {
    return _ModernBase(
      colors: [const Color(0xFFED213A), const Color(0xFF93291E)],
      icon: Icons.campaign_rounded,
      onTap: () => Navigator.of(context).pushNamed('/feed'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt, color: Colors.yellow, size: 18),
              const SizedBox(width: 4),
              Text(
                'IMPORTANT ANNOUNCEMENT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withOpacity(0.9),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _body(announcement),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Read More',
              style: TextStyle(color: Color(0xFF93291E), fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Utilities ───────────────────────────────────────────────────────────────
class _GreetingShimmer extends StatelessWidget {
  const _GreetingShimmer();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(child: CircularProgressIndicator(color: Colors.grey.shade400)),
    );
  }
}

class _GreetingError extends StatelessWidget {
  const _GreetingError();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red.shade100),
        borderRadius: BorderRadius.circular(24),
        color: Colors.red.shade50,
      ),
      child: const Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red),
          SizedBox(width: 12),
          Text('Failed to load greeting.', style: TextStyle(color: Colors.redAccent)),
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