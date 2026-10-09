import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/admin_settings/admin_palette.dart';
import 'package:my_app/admin_settings/data/holiday_admin_repository.dart';

/// Settings → Holidays.
///
/// A superadmin adds holidays one by one or imports a CSV (`date,name`).
/// Every date in this list is a day off: nobody gets the 1 PM check-in
/// reminder email on it. Other admins see the list read-only.
class HolidaysAdminScreen extends StatefulWidget {
  const HolidaysAdminScreen({super.key, required this.canEdit});

  final bool canEdit;

  @override
  State<HolidaysAdminScreen> createState() => _HolidaysAdminScreenState();
}

class _HolidaysAdminScreenState extends State<HolidaysAdminScreen> {
  final _repo = HolidayAdminRepository();
  int _year = DateTime.now().year;
  List<AdminHoliday> _holidays = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _repo.list(_year, manage: widget.canEdit);
      if (!mounted) return;
      setState(() {
        _holidays = list;
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

  void _changeYear(int delta) {
    setState(() => _year += delta);
    _load();
  }

  Future<void> _openEditor([AdminHoliday? holiday]) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _HolidayEditorDialog(repo: _repo, holiday: holiday, year: _year),
    );
    if (saved == true) {
      if (!mounted) return;
      showAdminSnack(context, holiday == null ? 'Holiday added' : 'Holiday updated');
      _load();
    }
  }

  Future<void> _delete(AdminHoliday holiday) async {
    final p = AdminPalette.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete holiday?'),
        content: Text(
          '${holiday.name} on ${DateFormat('d MMM yyyy').format(holiday.date)} will become a '
          'working day again, and check-in reminders will go out that day.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: p.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _repo.delete(holiday.id);
      if (!mounted) return;
      showAdminSnack(context, 'Holiday deleted');
      _load();
    } catch (e) {
      if (mounted) showAdminSnack(context, e.toString(), error: true);
    }
  }

