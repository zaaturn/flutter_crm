import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'section_header.dart';
import 'media_picker_card.dart';

class CompanyUploadsSection extends StatelessWidget {
  final String? logoUrl;
  final String? signatureUrl;
  final ValueChanged<XFile> onLogoChanged;
  final ValueChanged<XFile> onSignatureChanged;

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
          title: "Brand Assets",
          subtitle: "Company logo and digital signature for invoices.",
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: MediaPickerCard(
                title: "Company Logo",
                url: logoUrl,
                helperText: "PNG, JPG up to 5MB",
                onUploaded: onLogoChanged,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MediaPickerCard(
                title: "Digital Signature",
                url: signatureUrl,
                helperText: "Transparent signature file",
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
