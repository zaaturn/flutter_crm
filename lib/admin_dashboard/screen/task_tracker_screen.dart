import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/admin_dashboard_bloc.dart';
import '../bloc/admin_dashboard_state.dart';
import '../bloc/admin_dashboard_event.dart';

import '../repository/admin_repository.dart';
import '../model/task.dart';
import '../widget/task_card.dart';

class TaskTrackerScreen extends StatelessWidget {
  const TaskTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminDashboardBloc(
        repository: AdminRepository(),
      )..add(const AdminDashboardStarted()),
      child: const _TaskTrackerView(),
    );
  }
}

class _TaskTrackerView extends StatefulWidget {
  const _TaskTrackerView();

  @override
  State<_TaskTrackerView> createState() => _TaskTrackerViewState();
}

class _TaskTrackerViewState extends State<_TaskTrackerView> {
  String selectedStatus = 'pending';
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Task Tracker",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black54),
            onPressed: () {
              context
                  .read<AdminDashboardBloc>()
                  .add(const AdminTasksRefreshed());
            },
          )
        ],
      ),
      body: BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<Task> tasks = state.tasks;

          final filteredTasks = tasks.where((t) {
            final matchesStatus = t.status == selectedStatus;

            final query = searchQuery.toLowerCase();
            final matchesSearch = query.isEmpty ||
                t.title.toLowerCase().contains(query) ||
                t.description.toLowerCase().contains(query) ||
                t.assignedToName.toLowerCase().contains(query);

            return matchesStatus && matchesSearch;
          }).toList();

          return Column(
            children: [
              _TaskSearchBar(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.trim().toLowerCase();
                  });
                },
              ),
              _TaskStatusTabs(
                tasks: tasks,
                selectedStatus: selectedStatus,
                onChanged: (status) {
                  setState(() {
                    selectedStatus = status;
                  });
                },
              ),
              Expanded(
                child: filteredTasks.isEmpty
                    ? const Center(
                  child: Text(
                    "No tasks found",
                    style: TextStyle(color: Colors.black45),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    return TaskCard(task: filteredTasks[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TaskSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _TaskSearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: "Search tasks, employees, project",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _TaskStatusTabs extends StatelessWidget {
  final List<Task> tasks;
  final String selectedStatus;
  final Function(String) onChanged;

  const _TaskStatusTabs({
    required this.tasks,
    required this.selectedStatus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final pending = tasks.where((t) => t.status == 'pending').length;
    final inProgress =
        tasks.where((t) => t.status == 'in_progress').length;
    final completed =
        tasks.where((t) => t.status == 'completed').length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _StatusTab(
            title: "Pending",
            count: pending,
            active: selectedStatus == 'pending',
            onTap: () => onChanged('pending'),
          ),
          const SizedBox(width: 8),
          _StatusTab(
            title: "In Progress",
            count: inProgress,
            active: selectedStatus == 'in_progress',
            onTap: () => onChanged('in_progress'),
          ),
          const SizedBox(width: 8),
          _StatusTab(
            title: "Completed",
            count: completed,
            active: selectedStatus == 'completed',
            onTap: () => onChanged('completed'),
          ),
        ],
      ),
    );
  }
}

class _StatusTab extends StatelessWidget {
  final String title;
  final int count;
  final bool active;
  final VoidCallback onTap;

  const _StatusTab({
    required this.title,
    required this.count,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? Colors.blue : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: active ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (count > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white
                          : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      count.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}