  Future<void> _import() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv', 'txt'],
      withData: true,
    );
    final file = picked?.files.single;
    if (file == null) return;
    final bytes = file.bytes;
    if (bytes == null) {
      if (mounted) showAdminSnack(context, "Couldn't read that file.", error: true);
      return;
    }
    if (!mounted) return;
    final imported = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ImportPreviewDialog(
        repo: _repo,
        bytes: bytes,
        fileName: file.name,
      ),
    );
    if (imported == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final p = AdminPalette.of(context);
    return AdminSettingsScaffold(
      title: 'Holidays',
      actions: [
        if (widget.canEdit && p.wide) ...[
          TextButton.icon(
            onPressed: _import,
            icon: const Icon(Icons.upload_file_rounded),
            label: const Text('Import CSV'),
            style: TextButton.styleFrom(foregroundColor: p.primaryDark),
          ),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: () => _openEditor(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add holiday'),
              style: FilledButton.styleFrom(backgroundColor: p.primary),
            ),
          ),
        ],
        if (widget.canEdit && !p.wide)
          IconButton(
            tooltip: 'Import CSV',
            onPressed: _import,
            icon: const Icon(Icons.upload_file_rounded),
          ),
      ],
      floatingActionButton: widget.canEdit && !p.wide
          ? FloatingActionButton.extended(
              onPressed: () => _openEditor(),
              backgroundColor: p.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add holiday'),
            )
          : null,
      body: Column(
        children: [
          _Header(
            year: _year,
            count: _holidays.length,
            canEdit: widget.canEdit,
            onPrev: () => _changeYear(-1),
            onNext: () => _changeYear(1),
          ),
          if (_loading) LinearProgressIndicator(color: p.primary, backgroundColor: p.primaryLight),
          Expanded(child: _buildList(p)),
        ],
      ),
    );
  }

  Widget _buildList(AdminPalette p) {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: p.danger)),
            const SizedBox(height: 8),
            TextButton(onPressed: _load, child: const Text('Try again')),
          ],
        ),
      );
    }
    if (!_loading && _holidays.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.beach_access_rounded, size: 48, color: p.muted),
              const SizedBox(height: 12),
              Text(
                'No holidays for $_year yet',
                style: TextStyle(fontWeight: FontWeight.w800, color: p.text, fontSize: 16),
              ),
              if (widget.canEdit) ...[
                const SizedBox(height: 6),
                Text(
                  'Add them one by one, or import a CSV with date and name columns.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: p.muted),
                ),
              ],
            ],
          ),
        ),
      );
    }

    // Group by month so a year's list reads like a calendar.
    final byMonth = <int, List<AdminHoliday>>{};
    for (final h in _holidays) {
      byMonth.putIfAbsent(h.date.month, () => []).add(h);
    }
    final today = DateUtils.dateOnly(DateTime.now());
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 8, 16, p.wide ? 24 : 96),
      children: [
        for (final month in byMonth.keys) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
            child: Text(
              DateFormat('MMMM').format(DateTime(_year, month)).toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: p.primary,
              ),
            ),
          ),
          for (final h in byMonth[month]!)
            _HolidayTile(
              holiday: h,
              past: h.date.isBefore(today),
              canEdit: widget.canEdit,
              onEdit: () => _openEditor(h),
              onDelete: () => _delete(h),
            ),
        ],
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.year,
    required this.count,
    required this.canEdit,
    required this.onPrev,
    required this.onNext,
  });

  final int year;
  final int count;
  final bool canEdit;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final p = AdminPalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onPrev,
                icon: const Icon(Icons.chevron_left_rounded),
                tooltip: 'Previous year',
              ),
              Text(
                '$year',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: p.text),
              ),
              IconButton(
                onPressed: onNext,
                icon: const Icon(Icons.chevron_right_rounded),
                tooltip: 'Next year',
              ),
              const Spacer(),
              Text(
                '$count holiday${count == 1 ? '' : 's'}',
                style: TextStyle(color: p.muted, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: p.primaryLight.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.mark_email_unread_outlined, size: 18, color: p.primaryDark),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    canEdit
                        ? 'On these days nobody gets the check-in reminder email. '
                            'Sundays are already skipped.'
                        : 'Office holidays. Only a super admin can change this list.',
                    style: TextStyle(color: p.primaryDark, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HolidayTile extends StatelessWidget {
  const _HolidayTile({
    required this.holiday,
    required this.past,
    required this.canEdit,
    required this.onEdit,
    required this.onDelete,
  });

  final AdminHoliday holiday;
  final bool past;
  final bool canEdit;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final p = AdminPalette.of(context);
    return Opacity(
      opacity: past ? 0.55 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: p.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: p.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    '${holiday.date.day}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: p.primaryDark,
                    ),
                  ),
                  Text(
                    DateFormat('MMM').format(holiday.date),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: p.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    holiday.name,
                    style: TextStyle(fontWeight: FontWeight.w800, color: p.text, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      DateFormat('EEEE').format(holiday.date),
                      if (holiday.localName.isNotEmpty) holiday.localName,
                    ].join(' · '),
                    style: TextStyle(color: p.muted, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            if (canEdit) ...[
              IconButton(
                tooltip: 'Edit',
                onPressed: onEdit,
                icon: Icon(Icons.edit_outlined, color: p.muted, size: 20),
              ),
              IconButton(
                tooltip: 'Delete',
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline_rounded, color: p.danger, size: 20),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HolidayEditorDialog extends StatefulWidget {
  const _HolidayEditorDialog({required this.repo, required this.year, this.holiday});

  final HolidayAdminRepository repo;
  final int year;
  final AdminHoliday? holiday;

  @override
  State<_HolidayEditorDialog> createState() => _HolidayEditorDialogState();
}

class _HolidayEditorDialogState extends State<_HolidayEditorDialog> {
  late final TextEditingController _name =
      TextEditingController(text: widget.holiday?.name ?? '');
  late final TextEditingController _local =
      TextEditingController(text: widget.holiday?.localName ?? '');
  DateTime? _date;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _date = widget.holiday?.date;
  }

  @override
  void dispose() {
    _name.dispose();
    _local.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _date ??
        (widget.year == now.year ? now : DateTime(widget.year, 1, 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5, 12, 31),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (_date == null) return setState(() => _error = 'Pick the date.');
    if (_name.text.trim().isEmpty) return setState(() => _error = 'Enter the holiday name.');
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final existing = widget.holiday;
      if (existing == null) {
        await widget.repo.create(_date!, _name.text, localName: _local.text);
      } else {
        await widget.repo.update(
          existing.id,
          date: _date,
          name: _name.text,
          localName: _local.text,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = AdminPalette.of(context);
    return AlertDialog(
      title: Text(widget.holiday == null ? 'Add holiday' : 'Edit holiday'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: p.input('Date', suffix: const Icon(Icons.calendar_month_rounded)),
                child: Text(
                  _date == null ? 'Select a date' : DateFormat('EEE, d MMM yyyy').format(_date!),
                  style: TextStyle(color: _date == null ? p.muted : p.text),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              maxLength: 255,
              textCapitalization: TextCapitalization.words,
              decoration: p.input('Name', hint: 'e.g. Diwali'),
            ),
            TextField(
              controller: _local,
              maxLength: 255,
              decoration: p.input('Local name (optional)', hint: 'e.g. ದೀಪಾವಳಿ'),
            ),
            if (_error != null)
              Text(_error!, style: TextStyle(color: p.danger, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          style: FilledButton.styleFrom(backgroundColor: p.primary),
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}

/// Uploads the file as a dry run first, shows what would change and which
/// rows have problems, and only saves when the superadmin confirms.
class _ImportPreviewDialog extends StatefulWidget {
  const _ImportPreviewDialog({
    required this.repo,
    required this.bytes,
    required this.fileName,
  });

  final HolidayAdminRepository repo;
  final Uint8List bytes;
  final String fileName;

  @override
  State<_ImportPreviewDialog> createState() => _ImportPreviewDialogState();
}

class _ImportPreviewDialogState extends State<_ImportPreviewDialog> {
  HolidayImportResult? _preview;
  bool _replaceYears = false;
  bool _busy = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _runPreview();
  }

  Future<void> _runPreview() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await widget.repo.importCsv(
        widget.bytes,
        widget.fileName,
        dryRun: true,
        replaceYears: _replaceYears,
      );
      if (mounted) {
        setState(() {
          _preview = result;
          _busy = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _busy = false;
        });
      }
    }
  }

  Future<void> _confirm() async {
    setState(() => _busy = true);
    try {
      final result = await widget.repo.importCsv(
        widget.bytes,
        widget.fileName,
        replaceYears: _replaceYears,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
      showAdminSnack(context, result.summary);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = AdminPalette.of(context);
    final preview = _preview;
    return AlertDialog(
      title: const Text('Import holidays'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.fileName, style: TextStyle(color: p.muted, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              if (_busy && preview == null)
                Center(child: CircularProgressIndicator(color: p.primary)),
              if (_error != null)
                Text(_error!, style: TextStyle(color: p.danger, fontWeight: FontWeight.w600)),
              if (preview != null) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _chip(p, '${preview.created} new'),
                    _chip(p, '${preview.updated} renamed'),
                    if (preview.removed > 0) _chip(p, '${preview.removed} removed', warn: true),
                    if (preview.errors.isNotEmpty)
                      _chip(p, '${preview.errors.length} skipped', warn: true),
                  ],
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: p.primary,
                  value: _replaceYears,
                  onChanged: _busy
                      ? null
                      : (v) {
                          setState(() => _replaceYears = v ?? false);
                          _runPreview();
                        },
                  title: const Text('Replace the whole list for these years'),
                  subtitle: const Text(
                    'Holidays in the same years that are not in this file get deleted.',
                  ),
                ),
                if (preview.errors.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('Rows that will be skipped',
                      style: TextStyle(fontWeight: FontWeight.w800, color: p.text)),
                  for (final e in preview.errors.take(20))
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('Line ${e.line}: ${e.error}',
                          style: TextStyle(color: p.danger, fontSize: 13)),
                    ),
                ],
                const SizedBox(height: 12),
                Text('Holidays in the file',
                    style: TextStyle(fontWeight: FontWeight.w800, color: p.text)),
                for (final h in preview.holidays.take(60))
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${DateFormat('d MMM yyyy').format(h.date)} — ${h.name}',
                      style: TextStyle(color: p.text, fontSize: 13),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _busy || preview == null || preview.validRows == 0 ? null : _confirm,
          style: FilledButton.styleFrom(backgroundColor: p.primary),
          child: Text(preview == null ? 'Import' : 'Import ${preview.validRows}'),
        ),
      ],
    );
  }

  Widget _chip(AdminPalette p, String text, {bool warn = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: warn ? p.danger.withValues(alpha: 0.1) : p.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 12,
          color: warn ? p.danger : p.primaryDark,
        ),
      ),
    );
  }
}
