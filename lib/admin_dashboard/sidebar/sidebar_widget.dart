import 'package:flutter/material.dart';

import 'sidebar_menu_config.dart';
import 'sidebar_handler.dart';

/* ============================================================
 * SIDEBAR DRAWER
 * ============================================================ */
class AdminSidebar extends StatelessWidget {
  final BuildContext parentContext;

  const AdminSidebar({
    super.key,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0F172A), // dark admin blue
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: sidebarMenuConfig.map((item) {
            // ================= EXPANDABLE ITEMS =================
            if (item.children != null && item.children!.isNotEmpty) {
              return SidebarExpansion(
                item: item,
                onAction: (action) {
                  SidebarHandler.handle(
                    context,
                    parentContext,
                    action,
                  );
                },
              );
            }

            // ================= SINGLE ACTION ITEMS =================
            return SidebarTile(
              item: item,
              onTap: () {
                if (item.action != null) {
                  SidebarHandler.handle(
                    context,
                    parentContext,
                    item.action!,
                  );
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

/* ============================================================
 * MAIN SIDEBAR TILE
 * ============================================================ */
class SidebarTile extends StatelessWidget {
  final SidebarMenuItem item;
  final VoidCallback onTap;

  const SidebarTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(
        item.icon,
        color: Colors.white70,
        size: 22,
      ),
      title: Text(
        item.title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      horizontalTitleGap: 12,
      onTap: onTap,
    );
  }
}

/* ============================================================
 * EXPANDABLE SIDEBAR SECTION
 * ============================================================ */
class SidebarExpansion extends StatelessWidget {
  final SidebarMenuItem item;
  final Function(SidebarAction) onAction;

  const SidebarExpansion({
    super.key,
    required this.item,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: Icon(
          item.icon,
          color: Colors.white70,
          size: 22,
        ),
        title: Text(
          item.title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        childrenPadding: const EdgeInsets.only(left: 28),
        children: item.children!
            .map(
              (child) => ListTile(
            dense: true,
            leading: Icon(
              child.icon,
              color: Colors.white54,
              size: 20,
            ),
            title: Text(
              child.title,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
            ),
            horizontalTitleGap: 10,
            onTap: () => onAction(child.action!),
          ),
        )
            .toList(),
      ),
    );
  }
}
