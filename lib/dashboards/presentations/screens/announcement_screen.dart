import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:my_app/dashboards/presentations/bloc/audience_bloc.dart';
import 'package:my_app/dashboards/presentations/bloc/post_bloc.dart';
import 'package:my_app/dashboards/presentations/bloc/post_event.dart';
import 'package:my_app/dashboards/presentations/bloc/post_state.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() =>
      _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  bool _allUsers = true;
  final List<MultipartFile> _attachments = <MultipartFile>[];
  String? _fileError;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    setState(() => _fileError = null);
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) return;
    final next = <MultipartFile>[];
    for (final f in result.files) {
      if (f.size > 20 * 1024 * 1024) {
        setState(() => _fileError = 'Each file must be <= 20MB');
        continue;
      }
      final bytes = f.bytes;
      final String? path = kIsWeb ? null : f.path;
      if (bytes == null && (path == null || path.isEmpty)) continue;
      final mf = bytes != null
          ? MultipartFile.fromBytes(bytes, filename: f.name)
          : await MultipartFile.fromFile(path!, filename: f.name);
      next.add(mf);
    }
    if (!mounted) return;
    setState(() => _attachments.addAll(next));
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    final link = '';
    final content = _contentCtrl.text.trim();
    if (content.isEmpty && _attachments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message content is required')),
      );
      return;
    }
    final audienceBloc = context.read<AudienceBloc>();
    final targeting = audienceBloc.resolveCreatePostTargeting();
    context.read<PostBloc>().add(
          CreatePostEvent(
            title: title.isEmpty ? null : title,
            link: link.isEmpty ? null : link,
            content: content,
            category: 'announcement',
            attachments: List<MultipartFile>.from(_attachments),
            isAllUsers: _allUsers,
            userIds: _allUsers ? const [] : targeting.userIds,
            departmentIds: _allUsers ? const [] : targeting.departmentIds,
            designationIds: _allUsers ? const [] : targeting.designationIds,
            publishAfterCreate: false,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostBloc, PostState>(
      listenWhen: (_, s) => s is PostCreated || s is PostError,
      listener: (context, state) {
        if (state is PostCreated) {
          _titleCtrl.clear();
          _contentCtrl.clear();
          setState(() {
            _attachments.clear();
            _fileError = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Announcement published')),
          );
        }
        if (state is PostError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 18, 32, 32),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Create Announcement',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111827),
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Draft your message for the curated board.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 18),
                    const _Label('BROADCAST TITLE'),
                    const SizedBox(height: 8),
                    _Field(controller: _titleCtrl, hintText: 'Enter headline...'),
                    const SizedBox(height: 14),
                    const _Label('MESSAGE CONTENT'),
                    const SizedBox(height: 8),
                    _Toolbar(onAttach: _pickFiles),
                    const SizedBox(height: 10),
                    _Field(
                      controller: _contentCtrl,
                      hintText: 'Start typing your announcement...',
                      maxLines: 10,
                    ),
                    if (_fileError != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _fileError!,
                        style: const TextStyle(
                          color: Color(0xFFB91C1C),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    if (_attachments.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (int i = 0; i < _attachments.length; i++)
                            _FileChip(
                              label: _attachments[i].filename ?? 'File',
                              onRemove: () =>
                                  setState(() => _attachments.removeAt(i)),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Checkbox(
                          value: _allUsers,
                          activeColor: const Color(0xFF604EB8),
                          onChanged: (v) =>
                              setState(() => _allUsers = v ?? true),
                        ),
                        const Text(
                          'All Users',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    BlocBuilder<PostBloc, PostState>(
                      builder: (context, state) {
                        final busy = state is PostLoading;
                        return ElevatedButton(
                          onPressed: busy ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF604EB8),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 26,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: busy
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Submit',
                                  style: TextStyle(fontWeight: FontWeight.w900),
                                ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFF8A79E5), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        color: Color(0xFF6B7280),
        letterSpacing: 1.3,
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  final VoidCallback onAttach;
  const _Toolbar({required this.onAttach});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ToolButton(
          label: 'B',
          onTap: () {},
          bold: true,
        ),
        const SizedBox(width: 8),
        _ToolButton(
          label: 'I',
          onTap: () {},
          italic: true,
        ),
        const SizedBox(width: 8),
        _IconTool(icon: Icons.link, onTap: () {}),
        const SizedBox(width: 8),
        _IconTool(icon: Icons.image_outlined, onTap: onAttach),
      ],
    );
  }
}

class _ToolButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool bold;
  final bool italic;
  const _ToolButton({
    required this.label,
    required this.onTap,
    this.bold = false,
    this.italic = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
            fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ),
    );
  }
}

class _IconTool extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconTool({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF111827)),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  const _Field({
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.45),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8A79E5), width: 2),
        ),
      ),
    );
  }
}

class _FileChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _FileChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.insert_drive_file_outlined,
              size: 16, color: Color(0xFF604EB8)),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 16, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}