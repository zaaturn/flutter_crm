import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:my_app/tasks/models/crm_task.dart';
import 'package:my_app/tasks/presentation/task_edit_screen.dart';
import 'package:my_app/tasks/services/crm_task_api_service.dart';
import 'package:my_app/tasks/task_permissions.dart';

class TaskDetailScreen extends StatefulWidget {
  final int taskId;
  final void Function(CrmTask updated)? onUpdated;
  final String? dueDateReminder;

  const TaskDetailScreen({
    super.key,
    required this.taskId,
    this.onUpdated,
    this.dueDateReminder,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  static const _purple = Color(0xFF7C3AED);
  static const _purpleLight = Color(0xFFF5F3FF);
  static const _purpleDark = Color(0xFF4C1D95);
  static const _borderPurple = Color(0xFFEDE9FE);
  static const _textPrimary = Color(0xFF0F172A);
  static const _textMuted = Color(0xFF64748B);
  static const _labelMuted = Color(0xFF94A3B8);
  static const _fieldBg = Color(0xFFF8FAFC);
  static const _border = Color(0xFFE2E8F0);

  final _api = CrmTaskApiService();
  CrmTask? _task;
  bool _loading = true;
  bool _canEdit = false;
  bool _canUpdateStatus = false;
  bool _updatingStatus = false;
  String? _error;

  static const _statuses = ['PENDING', 'IN_PROGRESS', 'COMPLETED'];

  @override
  void initState() {
    super.initState();
    _load();
    _maybeShowDueReminder();
  }

  void _maybeShowDueReminder() {
    final hint = widget.dueDateReminder;
    if (hint == null || hint.trim().isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Task due: $hint',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
          backgroundColor: _purple,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final task = await _api.getTask(widget.taskId);
      final editable = await canEditTask(task);
      final statusEditable = await canUpdateTaskStatus(task);
      if (!mounted) return;
      setState(() {
        _task = task;
        _canEdit = editable;
        _canUpdateStatus = statusEditable;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openEdit() async {
    final task = _task;
    if (task == null) return;
    final updated = await Navigator.of(context).push<CrmTask>(
      MaterialPageRoute(
        builder: (_) => TaskEditScreen(taskId: task.id),
      ),
    );
    if (updated != null) {
      widget.onUpdated?.call(updated);
      await _load();
    }
  }

  Future<void> _onStatusChanged(String status) async {
    if (_updatingStatus) return;
    setState(() => _updatingStatus = true);
    try {
      final updated = await _api.updateTaskStatus(widget.taskId, status);
      widget.onUpdated?.call(updated);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Status updated',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    } finally {
      if (mounted) setState(() => _updatingStatus = false);
    }
  }

  Color _priorityColor(String p) => switch (p.toUpperCase()) {
        'HIGH' => const Color(0xFFEF4444),
        'LOW' => const Color(0xFF10B981),
        _ => _purple,
      };

  Color _statusColor(String s) => switch (s.toUpperCase()) {
        'COMPLETED' => const Color(0xFF10B981),
        'IN_PROGRESS' => _purple,
        _ => _textMuted,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _purpleLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: const BackButton(color: _textPrimary),
        title: Text(
          'Task details',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: _textPrimary,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: _borderPurple, height: 1),
        ),
        actions: [
          if (_canEdit && _task != null && !_task!.isApproved)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: _openEdit,
                icon: const Icon(Icons.edit_rounded, size: 18, color: _purple),
                label: Text(
                  'Edit',
                  style: GoogleFonts.plusJakartaSans(
                    color: _purple,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _purple))
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: GoogleFonts.plusJakartaSans(color: _textMuted),
                  ),
                )
              : _buildBody(_task!),
    );
  }

  Widget _buildBody(CrmTask task) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _mainCard(task)),
                const SizedBox(width: 24),
                Expanded(flex: 2, child: _metaCard(task)),
              ],
            );
          }
          return Column(
            children: [
              _mainCard(task),
              const SizedBox(height: 20),
              _metaCard(task),
            ],
          );
        },
      ),
    );
  }

  Widget _mainCard(CrmTask task) {
    return _card(
      title: 'Overview',
      icon: Icons.assignment_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (task.isApproved) _approvedBanner(),
          Text(
            task.title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 20),
          _label('Description'),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _fieldBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: Text(
              task.description.isEmpty ? 'No description provided.' : task.description,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                height: 1.6,
                color: _textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (task.attachment != null && task.attachment!.isNotEmpty) ...[
            const SizedBox(height: 20),
            _label('Attachment'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _purpleLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _borderPurple),
              ),
              child: Row(
                children: [
                  const Icon(Icons.attach_file_rounded, color: _purple, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      task.attachment!,
                      style: GoogleFonts.plusJakartaSans(
                        color: _purpleDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _metaCard(CrmTask task) {
    return _card(
      title: 'Details',
      icon: Icons.info_outline_rounded,
      child: Column(
        children: [
          _detailTile(
            icon: Icons.calendar_month_rounded,
            label: 'Due date',
            value: _fmtDate(task.dueDate),
          ),
          _detailTile(
            icon: Icons.bolt_rounded,
            label: 'Priority',
            value: task.priority,
            valueColor: _priorityColor(task.priority),
          ),
          if (_canUpdateStatus && !task.isApproved)
            _statusEditor(task)
          else
            _detailTile(
              icon: Icons.flag_rounded,
              label: 'Status',
              value: task.status.replaceAll('_', ' '),
              valueColor: _statusColor(task.status),
            ),
          _detailTile(
            icon: Icons.person_outline_rounded,
            label: 'Assignee',
            value: task.assignedToName ?? '—',
          ),
          _detailTile(
            icon: Icons.person_add_alt_1_rounded,
            label: 'Assigned by',
            value: task.assignedByName ?? '—',
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _card({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderPurple),
        boxShadow: [
          BoxShadow(
            color: _purple.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _purpleLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _borderPurple),
                ),
                child: Icon(icon, size: 18, color: _purple),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _approvedBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline_rounded, color: Color(0xFFB45309), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'This task is approved and cannot be edited.',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFB45309),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: _labelMuted,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _detailTile({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 18, color: _purple),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _labelMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: valueColor ?? _textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, color: _border),
      ],
    );
  }

  Widget _statusEditor(CrmTask task) {
    final current = _statuses.contains(task.status) ? task.status : 'PENDING';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1, color: _border),
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 8),
          child: _label('Status'),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: _fieldBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: current,
              isExpanded: true,
              icon: const Icon(Icons.unfold_more_rounded, size: 20, color: _textMuted),
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
              items: _statuses.map((s) {
                return DropdownMenuItem(
                  value: s,
                  child: Text(s.replaceAll('_', ' ')),
                );
              }).toList(),
              onChanged: _updatingStatus
                  ? null
                  : (v) {
                      if (v != null) _onStatusChanged(v);
                    },
            ),
          ),
        ),
      ],
    );
  }

  String _fmtDate(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    try {
      return DateFormat('EEE, MMM dd, yyyy').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }
}
