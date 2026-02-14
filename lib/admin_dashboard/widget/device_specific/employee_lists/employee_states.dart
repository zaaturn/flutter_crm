import 'package:flutter/material.dart';

class EmployeeErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const EmployeeErrorState({
    super.key,
    this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message ?? "Something went wrong"),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text("Retry"),
          )
        ],
      ),
    );
  }
}

class EmployeeEmptyState extends StatelessWidget {
  final String? role;
  final VoidCallback onClear;

  const EmployeeEmptyState({
    super.key,
    this.role,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(role != null
              ? 'No "$role" found'
              : "No employees found"),
          const SizedBox(height: 16),
          if (role != null)
            ElevatedButton(
              onPressed: onClear,
              child: const Text("Clear Filter"),
            ),
        ],
      ),
    );
  }
}
