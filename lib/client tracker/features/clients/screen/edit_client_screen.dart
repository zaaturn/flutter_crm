import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/client_bloc.dart';
import '../bloc/client_event.dart';
import 'package:my_app/client tracker/features/clients/models/client_model.dart';
import 'package:my_app/client tracker/core/constants/crm_widget.dart';
import 'package:my_app/client tracker/core/constants/app_theme.dart';
import 'package:my_app/client tracker/core/constants/app_constant.dart';

class EditClientScreen extends StatefulWidget {
  final ClientModel client;
  const EditClientScreen({super.key, required this.client});

  @override
  State<EditClientScreen> createState() => _EditClientScreenState();
}

class _EditClientScreenState extends State<EditClientScreen> {
  late TextEditingController name;
  late TextEditingController phone;
  late TextEditingController email;
  late TextEditingController address;
  late TextEditingController about;
  late TextEditingController services;

  @override
  void initState() {
    super.initState();

    name = TextEditingController(text: widget.client.name ?? '');
    phone = TextEditingController(text: widget.client.phone ?? '');
    email = TextEditingController(text: widget.client.email ?? '');
    address = TextEditingController(text: widget.client.address ?? '');
    about = TextEditingController(text: widget.client.about ?? '');

    // Admin can type new services separated by comma
    services = TextEditingController();
  }

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    email.dispose();
    address.dispose();
    about.dispose();
    services.dispose();
    super.dispose();
  }

  void _save() {
    context.read<ClientBloc>().add(
      UpdateClientEvent(
        clientId: widget.client.id,
        clientData: {
          "name": name.text,
          "phone": phone.text,
          "email": email.text,
          "address": address.text,
          "about": about.text,
          "services": services.text, // FIXED KEY
        },
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Edit Client"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CrmButton(
              '← Back',
              style: BtnStyle.ghost,
              onTap: () => Navigator.pop(context),
            ),

            const SizedBox(height: 24),

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
                  Text(
                    "Client Details",
                    style: AppTextStyles.bodyMed.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 20),

                  CrmTextField(label: 'Full Name', controller: name),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: CrmTextField(
                          label: 'Phone',
                          controller: phone,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CrmTextField(
                          label: 'Email',
                          controller: email,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  CrmTextField(label: 'Address', controller: address),

                  const SizedBox(height: 16),

                  CrmTextField(
                    label: 'Add Services (comma separated)',
                    controller: services,
                  ),

                  const SizedBox(height: 16),

                  CrmTextField(label: 'About Client', controller: about),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: CrmButton(
                      'Update Client Info',
                      onTap: _save,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}