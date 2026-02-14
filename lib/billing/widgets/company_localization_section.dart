import 'package:flutter/material.dart';
import 'section_header.dart';
import 'group_card.dart';
import 'modern_text_field.dart';
import 'currency_dropdown.dart';

class CompanyLocalizationSection extends StatelessWidget {
  final TextEditingController addressCtrl;
  final TextEditingController stateCtrl;
  final TextEditingController countryCtrl;
  final String currency;
  final ValueChanged<String> onCurrencyChanged;

  const CompanyLocalizationSection({
    super.key,
    required this.addressCtrl,
    required this.stateCtrl,
    required this.countryCtrl,
    required this.currency,
    required this.onCurrencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: "Localization",
          subtitle: "Business location and currency",
        ),
        const SizedBox(height: 16),
        GroupCard(children: [
          ModernTextField(
            label: "Registered Address",
            controller: addressCtrl,
            maxLines: 2,
          ),
          Row(
            children: [
              Expanded(
                child: ModernTextField(
                  label: "State",
                  controller: stateCtrl,
                  required: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ModernTextField(
                  label: "Country",
                  controller: countryCtrl,
                ),
              ),
            ],
          ),
          CurrencyDropdown(
            value: currency,
            onChanged: onCurrencyChanged,
          ),
        ]),
      ],
    );
  }
}
