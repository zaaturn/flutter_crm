import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageUpload extends StatefulWidget {
  final ValueChanged<XFile> onUploaded;
  final void Function(VoidCallback openPicker)? onReady;

  const ImageUpload({
    super.key,
    required this.onUploaded,
    this.onReady,
  });

  @override
  State<ImageUpload> createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  Uint8List? _bytes;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() => _bytes = bytes);
    widget.onUploaded(picked);
  }

  @override
  void initState() {
    super.initState();
    widget.onReady?.call(_pickImage);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: SizedBox.expand(
        child: _bytes != null
            ? Image.memory(_bytes!, fit: BoxFit.cover)
            : const Center(
          child: Icon(Icons.camera_alt, size: 28, color: Colors.grey),
        ),
      ),
    );
  }
}

