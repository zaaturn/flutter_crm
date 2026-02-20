import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/employee_dashboard_bloc.dart';
import '../bloc/employee_dashboard_event.dart';
import '../bloc/employee_dashboard_state.dart';
import '../model/task_model.dart';

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

  // Drag state
  TaskModel? _draggingTask;
  String? _hoveredColumn;

  // ── Palette ──────────────────────────────────────────────────────────────
  static const _bg = Color(0xFFF8FAFC);
  static const _surface = Colors.white;
  static const _border = Color(0xFFE2E8F0);
  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF64748B);
  static const _textMuted = Color(0xFF94A3B8);
  static const _accent = Color(0xFF6366F1);
  static const _pending = Color(0xFFF59E0B);
  static const _pendingBg = Color(0xFFFFFBEB);
  static const _inprogress = Color(0xFF6366F1);
  static const _inprogressBg = Color(0xFFEEF2FF);
  static const _completed = Color(0xFF10B981);
  static const _completedBg = Color(0xFFECFDF5);
  static const _high = Color(0xFFEF4444);
  static const _highBg = Color(0xFFFEF2F2);
  static const _medium = Color(0xFFF97316);
  static const _mediumBg = Color(0xFFFFF7ED);
  static const _low = Color(0xFF10B981);
  static const _lowBg = Color(0xFFECFDF5);

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Color _statusColor(String s) => switch (s.toUpperCase()) {
    'IN_PROGRESS' => _inprogress,
    'COMPLETED' => _completed,
    _ => _pending,
  };

  Color _statusBg(String s) => switch (s.toUpperCase()) {
    'IN_PROGRESS' => _inprogressBg,
    'COMPLETED' => _completedBg,
    _ => _pendingBg,
  };

  String _statusLabel(String s) => switch (s.toUpperCase()) {
    'IN_PROGRESS' => 'In Progress',
    'COMPLETED' => 'Completed',
    _ => 'Pending',
  };

  Color _priorityColor(String p) => switch (p.toUpperCase()) {
    'HIGH' => _high,
    'MEDIUM' => _medium,
    _ => _low,
  };

  Color _priorityBg(String p) => switch (p.toUpperCase()) {
    'HIGH' => _highBg,
    'MEDIUM' => _mediumBg,
    _ => _lowBg,
  };

  List<TaskModel> _filtered(List<TaskModel> tasks) {
    final q = _searchCtrl.text.toLowerCase();
    return tasks.where((t) {
      if (_filterStatus != null && t.status != _filterStatus) return false;
      if (_filterPriority != null && t.priority != _filterPriority) return false;
      if (q.isNotEmpty &&
          !t.title.toLowerCase().contains(q) &&
          !t.description.toLowerCase().contains(q)) return false;
      return true;
    }).toList();
  }

  void _onStatusChange(int taskId, String status) =>
      context.read<EmployeeBloc>().add(UpdateTaskStatus(taskId: taskId, status: status));

  void _onDropped(TaskModel task, String targetStatus) {
    setState(() {
      _draggingTask = null;
      _hoveredColumn = null;
    });
    if (task.status != targetStatus) _onStatusChange(task.id, targetStatus);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeeBloc, EmployeeState>(
      builder: (context, state) {
        final tasks = state.tasks ?? [];
        final filtered = _filtered(tasks);
        final pending = filtered.where((t) => t.status == 'PENDING').toList();
        final inProgress = filtered.where((t) => t.status == 'IN_PROGRESS').toList();
        final completed = filtered.where((t) => t.status == 'COMPLETED').toList();

        return Scaffold(
          backgroundColor: _bg,
          body: Column(
            children: [
              _buildTopBar(tasks),
              Expanded(
                child: Row(
                  children: [
                    _buildSidebar(tasks),
                    Expanded(
                      child: Column(
                        children: [
                          _buildStatsBar(tasks),
                          Expanded(
                            child: state.loading == true
                                ? const Center(
                                child: CircularProgressIndicator(
                                    color: _accent, strokeWidth: 2))
                                : state.error != null
                                ? _buildError(state.error!)
                                : Padding(
                              padding: const EdgeInsets.all(20),
                              child: _isBoardView
                                  ? _buildBoardView(pending, inProgress, completed)
                                  : _buildListView(filtered),
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

  // ── TOP BAR ──────────────────────────────────────────────────────────────
  Widget _buildTopBar(List<TaskModel> tasks) {
    return Container(
      height: 60,
      color: _surface,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: _border))),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
                color: _accent, borderRadius: BorderRadius.circular(8)),
            alignment: Alignment.center,
            child: const Text('T',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
          ),
          const SizedBox(width: 12),
          const Text('TaskFlow',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: _textPrimary, letterSpacing: -0.3)),
          const Spacer(),
          _ViewToggle(isBoardView: _isBoardView, onToggle: (v) => setState(() => _isBoardView = v)),
          const Spacer(),
          SizedBox(
            width: 220, height: 36,
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 13, color: _textPrimary),
              decoration: InputDecoration(
                hintText: 'Search tasks…',
                hintStyle: const TextStyle(fontSize: 13, color: _textMuted),
                prefixIcon: const Icon(Icons.search, size: 16, color: _textMuted),
                filled: true, fillColor: _bg,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _accent)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _IconBtn(icon: Icons.refresh, onTap: () => context.read<EmployeeBloc>().add(LoadDashboard()), tooltip: 'Refresh'),
        ],
      ),
    );
  }

  // ── SIDEBAR ──────────────────────────────────────────────────────────────
  Widget _buildSidebar(List<TaskModel> tasks) {
    final statusItems = [
      ('All Tasks', null, Icons.home_outlined, tasks.length),
      ('Pending', 'PENDING', Icons.schedule_outlined, tasks.where((t) => t.status == 'PENDING').length),
      ('In Progress', 'IN_PROGRESS', Icons.trending_up_outlined, tasks.where((t) => t.status == 'IN_PROGRESS').length),
      ('Completed', 'COMPLETED', Icons.check_circle_outline, tasks.where((t) => t.status == 'COMPLETED').length),
    ];
    final priorityItems = [
      ('High Priority', 'HIGH', Icons.keyboard_arrow_up_outlined, _high),
      ('Medium Priority', 'MEDIUM', Icons.remove_outlined, _medium),
      ('Low Priority', 'LOW', Icons.keyboard_arrow_down_outlined, _low),
    ];

    return Container(
      width: 220,
      color: _surface,
      decoration: const BoxDecoration(border: Border(right: BorderSide(color: _border))),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sidebarLabel('Workspace'),
          ...statusItems.map((item) => _SidebarItem(
            label: item.$1, icon: item.$3, badge: item.$4,
            isActive: _filterStatus == item.$2 && item.$2 != null,
            isAllActive: item.$2 == null && _filterStatus == null && _filterPriority == null,
            onTap: () => setState(() {
              _filterStatus = _filterStatus == item.$2 ? null : item.$2;
              _filterPriority = null;
            }),
          )),
          const SizedBox(height: 8),
          const Divider(color: _border, height: 1),
          const SizedBox(height: 8),
          _sidebarLabel('Priority'),
          ...priorityItems.map((item) => _SidebarItem(
            label: item.$1, icon: item.$3, priorityColor: item.$4,
            isActive: _filterPriority == item.$2,
            onTap: () => setState(() {
              _filterPriority = _filterPriority == item.$2 ? null : item.$2;
              _filterStatus = null;
            }),
          )),
          const Spacer(),
          // Drag hint — only in board view
          if (_isBoardView)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFC7D2FE)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.drag_indicator, size: 14, color: _accent),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Drag cards between columns to change status',
                      style: TextStyle(fontSize: 11, color: _accent, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _sidebarLabel(String label) => Padding(
    padding: const EdgeInsets.only(left: 8, top: 4, bottom: 6),
    child: Text(label.toUpperCase(),
        style: const TextStyle(
            fontSize: 10, fontWeight: FontWeight.w700,
            letterSpacing: 1, color: _textMuted)),
  );

  // ── STATS BAR ────────────────────────────────────────────────────────────
  Widget _buildStatsBar(List<TaskModel> tasks) {
    return Container(
      color: _surface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: _border))),
      child: Row(
        children: [
          _StatCard(label: 'Total', value: tasks.length, color: _textSecondary),
          const SizedBox(width: 12),
          _StatCard(label: 'Pending', value: tasks.where((t) => t.status == 'PENDING').length, color: _pending),
          const SizedBox(width: 12),
          _StatCard(label: 'In Progress', value: tasks.where((t) => t.status == 'IN_PROGRESS').length, color: _inprogress),
          const SizedBox(width: 12),
          _StatCard(label: 'Completed', value: tasks.where((t) => t.status == 'COMPLETED').length, color: _completed),
        ],
      ),
    );
  }

  // ── BOARD VIEW WITH DRAG & DROP ──────────────────────────────────────────
  Widget _buildBoardView(List<TaskModel> pending, List<TaskModel> inProgress, List<TaskModel> completed) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildDragColumn('PENDING', pending)),
        const SizedBox(width: 16),
        Expanded(child: _buildDragColumn('IN_PROGRESS', inProgress)),
        const SizedBox(width: 16),
        Expanded(child: _buildDragColumn('COMPLETED', completed)),
      ],
    );
  }

  Widget _buildDragColumn(String status, List<TaskModel> tasks) {
    final isHovered = _hoveredColumn == status;
    final colColor = _statusColor(status);

    return DragTarget<TaskModel>(
      onWillAcceptWithDetails: (details) {
        if (details.data.status == status) return false;
        setState(() => _hoveredColumn = status);
        return true;
      },
      onLeave: (_) => setState(() => _hoveredColumn = null),
      onAcceptWithDetails: (details) => _onDropped(details.data, status),
      builder: (context, candidateData, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isHovered ? colColor.withOpacity(0.04) : _surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHovered ? colColor.withOpacity(0.5) : _border,
              width: isHovered ? 2 : 1,
            ),
            boxShadow: isHovered
                ? [BoxShadow(color: colColor.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 4))]
                : null,
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: isHovered ? colColor.withOpacity(0.2) : _border)),
                ),
                child: Row(
                  children: [
                    Container(width: 9, height: 9,
                        decoration: BoxDecoration(color: colColor, shape: BoxShape.circle)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(_statusLabel(status),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textPrimary)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                      decoration: BoxDecoration(
                        color: isHovered ? colColor.withOpacity(0.1) : _bg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isHovered ? colColor.withOpacity(0.3) : _border),
                      ),
                      child: Text('${tasks.length}',
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700,
                              color: isHovered ? colColor : _textSecondary)),
                    ),
                  ],
                ),
              ),

              // Drop hint
              if (isHovered && candidateData.isNotEmpty)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: colColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colColor.withOpacity(0.4), width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_downward_rounded, size: 14, color: colColor),
                      const SizedBox(width: 6),
                      Text('Drop to move → ${_statusLabel(status)}',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colColor)),
                    ],
                  ),
                ),

              // Cards
              Expanded(
                child: tasks.isEmpty && !isHovered
                    ? _emptyColumn(status)
                    : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _DraggableTaskCard(
                    task: tasks[i],
                    priorityColor: _priorityColor(tasks[i].priority),
                    priorityBg: _priorityBg(tasks[i].priority),
                    statusColor: _statusColor,
                    isDragging: _draggingTask?.id == tasks[i].id,
                    onDragStarted: () => setState(() => _draggingTask = tasks[i]),
                    onDragEnd: () => setState(() {
                      _draggingTask = null;
                      _hoveredColumn = null;
                    }),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _emptyColumn(String status) {
    final color = _statusColor(status);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 36, color: _border),
            const SizedBox(height: 8),
            const Text('No tasks', style: TextStyle(fontSize: 13, color: _textMuted)),
            const SizedBox(height: 4),
            Text('Drop a card here',
                style: TextStyle(fontSize: 11, color: color.withOpacity(0.6))),
          ],
        ),
      ),
    );
  }

  // ── LIST VIEW ─────────────────────────────────────────────────────────────
  Widget _buildListView(List<TaskModel> tasks) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
            decoration: const BoxDecoration(
              color: _bg,
              border: Border(bottom: BorderSide(color: _border)),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: _HeaderCell('Task')),
                Expanded(flex: 1, child: _HeaderCell('Priority')),
                Expanded(flex: 2, child: _HeaderCell('Status')),
                Expanded(flex: 1, child: _HeaderCell('Assignee')),
              ],
            ),
          ),
          Expanded(
            child: tasks.isEmpty
                ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_outlined, size: 56, color: _border),
                  SizedBox(height: 12),
                  Text('No tasks available',
                      style: TextStyle(fontSize: 15, color: _textMuted)),
                ],
              ),
            )
                : ListView.separated(
              itemCount: tasks.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: _border),
              itemBuilder: (_, i) => _ListRow(
                task: tasks[i],
                statusColor: _statusColor,
                statusBg: _statusBg,
                statusLabel: _statusLabel,
                priorityColor: _priorityColor,
                priorityBg: _priorityBg,
                onStatusChange: _onStatusChange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String err) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, size: 48, color: _high),
        const SizedBox(height: 12),
        Text(err, style: const TextStyle(fontSize: 13, color: _textSecondary)),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: _accent),
          onPressed: () => context.read<EmployeeBloc>().add(LoadDashboard()),
          child: const Text('Retry', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

// ════════════════════════════════════════════════════════════════════════════
// ── DRAGGABLE TASK CARD ───────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════

class _DraggableTaskCard extends StatefulWidget {
  const _DraggableTaskCard({
    required this.task,
    required this.priorityColor,
    required this.priorityBg,
    required this.statusColor,
    required this.isDragging,
    required this.onDragStarted,
    required this.onDragEnd,
  });

  final TaskModel task;
  final Color priorityColor;
  final Color priorityBg;
  final Color Function(String) statusColor;
  final bool isDragging;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnd;

  @override
  State<_DraggableTaskCard> createState() => _DraggableTaskCardState();
}

class _DraggableTaskCardState extends State<_DraggableTaskCard> {
  bool _hovered = false;

  Widget _cardBody({bool isFeedback = false}) {
    final t = widget.task;
    return Container(
      width: isFeedback ? 260 : null,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isFeedback
              ? const Color(0xFF6366F1)
              : _hovered
              ? const Color(0xFFCBD5E1)
              : const Color(0xFFE2E8F0),
          width: isFeedback ? 2 : 1,
        ),
        boxShadow: isFeedback
            ? [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.2), blurRadius: 24, offset: const Offset(0, 8))]
            : _hovered
            ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4))]
            : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.drag_indicator,
                  size: 16,
                  color: isFeedback
                      ? const Color(0xFF6366F1)
                      : _hovered
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFFCBD5E1)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(t.title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A), height: 1.4),
                    maxLines: isFeedback ? 1 : null,
                    overflow: isFeedback ? TextOverflow.ellipsis : null),
              ),
            ],
          ),
          if (t.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(t.description,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.5),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: widget.priorityBg, borderRadius: BorderRadius.circular(5)),
                child: Text(t.priority.toUpperCase(),
                    style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w700,
                        color: widget.priorityColor, letterSpacing: 0.5)),
              ),
              const Spacer(),
              CircleAvatar(
                radius: 13,
                backgroundColor: widget.statusColor(t.status).withOpacity(0.12),
                child: Text(
                  t.title.isNotEmpty ? t.title[0].toUpperCase() : '?',
                  style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700,
                      color: widget.statusColor(t.status)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Draggable<TaskModel>(
      data: widget.task,
      onDragStarted: widget.onDragStarted,
      onDragEnd: (_) => widget.onDragEnd(),
      onDraggableCanceled: (_, __) => widget.onDragEnd(),
      // Floating card shown under cursor
      feedback: Material(
        color: Colors.transparent,
        child: Transform.rotate(angle: 0.018, child: _cardBody(isFeedback: true)),
      ),
      // Invisible placeholder in original column
      childWhenDragging: Opacity(opacity: 0.0, child: _cardBody()),
      child: MouseRegion(
        cursor: SystemMouseCursors.grab,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: widget.isDragging ? 0.35 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            child: _cardBody(),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// ── SHARED WIDGETS ────────────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.isBoardView, required this.onToggle});
  final bool isBoardView;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleBtn(icon: Icons.grid_view_rounded, label: 'Board', isActive: isBoardView, onTap: () => onToggle(true)),
          const SizedBox(width: 2),
          _ToggleBtn(icon: Icons.view_list_rounded, label: 'List', isActive: !isBoardView, onTap: () => onToggle(false)),
        ],
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  const _ToggleBtn({required this.icon, required this.label, required this.isActive, required this.onTap});
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          boxShadow: isActive
              ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: isActive ? const Color(0xFF6366F1) : const Color(0xFF94A3B8)),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: isActive ? const Color(0xFF0F172A) : const Color(0xFF94A3B8))),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.label, required this.icon, required this.onTap,
    this.badge, this.isActive = false, this.isAllActive = false, this.priorityColor,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final int? badge;
  final bool isActive;
  final bool isAllActive;
  final Color? priorityColor;

  @override
  Widget build(BuildContext context) {
    final active = isActive || isAllActive;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFEEF2FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15,
                color: active ? const Color(0xFF6366F1) : priorityColor ?? const Color(0xFF94A3B8)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                      color: active ? const Color(0xFF6366F1) : const Color(0xFF64748B))),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                decoration: BoxDecoration(
                  color: active ? const Color(0xFFEEF2FF) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: active ? const Color(0xFFC7D2FE) : const Color(0xFFE2E8F0)),
                ),
                child: Text('$badge',
                    style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w700,
                        color: active ? const Color(0xFF6366F1) : const Color(0xFF94A3B8))),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.color});
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$value', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color, height: 1)),
                const SizedBox(height: 2),
                Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ListRow extends StatefulWidget {
  const _ListRow({
    required this.task, required this.statusColor, required this.statusBg,
    required this.statusLabel, required this.priorityColor, required this.priorityBg,
    required this.onStatusChange,
  });
  final TaskModel task;
  final Color Function(String) statusColor;
  final Color Function(String) statusBg;
  final String Function(String) statusLabel;
  final Color Function(String) priorityColor;
  final Color Function(String) priorityBg;
  final void Function(int, String) onStatusChange;

  @override
  State<_ListRow> createState() => _ListRowState();
}

