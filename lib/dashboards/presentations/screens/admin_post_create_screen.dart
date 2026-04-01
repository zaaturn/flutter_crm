import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_app/dashboards/presentations/bloc/audience_bloc.dart';
import 'package:my_app/dashboards/presentations/bloc/post_bloc.dart';
import 'package:my_app/dashboards/presentations/bloc/post_event.dart';
import 'package:my_app/dashboards/presentations/screens/admin_posts_manager_screen.dart';
import 'package:my_app/dashboards/widgets/app_color.dart';

class AdminPostCreateScreen extends StatefulWidget {
  final String category;
  final String title;

  const AdminPostCreateScreen({
    super.key,
    required this.category,
    required this.title,
  });

  @override
  State<AdminPostCreateScreen> createState() => _AdminPostCreateScreenState();
}

class _AdminPostCreateScreenState extends State<AdminPostCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  bool _isAllUsers = false;
  bool _publishNow = true;
  final List<MultipartFile> _attachments = [];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: const [
        'jpg',
        'jpeg',
        'png',
        'pdf',
        'mp4',
        'mov',
        'avi',
        'doc',
        'docx',
        'xls',
        'xlsx',
        'ppt',
        'pptx',
      ],
    );
    if (result == null) return;

    final next = <MultipartFile>[];
    for (final f in result.files) {
      final bytes = f.bytes;
      if (bytes == null) continue;
      // 20MB limit
      if (bytes.length > 20 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${f.name} exceeds 20MB limit')),
        );
        continue;
      }
      next.add(MultipartFile.fromBytes(bytes, filename: f.name));
    }

    setState(() => _attachments.addAll(next));
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final audienceBloc = context.read<AudienceBloc>();
    var departmentIds = <int>[];
    var designationIds = <int>[];
    var userIds = <int>[];
    if (!_isAllUsers) {
      final t = audienceBloc.resolveCreatePostTargeting();
      departmentIds = t.departmentIds;
      designationIds = t.designationIds;
      userIds = t.userIds;
    }

    context.read<PostBloc>().add(
          CreatePostEvent(
            title: _titleCtrl.text.trim().isEmpty ? null : _titleCtrl.text.trim(),
            content: _contentCtrl.text.trim(),
            category: widget.category,
            attachments: _attachments,
            isAllUsers: _isAllUsers,
            departmentIds: departmentIds,
            designationIds: designationIds,
            userIds: userIds,
            publishAfterCreate: _publishNow,
          ),
        );

    Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute<void>(
        builder: (_) =>
            AdminPostsManagerScreen(initialCategory: widget.category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _toggleRow(
                label: 'Send to all users',
                value: _isAllUsers,
                onChanged: (v) => setState(() => _isAllUsers = v),
              ),
              const SizedBox(height: 8),
              _toggleRow(
                label: 'Publish immediately',
                value: _publishNow,
                onChanged: (v) => setState(() => _publishNow = v),
              ),
              const SizedBox(height: 16),
              _label('TITLE (optional)'),
              const SizedBox(height: 8),
              _field(
                controller: _titleCtrl,
                hint: 'Title...',
                maxLines: 1,
                validator: (_) => null,
              ),
              const SizedBox(height: 14),
              _label('CONTENT'),
              const SizedBox(height: 8),
              _field(
                controller: _contentCtrl,
                hint: 'Write something...',
                maxLines: 8,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Content required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'Attachments',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _pickFiles,
                    icon: const Icon(Icons.attach_file_rounded, size: 18),
                    label: const Text('Add files'),
                  ),
                ],
              ),
              if (_attachments.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final a in _attachments)
                      Chip(
                        label: Text(a.filename ?? 'file'),
                        onDeleted: () => setState(() => _attachments.remove(a)),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 18),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isAllUsers ? Icons.public_rounded : Icons.group_rounded,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _isAllUsers
                            ? 'This will be sent to all users.'
                            : 'Use the Target Audience panel to pick departments, designations, or users.',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Text(
                    'Create',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  label: const Icon(Icons.arrow_forward_rounded, size: 18),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cyan,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toggleRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.cyan,
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: AppColors.textMuted,
          letterSpacing: 1.1,
        ),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required int maxLines,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cyan, width: 1.5),
        ),
      ),
    );
  }
}

