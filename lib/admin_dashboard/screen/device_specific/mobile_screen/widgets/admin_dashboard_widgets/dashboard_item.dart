import 'package:flutter/material.dart';

class DashboardItem {
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback? onTap;

  const DashboardItem({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.iconColor,
    this.onTap,
  });
}