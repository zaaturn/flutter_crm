import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../theme/analytics_theme.dart';
import 'package:my_app/core/widgets/analytics_icons.dart';

class AnalyticsShimmerGrid extends StatelessWidget {
  final bool mobile;

  const AnalyticsShimmerGrid({super.key, this.mobile = false});

  @override
  Widget build(BuildContext context) {
    final base = mobile
        ? AnalyticsMobileTheme.card
        : AnalyticsDesktopTheme.border;
    final highlight = mobile
        ? AnalyticsMobileTheme.field
        : AnalyticsDesktopTheme.purpleLight;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Shimmer.fromColors(
        baseColor: base,
        highlightColor: highlight,
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.5,
          ),
          itemCount: 6,
          itemBuilder: (_, __) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}

class AnalyticsShimmerList extends StatelessWidget {
  const AnalyticsShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Shimmer.fromColors(
        baseColor: AnalyticsDesktopTheme.border,
        highlightColor: AnalyticsDesktopTheme.purpleLight,
        child: Column(
          children: List.generate(
            5,
            (_) => Container(
              height: 52,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AnalyticsErrorRetry extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;
  final bool mobile;

  const AnalyticsErrorRetry({
    super.key,
    this.message,
    required this.onRetry,
    this.mobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent =
        mobile ? AnalyticsMobileTheme.terracotta : AnalyticsDesktopTheme.purple;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnalyticsIcon(type: AnalyticsIconType.cloudOff, size: 48, color: accent),
            const SizedBox(height: 16),
            Text(
              message ?? 'Unable to load analytics data.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: mobile
                    ? AnalyticsMobileTheme.textMuted
                    : AnalyticsDesktopTheme.textMuted,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(backgroundColor: accent),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  AnalyticsIcon(
                    type: AnalyticsIconType.refresh,
                    size: 18,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8),
                  Text('Retry'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnalyticsRefreshable extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final bool mobile;

  const AnalyticsRefreshable({
    super.key,
    required this.onRefresh,
    required this.child,
    this.mobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: mobile
          ? AnalyticsMobileTheme.terracotta
          : AnalyticsDesktopTheme.purple,
      onRefresh: onRefresh,
      child: child,
    );
  }
}
