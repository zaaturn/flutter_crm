import 'package:flutter/material.dart';

class EmployeeShimmerList extends StatelessWidget {
  const EmployeeShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (_, __) => const EmployeeShimmerCard(),
    );
  }
}

class EmployeeShimmerCard extends StatelessWidget {
  const EmployeeShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      margin: const EdgeInsets.all(8),
      color: Colors.grey.shade300,
    );
  }
}
