import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../theme/asset_theme.dart';

Future<bool> showAssetReturnConfirm(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(
        'Return asset?',
        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
      ),
      content: Text(
        'This will submit a return request for verification by an admin.',
        style: GoogleFonts.plusJakartaSans(fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Return'),
        ),
      ],
    ),
  );
  return result == true;
}

Future<String?> showAssetDamageDialog(BuildContext context) async {
  return showDialog<String>(
    context: context,
    builder: (ctx) => const _DamageReportDialog(),
  );
}

class _DamageReportDialog extends StatefulWidget {
  const _DamageReportDialog();

  @override
  State<_DamageReportDialog> createState() => _DamageReportDialogState();
}

class _DamageReportDialogState extends State<_DamageReportDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Report damage',
        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
      ),
      content: TextField(
        controller: _controller,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: 'Describe the damage…',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final text = _controller.text.trim();
            if (text.isEmpty) return;
            Navigator.pop(context, text);
          },
          style: FilledButton.styleFrom(
            backgroundColor: AssetMobileTheme.danger,
          ),
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

Future<({String purpose, String expectedReturnDate, String? notes})?>
    showAssetRequestSheet(BuildContext context) {
  return showModalBottomSheet<
      ({String purpose, String expectedReturnDate, String? notes})>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => const _AssetRequestSheet(),
  );
}

class _AssetRequestSheet extends StatefulWidget {
  const _AssetRequestSheet();

  @override
  State<_AssetRequestSheet> createState() => _AssetRequestSheetState();
}

class _AssetRequestSheetState extends State<_AssetRequestSheet> {
  final _purposeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? _returnDate;
  String? _dateError;

  @override
  void dispose() {
    _purposeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _returnDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (!mounted || picked == null) return;
    setState(() {
      _returnDate = picked;
      _dateError = null;
    });
  }

  void _submit() {
    final purposeOk = _formKey.currentState?.validate() ?? false;
    if (_returnDate == null) {
      setState(() => _dateError = 'Pick an expected return date');
      return;
    }
    if (!purposeOk) return;

    final notes = _notesCtrl.text.trim();
    Navigator.of(context).pop((
      purpose: _purposeCtrl.text.trim(),
      expectedReturnDate: DateFormat('yyyy-MM-dd').format(_returnDate!),
      notes: notes.isEmpty ? null : notes,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Request asset',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _purposeCtrl,
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Purpose is required' : null,
                decoration: const InputDecoration(
                  labelText: 'Purpose *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(
                  _returnDate == null
                      ? 'Expected return date *'
                      : DateFormat('yyyy-MM-dd').format(_returnDate!),
                ),
              ),
              if (_dateError != null) ...[
                const SizedBox(height: 6),
                Text(
                  _dateError!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _submit,
                child: const Text('Submit request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<String?> showCommentDialog(
  BuildContext context, {
  required String title,
  String hint = 'Optional comment',
}) {
  return showDialog<String>(
    context: context,
    builder: (ctx) => _CommentDialog(title: title, hint: hint),
  );
}

class _CommentDialog extends StatefulWidget {
  const _CommentDialog({required this.title, required this.hint});

  final String title;
  final String hint;

  @override
  State<_CommentDialog> createState() => _CommentDialogState();
}

class _CommentDialogState extends State<_CommentDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.title,
        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
      ),
      content: TextField(
        controller: _controller,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: widget.hint,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}

class AssetDeleteResult {
  const AssetDeleteResult({this.reason});
  final String? reason;
}

/// Confirm permanent delete of an asset from inventory.
Future<AssetDeleteResult?> showAssetDeleteDialog(
  BuildContext context, {
  required String assetName,
  required String assetCode,
}) {
  return showDialog<AssetDeleteResult>(
    context: context,
    builder: (ctx) => _AssetDeleteDialog(
      assetName: assetName,
      assetCode: assetCode,
    ),
  );
}

class _AssetDeleteDialog extends StatefulWidget {
  const _AssetDeleteDialog({
    required this.assetName,
    required this.assetCode,
  });

  final String assetName;
  final String assetCode;

  @override
  State<_AssetDeleteDialog> createState() => _AssetDeleteDialogState();
}

class _AssetDeleteDialogState extends State<_AssetDeleteDialog> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Delete asset?',
        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.assetName} (${widget.assetCode}) will be permanently deleted from inventory.',
            style: GoogleFonts.plusJakartaSans(fontSize: 14),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _reason,
            decoration: const InputDecoration(
              labelText: 'Reason (optional)',
              hintText: 'Optional note…',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AssetMobileTheme.danger,
          ),
          onPressed: () {
            Navigator.pop(
              context,
              AssetDeleteResult(
                reason:
                    _reason.text.trim().isEmpty ? null : _reason.text.trim(),
              ),
            );
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
