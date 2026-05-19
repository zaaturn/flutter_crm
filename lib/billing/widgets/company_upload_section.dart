import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final wide = MediaQuery.sizeOf(context).width >= 840;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (wide) ...[
          const SectionHeader(
            title: "Brand Assets",
            subtitle: "Company logo and digital signature for invoices.",
          ),
          const SizedBox(height: 16),
        ] else ...[
          Text(
            "BRAND ASSETS",
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: const Color(0xFFB14D1E),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: MediaPickerCard(
                title: "Company Logo",
                url: logoUrl,
                helperText: "PNG, JPG up to 5MB",
                onUploaded: onLogoChanged,
                // Adaptive Styling
                decoration: wide
                    ? null
                    : BoxDecoration(
                  color: const Color(0xFFF5E6DA),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFB14D1E).withOpacity(0.1)),
                ),
              ),
            ),
             SizedBox(width: wide ? 16 : 12),
            Expanded(
              child: MediaPickerCard(
                title: "Digital Signature",
                url: signatureUrl,
                helperText: "Transparent file",
                onUploaded: onSignatureChanged,
                decoration: wide
                    ? null
                    : BoxDecoration(
                  color: const Color(0xFFF5E6DA),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFB14D1E).withOpacity(0.1)),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: wide ? 32 : 16),
      ],
    );
  }
}