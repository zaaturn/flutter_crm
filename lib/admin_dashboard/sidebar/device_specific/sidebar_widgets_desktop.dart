import 'package:flutter/material.dart';

import 'package:my_app/admin_dashboard/sidebar/device_specific/sidebar_menu_config_desktop.dart';
import 'package:my_app/admin_dashboard/sidebar/device_specific/sidebar_handler_desktop.dart';

class DesktopSidebar extends StatefulWidget {
  final BuildContext parentContext;
  final String userName;
  final String userRole;
  final String? userAvatar;

  const DesktopSidebar({
    super.key,
    required this.parentContext,
    required this.userName,
    required this.userRole,
    this.userAvatar,
  });

  @override
  State<DesktopSidebar> createState() => _DesktopSidebarState();
}

class _DesktopSidebarState extends State<DesktopSidebar> {
  SidebarAction? _selectedAction = SidebarAction.dashboard;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 256,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(isDark),
          _buildMenu(isDark),
          _buildFooter(isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage:
            widget.userAvatar != null ? NetworkImage(widget.userAvatar!) : null,
            child: widget.userAvatar == null
                ? Text(widget.userName[0].toUpperCase())
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.userRole,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenu(bool isDark) {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: sidebarMenuConfig.map((item) {
          if (item.children != null && item.children!.isNotEmpty) {
            return _ExpandableMenuTile(
              item: item,
              isDark: isDark,
              selectedAction: _selectedAction,
              onActionSelected: _onAction,
            );
          }
          return _buildMenuItem(item, isDark);
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem(SidebarMenuItem item, bool isDark) {
    final isSelected = _selectedAction == item.action;

    return InkWell(
      onTap: () => _onAction(item.action),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0D3199).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              item.icon,
              size: 20,
              color: isSelected
                  ? const Color(0xFF0D3199)
                  : (isDark
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF64748B)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF0D3199)
                      : (isDark
                      ? Colors.white70
                      : const Color(0xFF475569)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onAction(SidebarAction? action) {
    if (action == null) return;
    setState(() => _selectedAction = action);
    SidebarHandler.handle(context, widget.parentContext, action);
  }

  Widget _buildFooter(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        '© ${DateTime.now().year}',
        style: TextStyle(
          fontSize: 11,
          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
        ),
      ),
    );
  }
}

class _ExpandableMenuTile extends StatefulWidget {
  final SidebarMenuItem item;
  final bool isDark;
  final SidebarAction? selectedAction;
  final Function(SidebarAction) onActionSelected;

  const _ExpandableMenuTile({
    required this.item,
    required this.isDark,
    required this.selectedAction,
    required this.onActionSelected,
  });

  @override
  State<_ExpandableMenuTile> createState() => _ExpandableMenuTileState();
}

class _ExpandableMenuTileState extends State<_ExpandableMenuTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final hasSelectedChild = widget.item.children
        ?.any((c) => c.action == widget.selectedAction) ??
        false;

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  widget.item.icon,
                  size: 20,
                  color: hasSelectedChild
                      ? const Color(0xFF0D3199)
                      : (widget.isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.item.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: hasSelectedChild
                          ? const Color(0xFF0D3199)
                          : (widget.isDark
                          ? Colors.white70
                          : const Color(0xFF475569)),
                    ),
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
        if (_expanded && widget.item.children != null)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              children: widget.item.children!.map((child) {
                final isSelected =
                    widget.selectedAction == child.action;

                return InkWell(
                  onTap: () {
                    if (child.action != null) {
                      widget.onActionSelected(child.action!);
                    }
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF0D3199).withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          child.icon,
                          size: 18,
                          color: isSelected
                              ? const Color(0xFF0D3199)
                              : (widget.isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            child.title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFF0D3199)
                                  : (widget.isDark
                                  ? Colors.white70
                                  : const Color(0xFF475569)),
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
