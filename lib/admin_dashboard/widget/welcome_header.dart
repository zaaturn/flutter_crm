import 'package:flutter/material.dart';

class WelcomeHeader extends StatefulWidget {
  final String adminName;
  final VoidCallback? onSearchTap;
  final Function(String)? onSearchChanged;

  const WelcomeHeader({
    super.key,
    this.adminName = 'Admin',
    this.onSearchTap,
    this.onSearchChanged,
  });

  @override
  State<WelcomeHeader> createState() => _WelcomeHeaderState();
}

class _WelcomeHeaderState extends State<WelcomeHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF6366F1).withOpacity(0.05),
                const Color(0xFF8B5CF6).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 20),
              _buildSearchBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final hour = DateTime.now().hour;
    String greeting = 'Good morning';
    IconData greetingIcon = Icons.wb_sunny_rounded;
    Color greetingColor = const Color(0xFFFBBF24);

    if (hour >= 12 && hour < 17) {
      greeting = 'Good afternoon';
      greetingIcon = Icons.wb_sunny_rounded;
      greetingColor = const Color(0xFFF59E0B);
    } else if (hour >= 17 && hour < 21) {
      greeting = 'Good evening';
      greetingIcon = Icons.wb_twilight_rounded;
      greetingColor = const Color(0xFFEF4444);
    } else if (hour >= 21 || hour < 6) {
      greeting = 'Good night';
      greetingIcon = Icons.nightlight_rounded;
      greetingColor = const Color(0xFF6366F1);
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: greetingColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      greetingIcon,
                      color: greetingColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$greeting, ${widget.adminName}! 👋',
                          style: const TextStyle(
                            color: Color(0xFF1F2937),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getCurrentDateString(),
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withOpacity(0.5),
                            blurRadius: 6,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Here's what's happening today",
                      style: TextStyle(
                        color: Color(0xFF6366F1),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _searchFocusNode.hasFocus
              ? const Color(0xFF6366F1)
              : const Color(0xFFE5E7EB),
          width: _searchFocusNode.hasFocus ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _searchFocusNode.hasFocus
                ? const Color(0xFF6366F1).withOpacity(0.1)
                : Colors.black.withOpacity(0.04),
            blurRadius: _searchFocusNode.hasFocus ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onTap: widget.onSearchTap,
        onChanged: widget.onSearchChanged,
        style: const TextStyle(
          color: Color(0xFF1F2937),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.search_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(
              Icons.clear_rounded,
              color: Color(0xFF9CA3AF),
            ),
            onPressed: () {
              setState(() {
                _searchController.clear();
              });
              if (widget.onSearchChanged != null) {
                widget.onSearchChanged!('');
              }
            },
          )
              : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                  ),
                ),
                child: const Text(
                  '⌘ K',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
          hintText: "Search employees, tasks, or events...",
          hintStyle: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  String _getCurrentDateString() {
    final now = DateTime.now();
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}

/// Alternative compact version for smaller screens
class WelcomeHeaderCompact extends StatelessWidget {
  final String adminName;
  final VoidCallback? onSearchTap;

  const WelcomeHeaderCompact({
    super.key,
    this.adminName = 'Admin',
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, $adminName! 👋',
                      style: const TextStyle(
                        color: Color(0xFF1F2937),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Manage your workspace",
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.dashboard_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onSearchTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: Color(0xFF9CA3AF),
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Quick search...",
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    '⌘ K',
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}