import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/admin_dashboard_bloc.dart';
import '../bloc/admin_dashboard_state.dart';
import '../bloc/admin_dashboard_event.dart';

import '../sidebar/sidebar_drawer.dart';
import '../widget/welcome_header.dart';
import '../widget/employee_section.dart';
import '../widget/task_section.dart';
import 'package:my_app/event_management/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:my_app/event_management/features/dashboard/presentation/widgets/main_dashboard_events_panel.dart';

import 'package:my_app/admin_dashboard/repository/admin_repository.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/mainscreen/mobile_employee_section.dart';

// ─────────────────────────────────────────────
//  Entry point — provides the BLoC
// ─────────────────────────────────────────────
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminDashboardBloc(
        repository: AdminRepository(),
      )
        ..add(const AdminDashboardStarted())
        ..add(const RegisterAdminNotificationDevice()),
      child: const _AdminDashboardView(),
    );
  }
}

// ─────────────────────────────────────────────
//  Main view
// ─────────────────────────────────────────────
class _AdminDashboardView extends StatefulWidget {
  const _AdminDashboardView({super.key});

  @override
  State<_AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<_AdminDashboardView> {
  int _selectedIndex = 0;
  Timer? _liveStatusTimer;

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_rounded, label: 'HOME'),
    _NavItem(icon: Icons.person_rounded, label: 'PROFILE'),
    _NavItem(icon: Icons.chat_bubble_rounded, label: 'CHAT'),
    _NavItem(icon: Icons.share_rounded, label: 'SHARE'),
  ];

  // Dashboard feature grid items
  final List<_DashboardItem> _dashboardItems = const [
    _DashboardItem(
      icon: Icons.dashboard_rounded,
      label: 'Dashboard',
      bgColor: Color(0xFFEFF3FF),
      iconColor: Color(0xFF3B82F6),
    ),
    _DashboardItem(
      icon: Icons.badge_rounded,
      label: 'Employees',
      bgColor: Color(0xFFECFDF5),
      iconColor: Color(0xFF10B981),
    ),
    _DashboardItem(
      icon: Icons.assignment_rounded,
      label: 'Projects & Tasks',
      bgColor: Color(0xFFEEF2FF),
      iconColor: Color(0xFF6366F1),
    ),
    _DashboardItem(
      icon: Icons.share_rounded,
      label: 'Share',
      bgColor: Color(0xFFFFF1F2),
      iconColor: Color(0xFFF43F5E),
    ),
    _DashboardItem(
      icon: Icons.handshake_rounded,
      label: 'Clients',
      bgColor: Color(0xFFFFFBEB),
      iconColor: Color(0xFFF59E0B),
    ),
    _DashboardItem(
      icon: Icons.inventory_2_rounded,
      label: 'Assets & Resources',
      bgColor: Color(0xFFF0FDFA),
      iconColor: Color(0xFF14B8A6),
    ),
    _DashboardItem(
      icon: Icons.event_busy_rounded,
      label: 'Leave Management',
      bgColor: Color(0xFFFFF7ED),
      iconColor: Color(0xFFF97316),
    ),
    _DashboardItem(
      icon: Icons.receipt_long_rounded,
      label: 'Billing & Invoices',
      bgColor: Color(0xFFF5F3FF),
      iconColor: Color(0xFF8B5CF6),
    ),
    _DashboardItem(
      icon: Icons.payments_rounded,
      label: 'Payroll',
      bgColor: Color(0xFFECFEFF),
      iconColor: Color(0xFF06B6D4),
    ),
    _DashboardItem(
      icon: Icons.groups_3_rounded,
      label: 'Leads',
      bgColor: Color(0xFFF7FEE7),
      iconColor: Color(0xFF84CC16),
    ),
    _DashboardItem(
      icon: Icons.event_available_rounded,
      label: 'Events',
      bgColor: Color(0xFFFDF4FF),
      iconColor: Color(0xFFD946EF),
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Keep "Live Attendance" fresh without user pull-to-refresh.
    _liveStatusTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!mounted) return;
      context.read<AdminDashboardBloc>().add(const AdminDashboardRefreshed());
    });
  }

  @override
  void dispose() {
    _liveStatusTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blocContext = context;

    return BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),

          // ── Sidebar Drawer (unchanged logic) ──
          drawer: (state.username == null || state.role == null)
              ? null
              : SidebarDrawer(
            parentContext: blocContext,
            userId: state.username!,
            userName: state.role!.toUpperCase(),
            userEmail: state.username!,
            userAvatar: null,
          ),

          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ── Top Header ──
                _buildHeader(context, state),

                // ── Body ──
                Expanded(
                  child: _buildBody(context, state),
                ),
              ],
            ),
          ),

          // ── Bottom Nav ──
          bottomNavigationBar: _buildBottomNav(),
        );
      },
    );
  }

  // ─── Header ──────────────────────────────────
  Widget _buildHeader(BuildContext context, AdminDashboardState state) {
    return Container(
      color: const Color(0xFFF8F9FA),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Menu button (opens sidebar drawer)
          Builder(
            builder: (ctx) => GestureDetector(
              onTap: () => Scaffold.of(ctx).openDrawer(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE5E9EB), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.menu_rounded,
                  size: 18,
                  color: Color(0xFF4456BA),
                ),
              ),
            ),
          ),

          // App name / logo
          const Text(
            'Admin Panel',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: Color(0xFF4456BA),
              letterSpacing: -0.5,
            ),
          ),

          // Notification + Avatar
          Row(
            children: [
              // Notification bell
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border:
                    Border.all(color: const Color(0xFFE5E9EB), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.notifications_rounded,
                    size: 18,
                    color: Color(0xFF4456BA),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Avatar
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                  Border.all(color: const Color(0xFFE5E9EB), width: 2),
                  image: const DecorationImage(
                    image: NetworkImage('https://i.pravatar.cc/150?img=12'),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Body ────────────────────────────────────
  Widget _buildBody(BuildContext context, AdminDashboardState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(child: Text(state.error!));
    }

    return RefreshIndicator(
      onRefresh: () async {
        context
            .read<AdminDashboardBloc>()
            .add(const AdminDashboardRefreshed());
        context.read<DashboardBloc>().add(DashboardRefreshRequested());
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            _buildWelcomeSection(state),
            const SizedBox(height: 24),

            // Feature grid
            _buildGrid(),
            const SizedBox(height: 28),

            // ── Existing data sections ──
            // Employees live status
            _AnimatedCard(child: EmployeeSection(employees: state.liveEmployees)),
            const SizedBox(height: 20),

            // Tasks
            _AnimatedCard(child: TaskSection(tasks: state.tasks)),
            const SizedBox(height: 20),

            // Events (Event Management API — today + upcoming)
            _AnimatedCard(child: const MainDashboardEventsPanel()),
          ],
        ),
      ),
    );
  }

  // ─── Welcome section ─────────────────────────
  Widget _buildWelcomeSection(AdminDashboardState state) {
    final name = state.username ?? 'Admin';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'WELCOME BACK',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 11,
            color: Color(0xFF4456BA),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w800,
            fontSize: 28,
            color: Color(0xFF2D3335),
            letterSpacing: -0.8,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Manage your workspace efficiently.',
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 13,
            color: Color(0xFF5A6062),
          ),
        ),
      ],
    );
  }

  // ─── Feature grid ────────────────────────────
  Widget _buildGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.0,
      ),
      itemCount: _dashboardItems.length,
      itemBuilder: (context, index) {
        return _DashboardCard(item: _dashboardItems[index]);
      },
    );
  }

  // ─── Bottom Nav ──────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0C0F10).withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, -12),
            spreadRadius: -6,
          ),
        ],
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_navItems.length, (index) {
                  final item = _navItems[index];
                  final isSelected = _selectedIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIndex = index),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedScale(
                      scale: isSelected ? 1.0 : 0.95,
                      duration: const Duration(milliseconds: 200),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            size: 24,
                            color: isSelected
                                ? const Color(0xFF4456BA)
                                : const Color(0xFF94A3B8),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                              letterSpacing: 0.8,
                              color: isSelected
                                  ? const Color(0xFF4456BA)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Animated card wrapper (kept from original)
// ─────────────────────────────────────────────
class _AnimatedCard extends StatelessWidget {
  final Widget child;
  const _AnimatedCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEBEEF0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Feature grid card (press-to-scale)
// ─────────────────────────────────────────────
class _DashboardCard extends StatefulWidget {
  final _DashboardItem item;
  const _DashboardCard({required this.item});

  @override
  State<_DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<_DashboardCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFEBEEF0), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: widget.item.bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.item.icon,
                    color: widget.item.iconColor, size: 28),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  widget.item.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Color(0xFF2D3335),
                    letterSpacing: -0.2,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Data models
// ─────────────────────────────────────────────
class _DashboardItem {
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color iconColor;

  const _DashboardItem({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.iconColor,
  });
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}