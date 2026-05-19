import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/dashboards/presentations/bloc/audience_bloc.dart';
import 'package:my_app/dashboards/presentations/bloc/audience_state.dart';
import 'package:my_app/dashboards/presentations/bloc/post_bloc.dart';
import 'package:my_app/dashboards/presentations/bloc/post_event.dart';
import 'package:my_app/dashboards/presentations/bloc/post_state.dart';

import '../widget/mobile_audience_picker_sheet.dart';
import '../widget/share_mobile_top_bar.dart';

class SharedItemsMobileScreen extends StatefulWidget {
  const SharedItemsMobileScreen({super.key});

  @override
  State<SharedItemsMobileScreen> createState() => _SharedItemsMobileScreenState();
}

class _SharedItemsMobileScreenState extends State<SharedItemsMobileScreen> {
  static const Color _bgScreen = Color(0xFFFEF7F1);
  static const Color _boxFill = Color(0xFFF5E6DA);
  static const Color _accentColor = Color(0xFFB14D1E);
  static const Color _btnColor = Color(0xFF8D5B39);

  final _titleCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final List<MultipartFile> _attachments = <MultipartFile>[];
  String? _fileError;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _linkCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _addPickedPlatformFiles(List<PlatformFile> files) async {
    final next = <MultipartFile>[];
    for (final f in files) {
      final bytes = f.bytes;
      final String? path = kIsWeb ? null : f.path;
      if (f.size > 50 * 1024 * 1024) {
        setState(() => _fileError = 'Each file must be <= 50MB');
        continue;
      }
      if (bytes == null && (path == null || path.isEmpty)) continue;
      final mf = bytes != null
          ? MultipartFile.fromBytes(bytes, filename: f.name)
          : await MultipartFile.fromFile(path!, filename: f.name);
      next.add(mf);
    }
    if (!mounted) return;
    setState(() => _attachments.addAll(next));
  }

  Future<void> _pickFiles() async {
    setState(() => _fileError = null);
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) return;
    await _addPickedPlatformFiles(result.files);
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    final link = _linkCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    final content = desc;

    if (content.isEmpty && link.isEmpty && _attachments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a link/description or attach a file')),
      );
      return;
    }

    final audience = context.read<AudienceBloc>().resolveCreatePostTargeting();
    final isAllUsers = context.read<AudienceBloc>().state.totalSelectedCount == 0;

    context.read<PostBloc>().add(
      CreatePostEvent(
        title: title.isEmpty ? null : title,
        link: link.isEmpty ? null : link,
        content: content,
        category: 'shared',
        attachments: List<MultipartFile>.from(_attachments),
        isAllUsers: isAllUsers,
        userIds: isAllUsers ? const [] : audience.userIds,
        departmentIds: isAllUsers ? const [] : audience.departmentIds,
        designationIds: isAllUsers ? const [] : audience.designationIds,
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
          _linkCtrl.clear();
          _descCtrl.clear();
          setState(() {
            _attachments.clear();
            _fileError = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Shared item submitted')),
          );
        }
        if (state is PostError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: _bgScreen,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              ShareMobileTopBar(
                title: 'Shared Items',
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    20,
                    16,
                    20,
                    24 + MediaQuery.paddingOf(context).bottom + 110,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _Label('ITEM TITLE'),
                      const SizedBox(height: 8),
                      _Field(
                        controller: _titleCtrl,
                        fillColor: _boxFill,
                      ),
                      const SizedBox(height: 16),
                      _UploadCard(
                        onTap: _pickFiles,
                        hasFiles: _attachments.isNotEmpty,
                        fileCount: _attachments.length,
                        cardColor: _boxFill,
                        accentColor: _accentColor,
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
                                chipColor: _boxFill,
                                accentColor: _accentColor,
                                onRemove: () => setState(
                                      () => _attachments.removeAt(i),
                                ),
                              ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 20),
                      const _Label('SHARE LINKS'),
                      const SizedBox(height: 8),
                      _Field(
                        controller: _linkCtrl,
                        prefixIcon: Icons.link_rounded,
                        fillColor: _boxFill,
                      ),
                      const SizedBox(height: 20),
                      const _Label('DESCRIPTION'),
                      const SizedBox(height: 8),
                      _Field(
                        controller: _descCtrl,
                        maxLines: 5,
                        fillColor: _boxFill,
                      ),
                      const SizedBox(height: 20),
                      const _Label('TARGET AUDIENCE'),
                      const SizedBox(height: 10),
                      const MobileAudiencePickers(),
                      const SizedBox(height: 10),
                      BlocBuilder<AudienceBloc, AudienceState>(
                        builder: (context, state) {
                          final count = state.totalSelectedCount;
                          final text = count == 0 ? 'All users' : '$count selected';
                          return Text(
                            text,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF1A1C1E).withOpacity(0.6),
                              fontWeight: FontWeight.w700,
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
        bottomNavigationBar: _SubmitBar(
          label: 'Submit Shared Item',
          onPressed: _submit,
            btnColor: _btnColor
        ),
      ),
    );
  }
}

class _SubmitBar extends StatelessWidget {
  const _SubmitBar({required this.label, required this.onPressed,required this.btnColor});

  final String label;
  final VoidCallback onPressed;
  final Color btnColor;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: btnColor,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ),
      ),
    );
  }
}

class _UploadCard extends StatelessWidget {
  const _UploadCard({
    required this.onTap,
    required this.hasFiles,
    required this.fileCount,
    required this.cardColor,
    required this.accentColor,
  });

  final VoidCallback onTap;
  final bool hasFiles;
  final int fileCount;
  final Color cardColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: accentColor.withOpacity(0.12), width: 1.2),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_upload_outlined,
                color: accentColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              hasFiles ? '$fileCount file(s) selected' : 'Upload Resource',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A1C1E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'PDF, JPG or Assets up to 50MB',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1C1E).withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FileChip extends StatelessWidget {
  const _FileChip({
    required this.label,
    required this.onRemove,
    required this.chipColor,
    required this.accentColor
  });

  final String label;
  final VoidCallback onRemove;
  final Color chipColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.description_outlined, size: 16, color: accentColor),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1C1E),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF1A1C1E)),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
        color: const Color(0xFF1A1C1E).withOpacity(0.6),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.fillColor,
    this.maxLines = 1,
    this.prefixIcon,
  });

  final TextEditingController controller;
  final Color fillColor;
  final int maxLines;
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1A1C1E)),
      decoration: InputDecoration(
        hintText: '',
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, color: const Color(0xFFB14D1E).withOpacity(0.6), size: 20),
        filled: true,
        fillColor: fillColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: const Color(0xFFB14D1E).withOpacity(0.08), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: const Color(0xFFB14D1E).withOpacity(0.2), width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(18),
      ),
    );
  }
}