class _ListRowState extends State<_ListRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.task;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        color: _hovered ? const Color(0xFFF8FAFC) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 3, height: 38,
                    decoration: BoxDecoration(
                        color: widget.statusColor(t.status), borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.title,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        if (t.description.isNotEmpty)
                          Text(t.description,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: widget.priorityBg(t.priority), borderRadius: BorderRadius.circular(5)),
                child: Text(t.priority.toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                        color: widget.priorityColor(t.priority), letterSpacing: 0.5)),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: widget.statusBg(t.status),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: widget.statusColor(t.status).withOpacity(0.25)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: t.status,
                    isDense: true,
                    icon: Icon(Icons.keyboard_arrow_down, size: 14, color: widget.statusColor(t.status)),
                    style: TextStyle(color: widget.statusColor(t.status), fontSize: 12, fontWeight: FontWeight.w600),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    items: const [
                      DropdownMenuItem(value: 'PENDING', child: Text('Pending')),
                      DropdownMenuItem(value: 'IN_PROGRESS', child: Text('In Progress')),
                      DropdownMenuItem(value: 'COMPLETED', child: Text('Completed')),
                    ],
                    onChanged: (v) {
                      if (v != null && v != t.status) widget.onStatusChange(t.id, v);
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: CircleAvatar(
                radius: 14,
                backgroundColor: widget.statusColor(t.status).withOpacity(0.1),
                child: Text(
                  t.title.isNotEmpty ? t.title[0].toUpperCase() : '?',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: widget.statusColor(t.status)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label.toUpperCase(),
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.7, color: Color(0xFF94A3B8)));
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap, required this.tooltip});
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 17, color: const Color(0xFF64748B)),
        ),
      ),
    );
  }
}