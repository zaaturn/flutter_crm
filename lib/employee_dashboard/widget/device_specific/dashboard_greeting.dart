import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/dashboards/domain/models/post_model.dart';
import 'package:my_app/dashboards/domain/repository/post_repository.dart';

class DashboardGreeting extends StatefulWidget {
  const DashboardGreeting({super.key});

  @override
  State<DashboardGreeting> createState() => _DashboardGreetingState();
}

class _DashboardGreetingState extends State<DashboardGreeting> {
  Timer? _expiryTimer;
  late Future<({PostModel? quote, PostModel? announcement})> _highlightsFuture;

  @override
  void initState() {
    super.initState();
    _highlightsFuture = _loadHighlights();
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    super.dispose();
  }

  bool _isFresh(PostModel p) =>
      DateTime.now().difference(p.createdAt) < const Duration(hours: 24);

  Future<({PostModel? quote, PostModel? announcement})> _loadHighlights() async {
    final repo = context.read<PostRepository>();
    final results = await Future.wait<List<PostModel>>([
      repo.fetchPosts(category: 'quote', pageSize: 1),
      repo.fetchPosts(category: 'announcement', pageSize: 1),
    ]);

    final quote = results[0].isNotEmpty && _isFresh(results[0].first)
        ? results[0].first
        : null;
    final ann = results[1].isNotEmpty && _isFresh(results[1].first)
        ? results[1].first
        : null;

    final expiries = <Duration>[
      if (quote != null)
        const Duration(hours: 24) - DateTime.now().difference(quote.createdAt),
      if (ann != null)
        const Duration(hours: 24) - DateTime.now().difference(ann.createdAt),
    ].where((d) => d > Duration.zero).toList(growable: false);

    _expiryTimer?.cancel();
    if (expiries.isNotEmpty) {
      expiries.sort();
      _expiryTimer = Timer(expiries.first, () {
        if (!mounted) return;
        setState(() {
          _highlightsFuture = _loadHighlights();
        });
      });
    }

    return (quote: quote, announcement: ann);
  }

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;

    String greeting;
    IconData icon;

    if (hour < 12) {
      greeting = "Good Morning";
      icon = Icons.wb_sunny_rounded;
    } else if (hour < 17) {
      greeting = "Good Afternoon";
      icon = Icons.wb_sunny_outlined;
    } else {
      greeting = "Good Evening";
      icon = Icons.nights_stay_rounded;
    }

    return FutureBuilder<({PostModel? quote, PostModel? announcement})>(
      future: _highlightsFuture,
      builder: (context, snap) {
        final data = snap.data;
        final quote = data?.quote;
        final ann = data?.announcement;
        final hasAny = quote != null || ann != null;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                quote != null
                    ? Icons.format_quote_rounded
                    : (ann != null ? Icons.campaign_rounded : icon),
                color: Colors.white,
                size: 38,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quote != null
                          ? 'Quote'
                          : (ann != null ? 'Announcement' : greeting),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (!hasAny)
                      Text(
                        "Here’s your work overview for today",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.92),
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                      )
                    else ...[
                      if (quote != null)
                        Text(
                          _highlightBody(quote),
                          maxLines: ann != null ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.94),
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                      if (ann != null) ...[
                        if (quote != null) const SizedBox(height: 6),
                        Text(
                          'Announcement: ${_highlightBody(ann)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.90),
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              if (hasAny) ...[
                const SizedBox(width: 14),
                TextButton(
                  onPressed: () => Navigator.of(context).pushNamed('/feed'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  child: const Text('OPEN FEED'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

String _highlightBody(PostModel post) {
  final t = (post.title ?? '').trim();
  if (t.isNotEmpty) return t;
  final c = post.content.trim();
  if (c.isNotEmpty) return c;
  return 'New update posted.';
}
