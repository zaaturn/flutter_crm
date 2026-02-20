import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_app/employee_dashboard/bloc/employee_dashboard_bloc.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_event.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_state.dart';
import 'package:my_app/employee_dashboard/model/task_model.dart';

import 'package:my_app/employee_dashboard/widget/device_specific/task_tracker_widget/board_view.dart';
import 'package:my_app/employee_dashboard/widget/device_specific/task_tracker_widget/sidebar.dart';
import 'package:my_app/employee_dashboard/widget/device_specific/task_tracker_widget/stats_bar.dart';
import 'package:my_app/employee_dashboard/widget/device_specific/task_tracker_widget/top_bar.dart';
import 'package:my_app/employee_dashboard/widget/device_specific/task_tracker_widget/list_view.dart';

class EmployeeTaskTrackerScreen extends StatefulWidget {
  const EmployeeTaskTrackerScreen({super.key});

  @override
  State<EmployeeTaskTrackerScreen> createState() =>
      _EmployeeTaskTrackerScreenState();
}

class _EmployeeTaskTrackerScreenState
    extends State<EmployeeTaskTrackerScreen> {
  bool _isBoardView = true;
  String? _filterStatus;
  String? _filterPriority;
  final TextEditingController _searchCtrl = TextEditingController();

  // drag state
  TaskModel? _draggingTask;
  String? _hoveredColumn;

  // palette
  static const _bg = Color(0xFFF8FAFC);
  static const _pending = Color(0xFFF59E0B);
  static const _inprogress = Color(0xFF6366F1);
  static const _completed = Color(0xFF10B981);
  static const _high = Color(0xFFEF4444);
  static const _medium = Color(0xFFF97316);
  static const _low = Color(0xFF10B981);

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ───────────────── helpers ─────────────────

  Color statusColor(String s) => switch (s.toUpperCase()) {
    'IN_PROGRESS' => _inprogress,
    'COMPLETED' => _completed,
    _ => _pending,
  };

  String statusLabel(String s) => switch (s.toUpperCase()) {
    'IN_PROGRESS' => 'In Progress',
    'COMPLETED' => 'Completed',
    _ => 'Pending',
  };

  Color priorityColor(String p) => switch (p.toUpperCase()) {
    'HIGH' => _high,
    'MEDIUM' => _medium,
    _ => _low,
  };

  List<TaskModel> _filtered(List<TaskModel> tasks) {
    final q = _searchCtrl.text.toLowerCase();

    return tasks.where((t) {
      if (_filterStatus != null && t.status != _filterStatus) {
        return false;
      }

      if (_filterPriority != null && t.priority != _filterPriority) {
        return false;
      }

      if (q.isNotEmpty &&
          !t.title.toLowerCase().contains(q) &&
          !t.description.toLowerCase().contains(q)) {
        return false;
      }

      return true;
    }).toList();
  }

  void _onStatusChange(int taskId, String status) {
    context
        .read<EmployeeBloc>()
        .add(UpdateTaskStatus(taskId: taskId, status: status));
  }

  void _onDropped(TaskModel task, String targetStatus) {
    setState(() {
      _draggingTask = null;
      _hoveredColumn = null;
    });

    if (task.status != targetStatus) {
      _onStatusChange(task.id, targetStatus);
    }
  }

  // ───────────────── UI ─────────────────

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeeBloc, EmployeeState>(
      builder: (context, state) {
        final tasks = state.tasks ?? [];
        final filtered = _filtered(tasks);

        final pending =
        filtered.where((t) => t.status == 'PENDING').toList();
        final inProgress =
        filtered.where((t) => t.status == 'IN_PROGRESS').toList();
        final completed =
        filtered.where((t) => t.status == 'COMPLETED').toList();

        return Scaffold(
          backgroundColor: _bg,
          body: Column(
            children: [
              TopBar(
                searchCtrl: _searchCtrl,
                isBoardView: _isBoardView,
                onToggleView: (v) =>
                    setState(() => _isBoardView = v),
              ),
              Expanded(
                child: Row(
                  children: [
                    Sidebar(
                      tasks: tasks,
                      filterStatus: _filterStatus,
                      filterPriority: _filterPriority,
                      isBoardView: _isBoardView,
                      onStatusFilterChanged: (v) {
                        setState(() {
                          _filterStatus = v;
                          _filterPriority = null;
                        });
                      },
                      onPriorityFilterChanged: (v) {
                        setState(() {
                          _filterPriority = v;
                          _filterStatus = null;
                        });
                      },
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          StatsBar(tasks: tasks),
                          Expanded(
                            child: state.loading == true
                                ? const Center(
                              child:
                              CircularProgressIndicator(),
                            )
                                : state.error != null
                                ? Center(
                              child: Text(state.error!),
                            )
                                : Padding(
                              padding:
                              const EdgeInsets.all(20),
                              child: _isBoardView
                                  ? BoardView(
                                pending: pending,
                                inProgress:
                                inProgress,
                                completed: completed,
                                draggingTask:
                                _draggingTask,
                                hoveredColumn:
                                _hoveredColumn,
                                statusColor:
                                statusColor,
                                priorityColor:
                                priorityColor,
                                statusLabel:
                                statusLabel,
                                onDragStarted:
                                    (task) =>
                                    setState(() =>
                                    _draggingTask =
                                        task),
                                onDragEnd: () =>
                                    setState(() {
                                      _draggingTask = null;
                                      _hoveredColumn =
                                      null;
                                    }),
                                onColumnHover:
                                    (status) =>
                                    setState(() =>
                                    _hoveredColumn =
                                        status),
                                onDropped:
                                _onDropped,
                              )
                                  : TaskListView(
                                tasks: filtered,
                                onStatusChange:
                                _onStatusChange,
                                statusColor:
                                statusColor,
                                priorityColor:
                                priorityColor,
                                statusLabel:
                                statusLabel,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}