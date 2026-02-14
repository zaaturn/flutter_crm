import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageUpload extends StatefulWidget {
  final Function(String url) onUploaded;
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
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() => _image = File(picked.path));

    // TEMP: local path (later replace with backend upload URL)
    widget.onUploaded(picked.path);
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
        child: _image != null
            ? Image.file(_image!, fit: BoxFit.cover)
            : const Center(
          child: Icon(Icons.camera_alt, size: 28, color: Colors.grey),
        ),
      ),
    );
  }
}

