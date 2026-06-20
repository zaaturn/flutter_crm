import 'package:flutter/material.dart';

enum SidebarAction {
  analytics,
  employees,

  // Projects & Tasks
  trackTasks,
  assignTasks,

  // Management
  share,
  client,
  assets,
  leaveManagement,

  // Finance
  billingGenerate,
  payroll,

  leads,

  events,

  /// Superadmin only — opens user access management.
  superadminUsers,

  logout,
}

class SidebarMenuItem {
  final String title;
  final IconData icon;
  final SidebarAction? action;
  final List<SidebarMenuItem>? children;

  final bool isGroup;
  final bool showDividerAfter;
  final String? tooltip;

  /// Key matching backend `admin_modules` (null = always visible, e.g. Dashboard).
  final String? moduleKey;

  const SidebarMenuItem({
    required this.title,
    required this.icon,
    this.action,
    this.children,
    this.isGroup = false,
    this.showDividerAfter = false,
    this.tooltip,
    this.moduleKey,
  });
}

const sidebarMenuConfig = [
  SidebarMenuItem(
    title: "Analytics",
    icon: Icons.insert_chart,
    action: SidebarAction.analytics,
    moduleKey: 'analytics',
    tooltip: "Analytics overview",
  ),

  SidebarMenuItem(
    title: "Employees",
    icon: Icons.people_outline,
    action: SidebarAction.employees,
    moduleKey: 'employees',
    showDividerAfter: true,
  ),

  // ================= PROJECTS & TASKS =================
  SidebarMenuItem(
    title: "Projects & Tasks",
    icon: Icons.work_outline,
    isGroup: true,
    moduleKey: 'tasks',
    children: [
      SidebarMenuItem(
        title: "Track Tasks",
        icon: Icons.track_changes_outlined,
        action: SidebarAction.trackTasks,
        moduleKey: 'tasks',
      ),
      SidebarMenuItem(
        title: "Assign Tasks",
        icon: Icons.add_task_outlined,
        action: SidebarAction.assignTasks,
        moduleKey: 'tasks',
      ),
    ],
    showDividerAfter: true,
  ),

  // ================= MANAGEMENT =================
  SidebarMenuItem(
    title: "Share",
    icon: Icons.share_outlined,
    action: SidebarAction.share,
    moduleKey: 'share',
  ),

  SidebarMenuItem(
    title: "Clients",
    icon: Icons.vpn_key_outlined,
    action: SidebarAction.client,
    moduleKey: 'clients',
  ),

  SidebarMenuItem(
    title: "Assets & Resources",
    icon: Icons.inventory_2_outlined,
    action: SidebarAction.assets,
    moduleKey: 'assets',
  ),

  SidebarMenuItem(
    title: 'Leave Management',
    icon: Icons.time_to_leave,
    action: SidebarAction.leaveManagement,
    moduleKey: 'leave',
    showDividerAfter: true,
  ),

  // ================= FINANCE =================
  SidebarMenuItem(
    title: "Billing & Invoices",
    icon: Icons.receipt_long_outlined,
    action: SidebarAction.billingGenerate,
    moduleKey: 'billing',
    showDividerAfter: true,
  ),

  SidebarMenuItem(
    title: "Payroll",
    icon: Icons.account_balance_outlined,
    action: SidebarAction.payroll,
    moduleKey: 'payroll',
    showDividerAfter: true,
  ),

  // ================= OTHERS =================
  SidebarMenuItem(
    title: "Leads",
    icon: Icons.cases_outlined,
    action: SidebarAction.leads,
    moduleKey: 'leads',
  ),


  SidebarMenuItem(
    title: "Events",
    icon: Icons.calendar_month_outlined,
    action: SidebarAction.events,
    moduleKey: 'events',
    showDividerAfter: true,
  ),

];

/// Backend `admin_modules` key for this action, or `null` if not gated.
String? moduleKeyForSidebarAction(SidebarAction action) {
  switch (action) {
    case SidebarAction.logout:
    case SidebarAction.superadminUsers:
      return null;
    case SidebarAction.employees:
      return 'employees';
    case SidebarAction.trackTasks:
    case SidebarAction.assignTasks:
      return 'tasks';
    case SidebarAction.share:
      return 'share';
    case SidebarAction.client:
      return 'clients';
    case SidebarAction.assets:
      return 'assets';
    case SidebarAction.leaveManagement:
      return 'leave';
    case SidebarAction.billingGenerate:
      return 'billing';
    case SidebarAction.payroll:
      return 'payroll';
    case SidebarAction.leads:
      return 'leads';
    case SidebarAction.events:
      return 'events';
    case SidebarAction.analytics:
      return 'analytics';
  }
}
