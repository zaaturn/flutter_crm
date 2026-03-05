import 'package:flutter/material.dart';

enum AudienceTab { byDepartment, byDesignation, specificUsers }

extension AudienceTabX on AudienceTab {
  String get label {
    switch (this) {
      case AudienceTab.byDepartment:
        return 'By Department';
      case AudienceTab.byDesignation:
        return 'By Designation';
      case AudienceTab.specificUsers:
        return 'Specific Users';
    }
  }

  IconData get icon {
    switch (this) {
      case AudienceTab.byDepartment:
        return Icons.corporate_fare_outlined;
      case AudienceTab.byDesignation:
        return Icons.work_outline;
      case AudienceTab.specificUsers:
        return Icons.people_outline;
    }
  }

  String get selectionLabel {
    switch (this) {
      case AudienceTab.byDepartment:
        return 'Department';
      case AudienceTab.byDesignation:
        return 'Designation';
      case AudienceTab.specificUsers:
        return 'User';
    }
  }
}