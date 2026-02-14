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
  reports,
  logout,
}

class SidebarMenuItem {
  final String title;
  final IconData icon;
  final SidebarAction? action;
  final List<SidebarMenuItem>? children;

  const SidebarMenuItem({
    required this.title,
    required this.icon,
    this.action,
    this.children,
  });
}

const sidebarMenuConfig = [
  SidebarMenuItem(
    title: "Dashboard",
    icon: Icons.dashboard_outlined,
    action: SidebarAction.dashboard,
  ),

  SidebarMenuItem(
    title: "Employees",
    icon: Icons.people_outline,
    action: SidebarAction.employees,
  ),

  // ================= PROJECTS & TASKS =================
  SidebarMenuItem(
    title: "Projects & Tasks",
    icon: Icons.work_outline,
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
      icon:Icons.time_to_leave ,
      action:SidebarAction.leaveManagement
  ),

  // ================= FINANCE =================
  SidebarMenuItem(
    title: "Billing & Invoices",
    icon: Icons.receipt_long_outlined,
    children: [
      SidebarMenuItem(
        title: "Generate Invoice",
        icon: Icons.add_circle_outline,
        action: SidebarAction.billingGenerate,
      ),
    ],
  ),

  SidebarMenuItem(
    title: "Payroll",
    icon: Icons.account_balance_outlined,
    action: SidebarAction.payroll,
  ),

  // ================= OTHERS =================
  SidebarMenuItem(
    title: "Leads",
    icon: Icons.cases_outlined,
    action: SidebarAction.leads,
  ),

  SidebarMenuItem(
    title: "Reports",
    icon: Icons.insights_outlined,
    action: SidebarAction.reports,
  ),
];
