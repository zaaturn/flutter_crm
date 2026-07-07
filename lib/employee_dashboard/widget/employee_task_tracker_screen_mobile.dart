import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Ensure these imports match your project structure exactly
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_bloc.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_event.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_state.dart';
import 'package:my_app/employee_dashboard/model/task_model.dart';
import 'package:my_app/tasks/presentation/task_detail_screen.dart';
import 'package:my_app/employee_dashboard/widget/bottom_nav.dart';
class EmployeeTaskTrackerScreenMobile extends StatefulWidget {
  /// Highlights the task row when opened from a notification.
  final int? focusTaskId;

  const EmployeeTaskTrackerScreenMobile({super.key, this.focusTaskId});

  @override
  State<EmployeeTaskTrackerScreenMobile> createState() =>
      _EmployeeTaskTrackerScreenMobileState();
}

class _EmployeeTaskTrackerScreenMobileState extends State<EmployeeTaskTrackerScreenMobile> {
  bool _isBoardView = true;

  @override
  void initState() {
    super.initState();
    if (widget.focusTaskId != null) {
      _isBoardView = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => TaskDetailScreen(taskId: widget.focusTaskId!),
          ),
        );
      });
    }
  }
  String? _selectedStatus;
  String? _selectedPriority;
  final TextEditingController _searchCtrl = TextEditingController();

  // Mobile terracotta palette (matches other mobile modules)
  static const _bg = Color(0xFFFAF3E0); // cream
  static const _surface = Color(0xFFF6E7D2); // beige card
  static const _terracotta = Color(0xFFD9822B);
  static const _terracottaDark = Color(0xFFB85C1E);
  static const _textMain = Color(0xFF3E2C1C);
  static const _textMuted = Color(0xFF7A5C3E);
  static const _border = Color(0x33B85C1E);

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── FILTER LOGIC ───────────────────────────────────────────────────────────
  List<TaskModel> _getFilteredTasks(List<TaskModel> tasks) {
    final query = _searchCtrl.text.toLowerCase().trim();
    return tasks.where((task) {
      final matchesSearch = query.isEmpty ||
          task.title.toLowerCase().contains(query) ||
          task.description.toLowerCase().contains(query);

      final matchesStatus = _selectedStatus == null ||
          task.status.toUpperCase() == _selectedStatus!.toUpperCase() ||
          task.status.toUpperCase().replaceAll(' ', '_') == _selectedStatus;

      final matchesPriority = _selectedPriority == null ||
          task.priority.toUpperCase() == _selectedPriority!.toUpperCase();

      return matchesSearch && matchesStatus && matchesPriority;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeeBloc, EmployeeState>(
      builder: (context, state) {
        final allTasks = state.tasks;
        final filteredTasks = _getFilteredTasks(allTasks);

        return Scaffold(
          backgroundColor: _bg,
          appBar: _buildAppBar(),
          body: Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: filteredTasks.isEmpty
                    ? _buildEmptyState()
                    : _isBoardView
                    ? _buildBoardView(filteredTasks)
                    : _buildListView(filteredTasks),
              ),
            ],
          ),
          bottomNavigationBar: const BottomNav(currentIndex: 1),
        );
      },
    );
  }

  // ── APP BAR ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() => AppBar(
    backgroundColor: _bg,
    elevation: 0,
    scrolledUnderElevation: 0,
    surfaceTintColor: Colors.transparent,
    shadowColor: Colors.transparent,
    centerTitle: false,
    title: const Text("My Tasks",
        style: TextStyle(color: _textMain, fontSize: 24, fontWeight: FontWeight.w900)),
    actions: [
      IconButton(
        onPressed: () => setState(() => _isBoardView = !_isBoardView),
        icon: Icon(_isBoardView ? Icons.view_agenda_outlined : Icons.grid_view_outlined,
            color: _terracottaDark),
      )
    ],
  );

  // ── SEARCH & FILTERS ───────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _border),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() {}),
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: _textMuted),
                  hintText: "Search tasks...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildFilterTrigger(),
        ],
      ),
    );
  }

  Widget _buildFilterTrigger() {
    final bool hasActiveFilters = _selectedStatus != null || _selectedPriority != null;
    return GestureDetector(
      onTap: _showFilters,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: hasActiveFilters ? _terracottaDark : _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Icon(Icons.tune_rounded,
            color: hasActiveFilters ? Colors.white : _terracottaDark),
      ),
    );
  }

  // ── LIST VIEW ──────────────────────────────────────────────────────────────
  Widget _buildListView(List<TaskModel> tasks) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) => _MobileTaskCard(
        task: tasks[index],
        highlight: widget.focusTaskId == tasks[index].id,
      ),
    );
  }

  // ── BOARD VIEW (DYNAMIC HEIGHT) ───────────────────────────────────────────
  Widget _buildBoardView(List<TaskModel> tasks) {
    final pending = tasks.where((t) => t.status.toUpperCase() == 'PENDING').toList();
    final active = tasks.where((t) => t.status.toUpperCase().contains('PROGRESS')).toList();
    final done = tasks.where((t) => t.status.toUpperCase() == 'COMPLETED').toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBoardColumn("Pending", pending, _terracotta),
            _buildBoardColumn("Active", active, _terracottaDark),
            _buildBoardColumn("Done", done, const Color(0xFF2F7D32)),
          ],
        ),
      ),
    );
  }

  Widget _buildBoardColumn(String title, List<TaskModel> columnTasks, Color color) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.82,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: _textMain)),
                  const Spacer(),
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: color.withOpacity(0.1),
                    child: Text("${columnTasks.length}", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ],
              ),
            ),
            ...columnTasks.map((task) => Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: _MobileTaskCard(
              task: task,
              highlight: widget.focusTaskId == task.id,
            ),
            )),
          ],
        ),
      ),
    );
  }

  // ── FILTER MODAL ──────────────────────────────────────────────────────────
  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
              left: 24, right: 24, top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Filter Tasks", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close))
                ],
              ),
              const SizedBox(height: 20),
              _filterHeading("BY STATUS"),
              _buildChips(['PENDING', 'IN_PROGRESS', 'COMPLETED'], _selectedStatus, (val) => setState(() => _selectedStatus = val), setModalState),
              const SizedBox(height: 24),
              _filterHeading("BY PRIORITY"),
              _buildChips(['HIGH', 'MEDIUM', 'LOW'], _selectedPriority, (val) => setState(() => _selectedPriority = val), setModalState),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _terracottaDark,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () { setState(() {}); Navigator.pop(context); },
                child: const Text("Apply Filters", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              TextButton(
                onPressed: () { setState(() { _selectedStatus = null; _selectedPriority = null; }); Navigator.pop(context); },
                child: const Center(child: Text("Clear All", style: TextStyle(color: Colors.redAccent))),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterHeading(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: _textMuted, letterSpacing: 1.2)),
  );

  Widget _buildChips(List<String> options, String? selected, Function(String?) onSelected, StateSetter setModalState) {
    return Wrap(
      spacing: 8,
      children: options.map((opt) {
        final isSelected = selected == opt;
        return ChoiceChip(
          label: Text(opt.replaceAll('_', ' ')),
          selected: isSelected,
          onSelected: (val) => setModalState(() => onSelected(val ? opt : null)),
          selectedColor: _terracottaDark,
          labelStyle: TextStyle(color: isSelected ? Colors.white : _textMain, fontWeight: FontWeight.bold, fontSize: 12),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.search_off_rounded, size: 64, color: _textMuted.withOpacity(0.1)),
        const SizedBox(height: 16),
        const Text("No matches found", style: TextStyle(color: _textMuted, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

// ── DYNAMIC TASK CARD (AUTO-ADJUSTS SIZE) ──────────────────────────────────
class _MobileTaskCard extends StatelessWidget {
  final TaskModel task;
  final bool highlight;

  const _MobileTaskCard({
    required this.task,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    const bg = _EmployeeTaskTrackerScreenMobileState._bg;
    const surface = _EmployeeTaskTrackerScreenMobileState._surface;
    const terracotta = _EmployeeTaskTrackerScreenMobileState._terracotta;
    const terracottaDark = _EmployeeTaskTrackerScreenMobileState._terracottaDark;
    const textMain = _EmployeeTaskTrackerScreenMobileState._textMain;
    const textMuted = _EmployeeTaskTrackerScreenMobileState._textMuted;
    const border = _EmployeeTaskTrackerScreenMobileState._border;

    return InkWell(
      onTap: () {
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => TaskDetailScreen(
              taskId: task.id,
              onUpdated: (_) => context.read<EmployeeBloc>().add(RefreshEvent()),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: highlight ? terracottaDark : border,
          width: highlight ? 2.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: highlight
                ? terracottaDark.withOpacity(0.16)
                : Colors.black.withOpacity(0.05),
            blurRadius: highlight ? 16 : 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Shrinks to fit content
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _priorityBadge(task.priority),
              _statusPicker(context, task),
            ],
          ),
          const SizedBox(height: 14),
          Text(task.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: textMain)),
          const SizedBox(height: 8),
          // Description expands to full length
          Text(
            task.description,
            style: const TextStyle(color: textMuted, fontSize: 14, height: 1.5),
          ),
          if (task.assignedByName != null && task.assignedByName!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.person_outline_rounded, size: 14, color: textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Assigned by ${task.assignedByName}',
                    style: const TextStyle(
                      color: textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ),
    );
  }

  Widget _priorityBadge(String priority) {
    // Keep priority distinct but harmonized with terracotta palette.
    final Color color = switch (priority.toUpperCase()) {
      'HIGH' => const Color(0xFFB42318),
      'MEDIUM' => const Color(0xFFB85C1E),
      _ => const Color(0xFF1D4ED8),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(priority, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }

  Widget _statusPicker(BuildContext context, TaskModel task) {
    return PopupMenuButton<String>(
      onSelected: (val) {
        context.read<EmployeeBloc>().add(UpdateTaskStatus(taskId: task.id, status: val));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _EmployeeTaskTrackerScreenMobileState._terracottaDark.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _EmployeeTaskTrackerScreenMobileState._border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(task.status.replaceAll('_', ' '),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: _EmployeeTaskTrackerScreenMobileState._terracottaDark,
                )),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 14,
              color: _EmployeeTaskTrackerScreenMobileState._terracottaDark,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'PENDING', child: Text("Pending")),
        const PopupMenuItem(value: 'IN_PROGRESS', child: Text("In Progress")),
        const PopupMenuItem(value: 'COMPLETED', child: Text("Completed")),
      ],
    );
  }
}