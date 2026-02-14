import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MediaPickerCard extends StatelessWidget {
  final String title;
  final String? url;
  final ValueChanged<String> onUploaded;

  const MediaPickerCard({
    super.key,
    required this.title,
    required this.url,
    required this.onUploaded,
  });

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked != null) {
      onUploaded(picked.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),


          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: url == null || url!.isEmpty
                ? const Icon(
              Icons.add_a_photo_outlined,
              color: Colors.grey,
            )
                : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: url!.startsWith("http")
                  ? Image.network(
                url!,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) {
                  return const Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.grey,
                  );
                },
              )
                  : Image.file(
                File(url!),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) {
                  return const Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.grey,
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 8),

          TextButton(
            onPressed: _pickImage,
            child: const Text(
              "Change",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


