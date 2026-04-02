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

  bool _isFresh(PostModel p) =>
      DateTime.now().difference(p.createdAt) < const Duration(hours: 24);

  Future<_GreetingData> _loadData() async {
    final postRepo = context.read<PostRepository>();

    final results = await Future.wait([
      postRepo.fetchPosts(category: 'quote', pageSize: 1),
      postRepo.fetchPosts(category: 'announcement', pageSize: 1),
    ]);

    final quotes = results[0] as List<PostModel>;
    final announcements = results[1] as List<PostModel>;

    // Current user comes from locally stored login profile on web/desktop.
    final storage = SecureStorageService();
    final rawUser = await storage.readUser();
    final rawUserId = await storage.readUserId();
    final user = rawUser != null
        ? UserModel.fromJson(rawUser)
        : UserModel(
            id: int.tryParse(rawUserId ?? '') ?? 0,
            username: '',
            email: '',
            fullName: null,
          );

    final quote = quotes.isNotEmpty && _isFresh(quotes.first)
        ? quotes.first
        : null;
    final ann = announcements.isNotEmpty && _isFresh(announcements.first)
        ? announcements.first
        : null;

    final expiries = <Duration>[
      if (quote != null)
        const Duration(hours: 24) - DateTime.now().difference(quote.createdAt),
      if (ann != null)
        const Duration(hours: 24) - DateTime.now().difference(ann.createdAt),
    ].where((d) => d > Duration.zero).toList()..sort();

    _expiryTimer?.cancel();
    if (expiries.isNotEmpty) {
      _expiryTimer = Timer(expiries.first, () {
        if (!mounted) return;
        setState(() => _dataFuture = _loadData());
      });
    }

    return _GreetingData(user: user, quote: quote, announcement: ann);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_GreetingData>(
      future: _dataFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _GreetingShimmer();
        }
        if (snap.hasError || snap.data == null) {
          return const _GreetingError();
        }

        final data = snap.data!;
        if (data.announcement != null) {
          return _AnnouncementCard(
            user: data.user,
            announcement: data.announcement!,
          );
        }
        if (data.quote != null) {
          return _QuoteCard(user: data.user, quote: data.quote!);
        }
        return _GreetingCard(user: data.user);
      },
    );
  }
}

// ─── Data bundle ─────────────────────────────────────────────────────────────
class _GreetingData {
  const _GreetingData({
    required this.user,
    this.quote,
    this.announcement,
  });
  final UserModel user;
  final PostModel? quote;
  final PostModel? announcement;
}

// ─── Shared card shell ───────────────────────────────────────────────────────
class _CardShell extends StatelessWidget {
  const _CardShell({
    required this.iconBg,
    required this.icon,
    required this.decoIcon,
    required this.decoColor,
    required this.child,
  });

  final Color iconBg;
  final Widget icon;
  final IconData decoIcon;
  final Color decoColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: 0,
            bottom: 0,
            child: Center(
              child: Icon(decoIcon, size: 130, color: decoColor.withOpacity(0.07)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: icon,
                ),
                const SizedBox(width: 18),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── State 1: Default greeting ───────────────────────────────────────────────
class _GreetingCard extends StatelessWidget {
  const _GreetingCard({required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;

    final String label;
    final IconData icon;
    final Color color;

    if (hour < 12) {
      label = 'Good morning';
      icon = Icons.wb_sunny_rounded;
      color = const Color(0xFFE8A000);
    } else if (hour < 17) {
      label = 'Good afternoon';
      icon = Icons.wb_sunny_outlined;
      color = const Color(0xFFE8A000);
    } else {
      label = 'Good evening';
      icon = Icons.nights_stay_rounded;
      color = const Color(0xFF534AB7);
    }

    return _CardShell(
      iconBg: color.withOpacity(0.12),
      decoIcon: icon,
      decoColor: color,
      icon: Icon(icon, color: color, size: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: color,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Welcome back, ${user.displayLabel}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Here's your work overview for today.",
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B6880),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── State 2: Quote ──────────────────────────────────────────────────────────
class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.user, required this.quote});
  final UserModel user;
  final PostModel quote;

  @override
  Widget build(BuildContext context) {
    const brand = Color(0xFF534AB7);
    const brandDark = Color(0xFF26215C);
    const brandMid = Color(0xFF7F77DD);

    return _CardShell(
      iconBg: const Color(0xFFF0F0FF),
      decoIcon: Icons.format_quote_rounded,
      decoColor: brand,
      icon: const Icon(Icons.format_quote_rounded, color: brand, size: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'QUOTE OF THE DAY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: brand,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '"${_body(quote)}"',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              color: brandDark,
              height: 1.45,
            ),
          ),
          if ((quote.createdByFullName ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '— ${quote.createdByFullName}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: brandMid,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── State 3: Announcement ───────────────────────────────────────────────────
class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({required this.user, required this.announcement});
  final UserModel user;
  final PostModel announcement;

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFE24B4A);
    const redDark = Color(0xFFA32D2D);
    const redBg = Color(0xFFFFF0F0);

    return _CardShell(
      iconBg: redBg,
      decoIcon: Icons.mic_rounded,
      decoColor: red,
      icon: const Icon(Icons.mic_rounded, color: red, size: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NEW ANNOUNCEMENT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: redDark,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _body(announcement),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: redDark,
              letterSpacing: -0.3,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: redBg,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.graphic_eq_rounded, color: red, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'New announcement arrived — check your feed',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: redDark,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed('/feed'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: red,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      'Check feed',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Loading shimmer ──────────────────────────────────────────────────────────
class _GreetingShimmer extends StatelessWidget {
  const _GreetingShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFF534AB7),
        ),
      ),
    );
  }
}

// ─── Error state ─────────────────────────────────────────────────────────────
class _GreetingError extends StatelessWidget {
  const _GreetingError();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: const Row(
        children: [
          Icon(Icons.error_outline_rounded, color: Color(0xFFE24B4A), size: 28),
          SizedBox(width: 14),
          Text(
            'Could not load greeting. Pull to refresh.',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B6880)),
          ),
        ],
      ),
    );
  }
}

// ─── Helper ──────────────────────────────────────────────────────────────────
String _body(PostModel post) {
  final t = (post.title ?? '').trim();
  if (t.isNotEmpty) return t;
  final c = post.content.trim();
  return c.isNotEmpty ? c : 'New update posted.';
}