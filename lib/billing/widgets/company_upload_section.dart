import 'package:flutter/material.dart';
import 'section_header.dart';
import 'media_picker_card.dart';

class CompanyUploadsSection extends StatelessWidget {
  final String? logoUrl;
  final String? signatureUrl;
  final ValueChanged<String> onLogoChanged;
  final ValueChanged<String> onSignatureChanged;

  const CompanyUploadsSection({
    super.key,
    required this.logoUrl,
    required this.signatureUrl,
    required this.onLogoChanged,
    required this.onSignatureChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: "Uploads",
          subtitle: "Manage your company logo and digital signature",
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: MediaPickerCard(
                title: "Company Logo",
                url: logoUrl,
                onUploaded: onLogoChanged,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MediaPickerCard(
                title: "Digital Signature",
                url: signatureUrl,
                onUploaded: onSignatureChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
