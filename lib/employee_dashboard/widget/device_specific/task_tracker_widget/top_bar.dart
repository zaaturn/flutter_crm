import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_app/employee_dashboard/bloc/employee_dashboard_bloc.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_event.dart';
import 'shared_widgets.dart';

class TopBar extends StatelessWidget {
  const TopBar({
    super.key,
    required this.searchCtrl,
    required this.isBoardView,
    required this.onToggleView,
  });

  final TextEditingController searchCtrl;
  final bool isBoardView;
  final ValueChanged<bool> onToggleView;

  static const _surface = Colors.white;
  static const _border = Color(0xFFE2E8F0);
  static const _textPrimary = Color(0xFF0F172A);
  static const _textMuted = Color(0xFF94A3B8);
  static const _accent = Color(0xFF6366F1);
  static const _bg = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: _surface,
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          // Logo
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _accent,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Text(
              'T',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),

          const SizedBox(width: 12),

          const Text(
            'TaskFlow',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
              letterSpacing: -0.3,
            ),
          ),

          const Spacer(),

          // ✅ Using shared widget
          ViewToggle(
            isBoardView: isBoardView,
            onToggle: onToggleView,
          ),

          const Spacer(),

          // Search
          SizedBox(
            width: 220,
            height: 36,
            child: TextField(
              controller: searchCtrl,
              style:
              const TextStyle(fontSize: 13, color: _textPrimary),
              decoration: InputDecoration(
                hintText: 'Search tasks…',
                hintStyle:
                const TextStyle(fontSize: 13, color: _textMuted),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 16,
                  color: _textMuted,
                ),
                filled: true,
                fillColor: _bg,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _accent),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),


          IconBtn(
            icon: Icons.refresh,
            tooltip: 'Refresh',
            onTap: () {
              context.read<EmployeeBloc>().add(LoadDashboard());
            },
          ),
        ],
      ),
    );
  }
}