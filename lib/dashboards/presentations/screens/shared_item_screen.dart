import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/dashboards/presentations/bloc/post_bloc.dart';
import 'package:my_app/dashboards/presentations/bloc/post_event.dart';

class SharedItemsScreen extends StatefulWidget {
  const SharedItemsScreen({super.key});

  @override
  State<SharedItemsScreen> createState() => _SharedItemsScreenState();
}

class _SharedItemsScreenState extends State<SharedItemsScreen> {
  final _linkCtrl = TextEditingController();
  final _captionCtrl = TextEditingController();

  @override
  void dispose() {
    _linkCtrl.dispose();
    _captionCtrl.dispose();
    super.dispose();
  }

  void _onSend() {
    final link = _linkCtrl.text.trim();
    final caption = _captionCtrl.text.trim();

    if (link.isEmpty && caption.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add a link or caption")),
      );
      return;
    }

    context.read<PostBloc>().add(
      CreatePostEvent(
        title: caption,
        description: link,
        category: "shared",
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Shared item posted successfully")),
    );

    _linkCtrl.clear();
    _captionCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF3F6F8),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Share Item',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Upload media or share links to the employee dashboard.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 28),

            const _DropZone(),

            const SizedBox(height: 24),

            const _FieldLabel(label: 'SHARE LINKS'),
            const SizedBox(height: 8),

            _OutlinedTextField(
              controller: _linkCtrl,
              hintText: 'https://external-resource.com/item',
              prefixIcon: const Icon(
                Icons.link,
                color: Color(0xFF9CA3AF),
                size: 20,
              ),
            ),

            const SizedBox(height: 20),

            const _FieldLabel(label: 'CAPTION'),
            const SizedBox(height: 8),

            _OutlinedTextField(
              controller: _captionCtrl,
              hintText: 'Add a description or message for this item...',
              maxLines: 5,
            ),

            const SizedBox(height: 24),

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _onSend,
                icon: const Text(
                  'Send',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                label: const Icon(Icons.arrow_forward, size: 18),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BCD4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Color(0xFF1976D2),
                    size: 18,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Shared items will appear in the employee Boards section.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropZone extends StatefulWidget {
  const _DropZone();

  @override
  State<_DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<_DropZone> {
  bool _isDragOver = false;
  String? _selectedFile;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf', 'mp4', 'mov', 'avi'],
      withData: true,
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      setState(() {
        _selectedFile = file.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isDragOver = true),
      onExit: (_) => setState(() => _isDragOver = false),
      child: GestureDetector(
        onTap: _pickFile,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: _isDragOver
                ? const Color(0xFFE0F7FA)
                : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isDragOver
                  ? const Color(0xFF00BCD4)
                  : const Color(0xFFD1D5DB),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.upload_file_outlined,
                  size: 44, color: Colors.grey[400]),
              const SizedBox(height: 14),
              const Text(
                'Drop file here',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _selectedFile ??
                    'Supports JPG, PNG, PDF, MP4, MOV and AVI formats',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutlinedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Widget? prefixIcon;
  final int maxLines;

  const _OutlinedTextField({
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Color(0xFF374151),
      ),
    );
  }
}