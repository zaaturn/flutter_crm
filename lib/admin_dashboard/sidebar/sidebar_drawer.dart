import 'package:flutter/material.dart';
import 'sidebar_menu_config.dart';
import 'sidebar_widget.dart';
import 'sidebar_handler.dart';

class SidebarDrawer extends StatefulWidget {
  final BuildContext parentContext;
  final String userId;
  final String userName;
  final String userEmail;
  final String? userAvatar;

  const SidebarDrawer({
    super.key,
    required this.parentContext,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userAvatar,
  });

  // BACKWARD-COMPATIBLE GETTERS
  String get adminName => userName;
  String get adminEmail => userEmail;
  String? get adminAvatar => userAvatar;

  @override
  State<SidebarDrawer> createState() => _SidebarDrawerState();
}

class _SidebarDrawerState extends State<SidebarDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF9FAFB),
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _sectionLabel("NAVIGATION"),
                      const SizedBox(height: 8),
                      ...sidebarMenuConfig.map((item) {
                        if (item.children != null) {
                          return _ModernSidebarExpansion(
                            item: item,
                            onAction: (action) => SidebarHandler.handle(
                              context,
                              widget.parentContext,
                              action,
                            ),
                          );
                        }
                        return _ModernSidebarTile(
                          item: item,
                          onTap: () => SidebarHandler.handle(
                            context,
                            widget.parentContext,
                            item.action!,
                          ),
                        );
                      }),
                      const SizedBox(height: 24),
                      _divider(),
                      const SizedBox(height: 16),
                      _sectionLabel("ACCOUNT"),
                      const SizedBox(height: 8),
                      _ModernSidebarTile(
                        item: const SidebarMenuItem(
                          title: "Logout",
                          icon: Icons.logout_rounded,
                          action: SidebarAction.logout,
                        ),
                        isDestructive: true,
                        onTap: () => SidebarHandler.handle(
                          context,
                          widget.parentContext,
                          SidebarAction.logout,
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
                _footer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            backgroundImage:
            widget.adminAvatar != null ? NetworkImage(widget.adminAvatar!) : null,
            child: widget.adminAvatar == null
                ? Text(
              widget.adminName[0].toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 24),
            )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.adminName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.adminEmail,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(left: 4),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        color: Color(0xFF9CA3AF),
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    ),
  );

  Widget _divider() => Container(height: 1, color: const Color(0xFFE5E7EB));

  Widget _footer() => const SizedBox(height: 16);
}

/* ================================
   MODERN SIDEBAR TILE
================================ */

class _ModernSidebarTile extends StatelessWidget {
  final SidebarMenuItem item;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isChild;

  const _ModernSidebarTile({
    required this.item,
    required this.onTap,
    this.isDestructive = false,
    this.isChild = false,
  });

  @override
  Widget build(BuildContext context) {
    final color =
    isDestructive ? const Color(0xFFEF4444) : const Color(0xFF6366F1);

    return Padding(
      padding: EdgeInsets.only(left: isChild ? 16 : 0, bottom: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(item.icon, size: 18, color: color),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    fontSize: isChild ? 13 : 14,
                    fontWeight: FontWeight.w600,
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

/* ================================
   MODERN SIDEBAR EXPANSION
================================ */

class _ModernSidebarExpansion extends StatefulWidget {
  final SidebarMenuItem item;
  final Function(SidebarAction) onAction;

  const _ModernSidebarExpansion({
    required this.item,
    required this.onAction,
  });

  @override
  State<_ModernSidebarExpansion> createState() =>
      _ModernSidebarExpansionState();
}

class _ModernSidebarExpansionState extends State<_ModernSidebarExpansion> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(widget.item.icon, size: 18),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    widget.item.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          Column(
            children: widget.item.children!.map((child) {
              return _ModernSidebarTile(
                item: child,
                isChild: true,
                onTap: () => widget.onAction(child.action!),
              );
            }).toList(),
          ),
      ],
    );
  }
}
