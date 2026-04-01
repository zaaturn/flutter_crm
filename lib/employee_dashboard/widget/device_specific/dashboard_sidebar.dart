import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_bloc.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_state.dart';
import 'package:my_app/employee_dashboard/navigation/employee_dashboard_navigation.dart';
import 'dart:ui';

class DashboardSidebar extends StatefulWidget {
  final VoidCallback? onNavigateLeave;
  final VoidCallback? onNavigateTask;
  final VoidCallback? onLogout;

  const DashboardSidebar({super.key, this.onNavigateLeave, this.onNavigateTask, this.onLogout});

  @override
  State<DashboardSidebar> createState() => _DashboardSidebarState();
}

class _DashboardSidebarState extends State<DashboardSidebar> {
  int _selected = 0;

  // --- DAXARROW Palette ---
  static const _purple      = Color(0xFF7C3AED);
  static const _purpleLight = Color(0xFFF5F3FF);
  static const _purpleDark  = Color(0xFF4C1D95);
  static const _bg          = Color(0xFFFFFFFF);
  static const _surface     = Color(0xFFF8FAFC);
  static const _border      = Color(0xFFEDE9FE);
  static const _textPrimary = Color(0xFF0F172A);
  static const _textMuted   = Color(0xFF334155);
  static const _red         = Color(0xFFEF4444);

  final _navItems = const [
    (label: 'Dashboard',      icon: Icons.grid_view_rounded),
    (label: 'My Tasks',       icon: Icons.layers_outlined),
    (label: 'Activity Feed',  icon: Icons.bolt_outlined),
    (label: 'Leave Request',  icon: Icons.calendar_today_outlined),
    (label: 'Events',         icon: Icons.auto_awesome_mosaic_rounded),
  ];

  void _onTap(int index) {
    setState(() => _selected = index);
    switch (index) {
    // FIXED: Added navigation to the main Employee Dashboard
      case 0:
        EmployeeDashboardNavigator.dashboard(context);
        break;
      case 1:
        widget.onNavigateTask?.call();
        EmployeeDashboardNavigator.tasks(context);
        break;
      case 2:
        EmployeeDashboardNavigator.feed(context);
        break;
      case 3:
        widget.onNavigateLeave?.call();
        EmployeeDashboardNavigator.leaveDashboard(context);
        break;
      case 4:
        EmployeeDashboardNavigator.events(context);
        break;
    }
  }

  void _showLogoutDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) => const SizedBox(),
      transitionBuilder: (ctx, anim, _, __) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: anim.drive(CurveTween(curve: Curves.easeOutBack)),
            child: AlertDialog(
              backgroundColor: _bg,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: _red.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.logout_rounded, color: _red, size: 32),
                  ),
                  const SizedBox(height: 24),
                  Text('Sign Out?', style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w900, color: _textPrimary)),
                  const SizedBox(height: 12),
                  Text('Are you sure you want to end your session?', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 14, color: _textMuted, height: 1.5)),
                  const SizedBox(height: 32),
                  Row(children: [
                    Expanded(child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Cancel', style: GoogleFonts.inter(color: _textMuted, fontWeight: FontWeight.w800)),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: ElevatedButton(
                      onPressed: () { Navigator.pop(ctx); widget.onLogout?.call(); },
                      style: ElevatedButton.styleFrom(backgroundColor: _red, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: Text('Logout', style: GoogleFonts.inter(fontWeight: FontWeight.w900)),
                    )),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
          color: _bg,
          border: Border(right: BorderSide(color: _border, width: 1.5))
      ),
      child: Column(children: [
        _buildHeader(),
        Expanded(child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          physics: const BouncingScrollPhysics(),
          children: [
            _sectionLabel('Workspace'),
            for (var i = 0; i < 3; i++) _navTile(i),
            const SizedBox(height: 12),
            _sectionLabel('Management'),
            for (var i = 3; i < _navItems.length; i++) _navTile(i),
          ],
        )),
        _buildUserCard(),
      ]),
    );
  }

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(24, 64, 24, 32),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Image.asset(
          'assets/images/logo.png',
          width: 36,
          height: 36,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: _purple, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.business_rounded, color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(width: 12),
        Text(
            'DAXARROW',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: _textPrimary,
                letterSpacing: 0.5
            )
        ),
      ],
    ),
  );

  Widget _sectionLabel(String label) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
    child: Text(label.toUpperCase(), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: _textMuted.withOpacity(0.8), letterSpacing: 1.5)),
  );

  Widget _navTile(int index) {
    final item = _navItems[index];
    final active = _selected == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
          color: active ? _purpleLight : Colors.transparent,
          borderRadius: BorderRadius.circular(12)
      ),
      child: ListTile(
        onTap: () => _onTap(index),
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(
            item.icon,
            size: 20,
            color: active ? _purple : _textMuted
        ),
        title: Text(
            item.label,
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: active ? FontWeight.w900 : FontWeight.w700,
                color: active ? _purpleDark : _textPrimary
            )
        ),
      ),
    );
  }

  Widget _buildUserCard() {
    return BlocBuilder<EmployeeBloc, EmployeeState>(
      builder: (ctx, state) {
        final name = state.employee?.username ?? 'User';
        final initials = name.isNotEmpty ? name.substring(0,1).toUpperCase() : 'U';

        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
          ),
          child: Row(children: [
            CircleAvatar(
                radius: 18,
                backgroundColor: _purple,
                child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12))
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w900, color: _textPrimary), overflow: TextOverflow.ellipsis),
              Row(children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text('Active Now', style: GoogleFonts.inter(fontSize: 11, color: _textMuted, fontWeight: FontWeight.w700)),
              ]),
            ])),
            InkWell(
              onTap: _showLogoutDialog,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: _red.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.power_settings_new_rounded, size: 18, color: _red),
              ),
            ),
          ]),
        );
      },
    );
  }
}