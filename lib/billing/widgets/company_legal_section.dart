import 'package:flutter/material.dart';
import 'section_header.dart';
import 'group_card.dart';
import 'modern_text_field.dart';

class CompanyLegalSection extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController gstCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController phoneCtrl;

  const CompanyLegalSection({
    super.key,
    required this.nameCtrl,
    required this.gstCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: "Legal Information",
          subtitle: "Official details for billing documents",
        ),
        const SizedBox(height: 16),
        GroupCard(children: [
          ModernTextField(
            label: "Company Legal Name",
            controller: nameCtrl,
            required: true,
          ),
          ModernTextField(label: "GST Number", controller: gstCtrl),
          ModernTextField(
            label: "Support Email",
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
          ),
          ModernTextField(
            label: "Phone Number",
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
          ),
        ]),
        const SizedBox(height: 32),
      ],
    );
  }
}
