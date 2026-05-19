import 'package:flutter/material.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/employee_lists/app_theme.dart';

class EmployeeFilterSheet extends StatefulWidget {
  final List<String> designations;
  final String? selected;
  final ValueChanged<String?> onSelected;

  const EmployeeFilterSheet({
    super.key,
    required this.designations,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<EmployeeFilterSheet> createState() => _EmployeeFilterSheetState();
}

class _EmployeeFilterSheetState extends State<EmployeeFilterSheet> {
  String? _picked;

  @override
  void initState() {
    super.initState();
    _picked = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32), // Extra bottom padding for safe area
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Handle Bar ──────────────────────────
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // ── Header ──────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter by Designation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textHeading,
                ),
              ),
              if (_picked != null)
                TextButton(
                  onPressed: () => setState(() => _picked = null),
                  child: const Text(
                    'Reset',
                    style: TextStyle(color: AppColors.offline, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Designation Grid/Wrap ────────────────
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: widget.designations.map((designation) {
              final isSelected = _picked == designation;
              return InkWell(
                onTap: () {
                  setState(() {
                    _picked = isSelected ? null : designation;
                  });
                },
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    designation,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textBody,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // ── Apply Button ────────────────────────
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                widget.onSelected(_picked);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Apply Filters",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }
}