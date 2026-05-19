import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/employee_lists/app_theme.dart';

class EmployeeShimmerList extends StatelessWidget {
  const EmployeeShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (_, __) => const EmployeeShimmerCard(),
    );
  }
}

class EmployeeShimmerCard extends StatelessWidget {
  const EmployeeShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {

    final baseColor = Colors.grey.shade200;
    final highlightColor = AppColors.primary.withOpacity(0.05);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top ID placeholder
            Align(
              alignment: Alignment.topRight,
              child: _shimmerBox(width: 40, height: 10),
            ),

            // Avatar placeholder
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 12),

            // Name placeholder
            _shimmerBox(width: 140, height: 14),
            const SizedBox(height: 6),

            // Designation placeholder
            _shimmerBox(width: 100, height: 12),
            const SizedBox(height: 12),

            // Badge placeholder
            _shimmerBox(width: 80, height: 20, radius: 20),
            const SizedBox(height: 12),

            // Bottom Tags placeholder
            Row(
              children: [
                _shimmerBox(width: 60, height: 18, radius: 6),
                const SizedBox(width: 8),
                _shimmerBox(width: 60, height: 18, radius: 6),
              ],
            ),
            const SizedBox(height: 16),

            // Button placeholders
            Row(
              children: [
                Expanded(child: _shimmerBox(height: 38, radius: 8)),
                const SizedBox(width: 8),
                _shimmerBox(width: 38, height: 38, radius: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox({double? width, required double height, double radius = 4}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}