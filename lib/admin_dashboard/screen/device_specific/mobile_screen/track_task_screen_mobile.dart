import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/admin_dashboard/bloc/admin_dashboard_bloc.dart';
import 'package:my_app/admin_dashboard/bloc/admin_dashboard_event.dart';
import 'package:my_app/admin_dashboard/bloc/admin_dashboard_state.dart';
import 'package:my_app/admin_dashboard/repository/admin_repository.dart';
import 'package:my_app/admin_dashboard/model/task.dart';

class SaasTheme {
  static const terracotta = Color(0xFFB35A38);
  static const darkSlate = Color(0xFF0F172A);
  static const lightCream = Color(0xFFFAF9F6);
  static const midCream = Color(0xFFEBDDCF);

  // Status Tab Colors from Image Swatches
  static const completedBg = Color(0xFF1D5603);
  static const completedText = Color(0xFFC3F380);
  static const inProgressBg = Color(0xFFC3F380);
  static const inProgressText = Color(0xFF7523B4);
  static const pendingBg = Color(0xFFD13F13);
  static const pendingText = Color(0xFFFCC5C6);
}

class TaskTrackerScreenMobile extends StatelessWidget {
  const TaskTrackerScreenMobile({super.key});

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

  void _confirmArchive(BuildContext context, Task task) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Archive task?', style: GoogleFonts.manrope(fontWeight: FontWeight.w800)),
        content: Text(
          'Archive "${task.title}"? It will be removed from the active workspace.',
          style: GoogleFonts.manrope(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              context.read<AdminDashboardBloc>().add(ApproveTaskRequested(taskId: task.id));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Task archived', style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            },
            child: const Text('Archive'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SaasTheme.lightCream,
      appBar: AppBar(
        backgroundColor: SaasTheme.lightCream,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: SaasTheme.darkSlate, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Task Tracker",
            style: GoogleFonts.manrope(fontWeight: FontWeight.w900, color: SaasTheme.darkSlate)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: SaasTheme.darkSlate, size: 22),
            onPressed: () => context.read<AdminDashboardBloc>().add(const AdminTasksRefreshed()),
          ),
        ],
      ),
      body: BlocListener<AdminDashboardBloc, AdminDashboardState>(
        listenWhen: (prev, curr) => curr.error != null && curr.error != prev.error,
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!, style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color(0xFFEF4444),
              ),
            );
          }
        },
        child: BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator(color: SaasTheme.terracotta));
            }

            final q = searchQuery.toLowerCase();
            final filteredTasks = state.tasks.where((t) {
              final matchesStatus = t.status.trim().toLowerCase() == selectedStatus.toLowerCase();
              return matchesStatus &&
                  (q.isEmpty ||
                      t.title.toLowerCase().contains(q) ||
                      t.assignedToName.toLowerCase().contains(q));
            }).toList();

            return Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: filteredTasks.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, index) => _TaskListItem(
                            task: filteredTasks[index],
                            onArchive: () => _confirmArchive(context, filteredTasks[index]),
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Column(
        children: [
          TextField(
            onChanged: (v) => setState(() => searchQuery = v),
            style: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: SaasTheme.darkSlate),
            decoration: InputDecoration(
              hintText: "Search tasks...",
              prefixIcon: const Icon(Icons.search_rounded, color: SaasTheme.terracotta),
              filled: true,
              fillColor: SaasTheme.midCream,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 16),
          _SaaSStatusTabs(
            selected: selectedStatus,
            onChanged: (s) => setState(() => selectedStatus = s),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text("No tasks found",
          style: GoogleFonts.manrope(color: SaasTheme.darkSlate.withOpacity(0.4), fontWeight: FontWeight.w700)),
    );
  }
}

class _TaskListItem extends StatelessWidget {
  final Task task;
  final VoidCallback onArchive;

  const _TaskListItem({required this.task, required this.onArchive});

  @override
  Widget build(BuildContext context) {
    final completed = task.status.trim().toLowerCase() == 'completed';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: SaasTheme.midCream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SaasTheme.darkSlate.withOpacity(0.1), width: 1.5),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: CircleAvatar(
            backgroundColor: SaasTheme.terracotta.withOpacity(0.1),
            child: const Icon(Icons.assignment_rounded, color: SaasTheme.terracotta, size: 20),
          ),
          title: Text(
            task.title,
            style: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 15, color: SaasTheme.darkSlate),
          ),
          subtitle: Text(
            "Assigned to ${task.assignedToName}",
            style: GoogleFonts.manrope(fontSize: 12, color: SaasTheme.darkSlate.withOpacity(0.6), fontWeight: FontWeight.w700),
          ),
          iconColor: SaasTheme.terracotta,
          collapsedIconColor: SaasTheme.terracotta.withOpacity(0.5),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 1.5, color: SaasTheme.darkSlate.withOpacity(0.05)),
                  const SizedBox(height: 16),
                  Text(
                    "DESCRIPTION",
                    style: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 11, color: SaasTheme.terracotta, letterSpacing: 1),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    task.description,
                    style: GoogleFonts.manrope(color: SaasTheme.darkSlate, height: 1.6, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  if (completed) ...[
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onArchive,
                        icon: const Icon(Icons.inventory_2_outlined, size: 20),
                        label: Text('Archive', style: GoogleFonts.manrope(fontWeight: FontWeight.w800)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _SaaSStatusTabs extends StatelessWidget {
  final String selected;
  final Function(String) onChanged;

  const _SaaSStatusTabs({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildTab("Pending", 'pending', SaasTheme.pendingBg, SaasTheme.pendingText),
        const SizedBox(width: 8),
        _buildTab("In Progress", 'in_progress', SaasTheme.inProgressBg, SaasTheme.inProgressText),
        const SizedBox(width: 8),
        _buildTab("Completed", 'completed', SaasTheme.completedBg, SaasTheme.completedText),
      ],
    );
  }

  Widget _buildTab(String label, String key, Color activeBg, Color activeText) {
    bool isActive = selected == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? activeBg : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isActive ? SaasTheme.darkSlate : Colors.transparent, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: isActive ? activeText : SaasTheme.darkSlate.withOpacity(0.4),
            ),
          ),
        ),
      ),
    );
  }
}