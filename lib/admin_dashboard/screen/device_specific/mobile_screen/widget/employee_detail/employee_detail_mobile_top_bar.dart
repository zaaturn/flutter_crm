import 'package:flutter/material.dart';

import 'employee_detail_mobile_theme.dart';

class EmployeeDetailMobileTopBar extends StatelessWidget {
  const EmployeeDetailMobileTopBar({
    super.key,
    required this.title,
    required this.onBack,
  });

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: EmployeeDetailMobileTheme.header,
        border: Border(
          bottom: BorderSide(color: Color(0x1AABB3B7)),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(4, 0, 16, 0),
      height: 64,
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: EmployeeDetailMobileTheme.text,
            splashRadius: 22,
          ),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: EmployeeDetailMobileTheme.screenTitle(),
            ),
          ),
        ],
      ),
    );
  }
}
