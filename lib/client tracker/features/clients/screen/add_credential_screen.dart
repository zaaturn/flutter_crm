import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/client_bloc.dart';
import '../bloc/client_event.dart';
import 'package:my_app/client tracker/core/constants/crm_widget.dart';
import 'package:my_app/client tracker/core/constants/app_theme.dart';
import 'package:my_app/client tracker/features/clients/models/client_platform_choices.dart';
import 'package:my_app/leave_management/screens/mobile_screen/widget/leave_manager_colors.dart';

class AddCredentialScreen extends StatefulWidget {
  final int clientId;

  const AddCredentialScreen({super.key, required this.clientId});

  @override
  State<AddCredentialScreen> createState() => _AddCredentialScreenState();
}

class _AddCredentialScreenState extends State<AddCredentialScreen> {
  String platform = "youtube";
  final username = TextEditingController();
  final password = TextEditingController();

  void _save() {
    if (username.text.isEmpty || password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    context.read<ClientBloc>().add(
      AddClientCredentialsEvent(
        clientId: widget.clientId,
        credentials: [
          {
            "client": widget.clientId,
            "platform": platform,
            "username": username.text,
            "password": password.text
          }
        ],
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 900;
    final scaffold = Scaffold(
      backgroundColor:
          narrow ? LeaveManagerColors.background : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Add New Credential',
          style: AppTextStyles.subheading.copyWith(
            color: narrow ? LeaveManagerColors.primary : AppColors.text,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: narrow ? LeaveManagerColors.primary : Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(kRadius),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Switched 'h3' to 'bodyMed' with bold weight to avoid the error
                  Text(
                    "Credential Details",
                    style: AppTextStyles.bodyMed.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 20),

                  CrmDropdown<String>(
                    label: "Select Platform",
                    value: platform,
                    items: ClientPlatformChoices.entries.map((choice) {
                      return DropdownMenuItem(
                        value: choice['value']!,
                        child: Text(choice['label']!),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => platform = v!),
                  ),

                  const SizedBox(height: 16),

                  // Removed hintText as your CrmTextField doesn't seem to support it
                  CrmTextField(
                    label: "Username / Email",
                    controller: username,
                  ),

                  const SizedBox(height: 16),

                  // Removed hintText and isPassword as they are not defined in your widget
                  CrmTextField(
                    label: "Password",
                    controller: password,
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: CrmButton(
                      "Save Credential",
                      onTap: _save,
                      brandPrimary:
                          narrow ? LeaveManagerColors.primary : null,
                      brandPrimaryHover:
                          narrow ? LeaveManagerColors.primaryDark : null,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (!narrow) return scaffold;

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: LeaveManagerColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: LeaveManagerColors.background,
      ),
      child: scaffold,
    );
  }
}