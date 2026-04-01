import 'package:dio/dio.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:my_app/dashboards/presentations/bloc/audience_bloc.dart';
import 'package:my_app/dashboards/presentations/bloc/post_bloc.dart';
import 'package:my_app/dashboards/presentations/bloc/post_event.dart';
import 'package:my_app/dashboards/presentations/bloc/post_state.dart';

class SharedItemsScreen extends StatefulWidget {
  const SharedItemsScreen({super.key});

  @override
  State<SharedItemsScreen> createState() => _SharedItemsScreenState();
}

class _SharedItemsScreenState extends State<SharedItemsScreen> {
  final _titleCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _allUsers = true;
  final List<MultipartFile> _attachments = <MultipartFile>[];
  String? _fileError;

  Future<void> _addPickedPlatformFiles(List<PlatformFile> files) async {
    final next = <MultipartFile>[];
    for (final f in files) {
      final bytes = f.bytes;
      // On web, `PlatformFile.path` throws (not available). Only use bytes there.
      final String? path = kIsWeb ? null : f.path;
      final size = f.size;
      if (size > 20 * 1024 * 1024) {
        setState(() => _fileError = 'Each file must be <= 20MB');
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
    final contentParts = <String>[];
    final desc = _descCtrl.text.trim();
    if (desc.isNotEmpty) contentParts.add(desc);

    final content = contentParts.join('\n\n');
    if (content.isEmpty && link.isEmpty && _attachments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a link/description or attach a file')),
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
            category: 'shared',
            attachments: List<MultipartFile>.from(_attachments),
            isAllUsers: _allUsers,
            userIds: targeting.userIds,
            departmentIds: targeting.departmentIds,
            designationIds: targeting.designationIds,
            // Backend does not expose `/publish/` endpoint; publish on create if needed.
            publishAfterCreate: false,
          ),
        );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _linkCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
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
            const SnackBar(content: Text('Post submitted successfully')),
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
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: media.size.height - 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Shared Items',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Make work more productive in creation',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Title',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _Field(
                            controller: _titleCtrl,
                            hintText: 'Title (optional)',
                            maxLines: 1,
                          ),
                          const SizedBox(height: 14),
                          _DropZone(
                            onTap: _pickFiles,
                            hasFiles: _attachments.isNotEmpty,
                            displayText: _attachments.isEmpty
                                ? null
                                : _attachments.length == 1
                                    ? (_attachments.first.filename ?? '1 file selected')
                                    : '${_attachments.first.filename ?? 'File'} (+${_attachments.length - 1} more)',
                            onDropped: (files) async {
                              setState(() => _fileError = null);
                              await _addPickedPlatformFiles(files);
                            },
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
                                    onRemove: () => setState(
                                      () => _attachments.removeAt(i),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 16),
                          const Text(
                            'Share Links',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _Field(
                            controller: _linkCtrl,
                            hintText: 'Share Links',
                            maxLines: 1,
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _Field(
                            controller: _descCtrl,
                            hintText: 'Description',
                            maxLines: 4,
                          ),
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
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: BlocBuilder<PostBloc, PostState>(
                              builder: (context, state) {
                                final busy = state is PostLoading;
                                return ElevatedButton(
                                  onPressed: busy ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF604EB8),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
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
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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

class _DropZone extends StatelessWidget {
  final VoidCallback onTap;
  final bool hasFiles;
  final String? displayText;
  final Future<void> Function(List<PlatformFile> files) onDropped;
  const _DropZone({
    required this.onTap,
    required this.hasFiles,
    required this.displayText,
    required this.onDropped,
  });

  @override
  Widget build(BuildContext context) {
    return _DropZoneBody(
      onTap: onTap,
      hasFiles: hasFiles,
      displayText: displayText,
      onDropped: onDropped,
    );
  }
}

class _DropZoneBody extends StatefulWidget {
  final VoidCallback onTap;
  final bool hasFiles;
  final String? displayText;
  final Future<void> Function(List<PlatformFile> files) onDropped;

  const _DropZoneBody({
    required this.onTap,
    required this.hasFiles,
    required this.displayText,
    required this.onDropped,
  });

  @override
  State<_DropZoneBody> createState() => _DropZoneBodyState();
}

class _DropZoneBodyState extends State<_DropZoneBody> {
  DropzoneViewController? _dz;
  bool _hovering = false;
  bool _webDragActive = false;

  Future<void> _pickFromWebDropzone() async {
    final dz = _dz;
    if (dz == null) return;
    final picked = await dz.pickFiles(multiple: true);
    if (!mounted) return;
    if (picked.isEmpty) return;
    await _handleDrop(picked);
  }

  Future<void> _handleDrop(dynamic event) async {
    final dz = _dz;
    if (dz == null) return;

    final List<dynamic> events = event is List ? event : [event];
    final files = <PlatformFile>[];

    for (final e in events) {
      final name = await dz.getFilename(e);
      final size = await dz.getFileSize(e);
      final data = await dz.getFileData(e); // Uint8List
      files.add(PlatformFile(
        name: name,
        size: size,
        bytes: data,
      ));
    }

    if (!mounted) return;
    await widget.onDropped(files);
  }

  Future<void> _handleDesktopDrop(DropDoneDetails details) async {
    final files = <PlatformFile>[];
    for (final xf in details.files) {
      // desktop_drop gives XFile with a path
      final name = xf.name;
      final path = xf.path;
      try {
        final len = await xf.length();
        if (path.isNotEmpty) {
          files.add(
            PlatformFile(
              name: name,
              size: len,
              path: path,
            ),
          );
        } else {
          // Some desktop platforms can provide an empty path; fall back to bytes.
          final bytes = await xf.readAsBytes();
          files.add(
            PlatformFile(
              name: name,
              size: bytes.length,
              bytes: bytes,
            ),
          );
        }
      } catch (_) {
        // Ignore unreadable files.
      }
    }
    if (!mounted) return;
    await widget.onDropped(files);
  }

  @override
  Widget build(BuildContext context) {
    final borderColor =
        _hovering ? const Color(0xFF604EB8) : const Color(0xFF8A79E5);
    final bg = _hovering
        ? const Color(0xFF7C6DE6).withValues(alpha: 0.18)
        : const Color(0xFF7C6DE6).withValues(alpha: 0.12);

    return DropTarget(
      enable: !kIsWeb,
      onDragEntered: (_) => setState(() => _hovering = true),
      onDragExited: (_) => setState(() => _hovering = false),
      onDragDone: (details) async {
        setState(() => _hovering = false);
        await _handleDesktopDrop(details);
      },
      child: Stack(
        children: [
          // Web drop surface at the bottom. When dragging, we temporarily route
          // pointer events to it by ignoring the UI layer above.
          if (kIsWeb)
            Positioned.fill(
              child: DropzoneView(
                onCreated: (c) {
                  _dz = c;
                },
                onHover: () => setState(() {
                  _hovering = true;
                  _webDragActive = true;
                }),
                onLeave: () => setState(() {
                  _hovering = false;
                  _webDragActive = false;
                }),
                onDropFile: (ev) async {
                  setState(() {
                    _hovering = false;
                    _webDragActive = false;
                  });
                  final messenger = ScaffoldMessenger.of(context);
                  await _handleDrop(ev);
                  if (!mounted) return;
                  messenger.showSnackBar(
                    const SnackBar(content: Text('File added')),
                  );
                },
                onDropFiles: (evs) async {
                  setState(() {
                    _hovering = false;
                    _webDragActive = false;
                  });
                  final messenger = ScaffoldMessenger.of(context);
                  await _handleDrop(evs);
                  if (!mounted) return;
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Files added')),
                  );
                },
              ),
            ),

          // UI layer: clickable most of the time. While a drag is hovering on
          // web, ignore pointer events so DropzoneView can receive the drop.
          IgnorePointer(
            ignoring: kIsWeb && _webDragActive,
            child: InkWell(
              onTap: () async {
                if (kIsWeb) {
                  await _pickFromWebDropzone();
                } else {
                  widget.onTap();
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: borderColor, width: 2),
                    gradient: LinearGradient(
                      colors: [
                        bg,
                        Colors.white.withValues(alpha: 0.10),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.upload_rounded,
                        size: 34,
                        color: const Color(0xFF604EB8).withValues(alpha: 0.85),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.hasFiles
                            ? (widget.displayText ?? 'Files selected')
                            : 'Drag & drop files here',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'or click to browse',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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
    required this.maxLines,
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