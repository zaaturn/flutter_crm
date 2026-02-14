import 'package:flutter/material.dart';

enum SidebarAction {
  dashboard,
  employees,

  // Projects & Tasks
  trackTasks,
  assignTasks,

  // Management
  meetings,
  credentials,
  assets,
  leaveManagement,

  // Finance
  billingGenerate,
  payroll,

  leads,

  events,

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

  const SidebarMenuItem({
    required this.title,
    required this.icon,
    this.action,
    this.children,
    this.isGroup = false,
    this.showDividerAfter = false,
    this.tooltip,
  });
}

const sidebarMenuConfig = [
  SidebarMenuItem(
    title: "Dashboard",
    icon: Icons.dashboard_outlined,
    action: SidebarAction.dashboard,
    tooltip: "Admin overview",
  ),

  SidebarMenuItem(
    title: "Employees",
    icon: Icons.people_outline,
    action: SidebarAction.employees,
    showDividerAfter: true,
  ),

  // ================= PROJECTS & TASKS =================
  SidebarMenuItem(
    title: "Projects & Tasks",
    icon: Icons.work_outline,
    isGroup: true,
    children: [
      SidebarMenuItem(
        title: "Track Tasks",
        icon: Icons.track_changes_outlined,
        action: SidebarAction.trackTasks,
      ),
      SidebarMenuItem(
        title: "Assign Tasks",
        icon: Icons.add_task_outlined,
        action: SidebarAction.assignTasks,
      ),
    ],
    showDividerAfter: true,
  ),

  // ================= MANAGEMENT =================
  SidebarMenuItem(
    title: "Meetings",
    icon: Icons.video_camera_front_outlined,
    action: SidebarAction.meetings,
  ),

  SidebarMenuItem(
    title: "Credentials",
    icon: Icons.vpn_key_outlined,
    action: SidebarAction.credentials,
  ),

  SidebarMenuItem(
    title: "Assets & Resources",
    icon: Icons.inventory_2_outlined,
    action: SidebarAction.assets,
  ),

  SidebarMenuItem(
    title: 'Leave Management',
    icon: Icons.time_to_leave,
    action: SidebarAction.leaveManagement,
    showDividerAfter: true,
  ),

  // ================= FINANCE =================
  SidebarMenuItem(
    title: "Billing & Invoices",
    icon: Icons.receipt_long_outlined,
    isGroup: true,
    children: [
      SidebarMenuItem(
        title: "Generate Invoice",
        icon: Icons.add_circle_outline,
        action: SidebarAction.billingGenerate,
      ),
    ],
    showDividerAfter: true,
  ),

  SidebarMenuItem(
    title: "Payroll",
    icon: Icons.account_balance_outlined,
    action: SidebarAction.payroll,
    showDividerAfter: true,
  ),

  // ================= OTHERS =================
  SidebarMenuItem(
    title: "Leads",
    icon: Icons.cases_outlined,
    action: SidebarAction.leads,
  ),


  SidebarMenuItem(
    title: "Events",
    icon: Icons.calendar_month_outlined,
    action: SidebarAction.events,
    showDividerAfter: true,
  ),

  SidebarMenuItem(
    title: "Logout",
    icon: Icons.logout_rounded,
    action: SidebarAction.logout,
    tooltip: "Sign out of session",
  ),
];
