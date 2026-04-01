import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/admin_dashboard/sidebar/device_specific/sidebar_menu_config_desktop.dart';
import 'package:my_app/admin_dashboard/sidebar/device_specific/sidebar_handler_desktop.dart';

class DesktopSidebar extends StatefulWidget {
  final BuildContext parentContext;
  final String userName;
  final String userRole;
  final String? userAvatar;
  final VoidCallback? onLogout;

  const DesktopSidebar({
    super.key,
    required this.parentContext,
    required this.userName,
    required this.userRole,
    this.userAvatar,
    this.onLogout,
  });

  @override
  State<DesktopSidebar> createState() => _DesktopSidebarState();
}

class _DesktopSidebarState extends State<DesktopSidebar> {
  SidebarAction? _selectedAction = SidebarAction.dashboard;

  // --- DAXARROW Premium Palette ---
  static const _purple      = Color(0xFF7C3AED);
  static const _purpleLight = Color(0xFFF5F3FF);
  static const _purpleDark  = Color(0xFF4C1D95);
  static const _textPrimary = Color(0xFF0F172A);
  static const _textMuted   = Color(0xFF334155);
  static const _border      = Color(0xFFEDE9FE);
  static const _red         = Color(0xFFEF4444);
  static const _green       = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: _border, width: 1.5)),
      ),
      child: Column(
        children: [
          _buildBrandHeader(),
          _buildMenu(),
          _buildCompactUserFooter(),
        ],
      ),
    );
  }

  // 1. BRAND HEADER
  Widget _buildBrandHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
      child: Row(
        children: [
          Image.asset(
            'assets/images/logo.png',
            width: 38,
            height: 38,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: _purple, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            'DAXARROW',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: _textPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // 2. MAIN MENU
  Widget _buildMenu() {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        physics: const BouncingScrollPhysics(),
        children: [
          _sectionLabel('Workspace'),
          ...sidebarMenuConfig.map((item) {
            if (item.children != null && item.children!.isNotEmpty) {
              return _ExpandableMenuTile(
                item: item,
                selectedAction: _selectedAction,
                onActionSelected: _onAction,
              );
            }
            return _buildMenuItem(item);
          }),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
    child: Text(
      label.toUpperCase(),
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: _textMuted.withOpacity(0.7),
        letterSpacing: 1.5,
      ),
    ),
  );

  Widget _buildMenuItem(SidebarMenuItem item) {
    final isSelected = _selectedAction == item.action;

    return InkWell(
      onTap: () => _onAction(item.action),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? _purpleLight : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              item.icon,
              size: 20,
              color: isSelected ? _purple : _textMuted,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.title,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w800,
                  fontSize: 14,
                  color: isSelected ? _purpleDark : _textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Centralized Action Handler
  void _onAction(SidebarAction? action) {
    if (action == null) return;

    // Only update visual selection if it's not a logout action
    if (action != SidebarAction.logout) {
      setState(() => _selectedAction = action);
    }

    // Delegate ALL logic (including logout) to the Handler
    SidebarHandler.handle(context, widget.parentContext, action);
  }

  // 3. COMPACT USER FOOTER
  Widget _buildCompactUserFooter() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 24),
      decoration: BoxDecoration(
        color: _purpleLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border, width: 1.5),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: _purple,
            child: Text(
              widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'U',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w900,
                      color: _textPrimary,
                      fontSize: 13
                  ),
                ),
                Text(
                  'Active Now',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: _green
                  ),
                ),
              ],
            ),
          ),
          // RED SWITCH ICON TRIGGERING THE HANDLER
          IconButton(
            onPressed: () => _onAction(SidebarAction.logout),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: _red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10)
              ),
              child: const Icon(Icons.power_settings_new_rounded, size: 18, color: _red),
            ),
          ),
        ],
      ),
    );
  }
}

// ... _ExpandableMenuTile remains the same as it correctly calls widget.onActionSelected ...
class _ExpandableMenuTile extends StatefulWidget {
  final SidebarMenuItem item;
  final SidebarAction? selectedAction;
  final Function(SidebarAction) onActionSelected;

  const _ExpandableMenuTile({
    required this.item,
    required this.selectedAction,
    required this.onActionSelected
  });

  @override
  State<_ExpandableMenuTile> createState() => _ExpandableMenuTileState();
}

class _ExpandableMenuTileState extends State<_ExpandableMenuTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final hasSelectedChild = widget.item.children?.any((c) => c.action == widget.selectedAction) ?? false;
    const purple = Color(0xFF7C3AED);
    const textPrimary = Color(0xFF0F172A);
    const textMuted = Color(0xFF334155);

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                    widget.item.icon,
                    size: 20,
                    color: hasSelectedChild ? purple : textMuted
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    widget.item.title,
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: hasSelectedChild ? FontWeight.w900 : FontWeight.w800,
                        fontSize: 14,
                        color: hasSelectedChild ? purple : textPrimary
                    ),
                  ),
                ),
                Icon(
                    _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    size: 22,
                    color: textMuted
                ),
              ],
            ),
          ),
        ),
        if (_expanded && widget.item.children != null)
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Column(
              children: widget.item.children!.map((child) {
                final isSelected = widget.selectedAction == child.action;
                return InkWell(
                  onTap: () { if (child.action != null) widget.onActionSelected(child.action!); },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFF5F3FF) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Row(
                      children: [
                        Icon(
                            child.icon,
                            size: 18,
                            color: isSelected ? purple : textMuted
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            child.title,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                                color: isSelected ? const Color(0xFF4C1D95) : textPrimary
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}