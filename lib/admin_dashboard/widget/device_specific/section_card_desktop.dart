import 'package:flutter/material.dart';

/// Desktop-optimized Section Card Widget - Promove Design Style
/// Production-ready reusable container with clean, modern UI
class DesktopSectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final bool showBorder;
  final VoidCallback? onTap;

  const DesktopSectionCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.showBorder = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardContent = Container(
      margin: margin ?? const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: backgroundColor ??
            (isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF)),
        borderRadius: BorderRadius.circular(20),
        border: showBorder
            ? Border.all(
          color: isDark
              ? const Color(0xFF334155)
              : const Color(0xFFE2E8F0),
          width: 1,
        )
            : null,
      ),
      child: Padding(
        padding: padding ??
            const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: child,
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}

/// Desktop Section Card with Header
/// Includes built-in header with icon, title, subtitle, and optional action button
class DesktopSectionCardWithHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget child;
  final VoidCallback? onActionTap;
  final String? actionLabel;
  final Color? iconGradientStart;
  final Color? iconGradientEnd;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const DesktopSectionCardWithHeader({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.child,
    this.onActionTap,
    this.actionLabel,
    this.iconGradientStart,
    this.iconGradientEnd,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(isDark),
          _buildDivider(isDark),
          Padding(
            padding: padding ?? const EdgeInsets.all(24),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        iconGradientStart ?? const Color(0xFF0D3199),
                        iconGradientEnd ?? const Color(0xFF1E40AF),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          if (onActionTap != null) _buildActionButton(isDark),
        ],
      ),
    );
  }

  Widget _buildActionButton(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D3199),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D3199).withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onActionTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  actionLabel ?? "View All",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      height: 1,
      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
    );
  }
}

/// Compact Desktop Section Card
/// Lighter version with less padding for smaller content
class DesktopSectionCardCompact extends StatelessWidget {
  final Widget child;
  final EdgeInsets? margin;
  final VoidCallback? onTap;

  const DesktopSectionCardCompact({
    super.key,
    required this.child,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardContent = Container(
      margin: margin ?? const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}

/// Gradient Desktop Section Card
/// Card with gradient background
class DesktopSectionCardGradient extends StatelessWidget {
  final Widget child;
  final List<Color>? gradientColors;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;

  const DesktopSectionCardGradient({
    super.key,
    required this.child,
    this.gradientColors,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      margin: margin ?? const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors ??
              [
                const Color(0xFF0D3199),
                const Color(0xFF1E40AF),
              ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (gradientColors?.first ?? const Color(0xFF0D3199))
                .withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(24),
        child: child,
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}

/// Desktop Section Card with Stats
/// Card optimized for displaying statistics/metrics
class DesktopSectionCardStats extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsets? margin;

  const DesktopSectionCardStats({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = iconColor ?? const Color(0xFF0D3199);

    final cardContent = Container(
      margin: margin ?? const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              size: 28,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}

/// Example Usage Widget
class DesktopSectionCardExamples extends StatelessWidget {
  const DesktopSectionCardExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Card
          DesktopSectionCard(
            child: Text(
              'Basic Section Card',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),

          // Card with Header
          DesktopSectionCardWithHeader(
            title: 'Projects & Tasks',
            subtitle: '12 active projects',
            icon: Icons.work_outline_rounded,
            onActionTap: () {},
            child: const Text('Content goes here...'),
          ),

          // Compact Card
          DesktopSectionCardCompact(
            child: const Text('Compact card with less padding'),
          ),

          // Gradient Card
          DesktopSectionCardGradient(
            gradientColors: const [Color(0xFFFF8C32), Color(0xFFFF6B35)],
            child: const Text(
              'Gradient Card',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),

          // Stats Card
          DesktopSectionCardStats(
            title: 'Total Users',
            value: '1,234',
            icon: Icons.people_outline_rounded,
            iconColor: const Color(0xFF10B981),
            subtitle: '+12% from last month',
            trailing: const Icon(
              Icons.trending_up_rounded,
              color: Color(0xFF10B981),
            ),
          ),

          // Custom colored card
          DesktopSectionCard(
            backgroundColor: const Color(0xFFF1F5F9),
            padding: const EdgeInsets.all(32),
            child: const Center(
              child: Text('Custom Background Color'),
            ),
          ),

          // Clickable card
          DesktopSectionCard(
            onTap: () {
              // Handle tap
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Clickable Card'),
                Icon(Icons.arrow_forward_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }
}