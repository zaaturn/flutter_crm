import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/client_bloc.dart';
import '../bloc/client_event.dart';
import '../bloc/client_state.dart';
import 'package:my_app/client tracker/core/constants/app_theme.dart';
import 'package:my_app/client tracker/core/constants/crm_widget.dart';
import 'package:my_app/client tracker/features/clients/widget/service_input_widget.dart';
import 'package:my_app/client tracker/features/clients/widget/credential_input_list.dart';

class AddClientScreen extends StatefulWidget {
  const AddClientScreen({super.key});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _aboutCtrl   = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _emailCtrl   = TextEditingController();

  final List<String> _services = [];
  final List<Map<String, dynamic>> _credentials = [];

  @override
  void dispose() {
    for (final c in [_nameCtrl, _aboutCtrl, _addressCtrl, _phoneCtrl, _emailCtrl]) c.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ClientBloc>().add(SaveClientEvent(
      clientData: {
        'name':    _nameCtrl.text.trim(),
        'about':   _aboutCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'phone':   _phoneCtrl.text.trim(),
        'email':   _emailCtrl.text.trim(),
      },
      services:    List<String>.from(_services),
      credentials: List<Map<String, dynamic>>.from(_credentials),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ClientBloc, ClientState>(
      listener: (ctx, state) {
        if (state is ClientSaved) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
            content: Text('${state.client.name} saved!', style: AppTextStyles.body.copyWith(color: Colors.white)),
            backgroundColor: AppColors.accent,
          ));
        } else if (state is ClientError) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
            content: Text(state.message, style: AppTextStyles.body.copyWith(color: Colors.white)),
            backgroundColor: AppColors.danger,
          ));
        }
      },
      child: BlocBuilder<ClientBloc, ClientState>(
        builder: (ctx, state) {
          final loading = state is ClientLoading;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Form(
              key: _formKey,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  // ── Client Information ──
                  SectionCard(
                    title: 'Client Information',
                    titleIcon: _SectionIcon('👤', AppColors.primaryLight, AppColors.primary),
                    child: Column(children: [
                      Row(children: [
                        Expanded(child: CrmTextField(label: 'Client Name', hint: 'e.g. ABC Marketing Co.', controller: _nameCtrl, required: true,
                            validator: (v) => v!.isEmpty ? 'Required' : null)),
                        const SizedBox(width: 16),
                        Expanded(child: CrmTextField(label: 'Phone Number', hint: '+91 98765 43210', controller: _phoneCtrl, keyboardType: TextInputType.phone)),
                      ]),
                      const SizedBox(height: 14),
                      CrmTextField(label: 'About Client', hint: 'Brief description...', controller: _aboutCtrl, maxLines: 3),
                      const SizedBox(height: 14),
                      Row(children: [
                        Expanded(child: CrmTextField(label: 'Email ID', hint: 'client@example.com', controller: _emailCtrl, keyboardType: TextInputType.emailAddress)),
                        const SizedBox(width: 16),
                        Expanded(child: CrmTextField(label: 'Address', hint: 'City, State', controller: _addressCtrl)),
                      ]),
                    ]),
                  ),

                  const SizedBox(height: 20),

                  // ── Services ──
                  SectionCard(
                    title: 'Services Requested',
                    titleIcon: _SectionIcon('⚙️', const Color(0xFFF0FFF4), AppColors.accent),
                    action: CrmButton('+ Add Service', style: BtnStyle.outline,
                        onTap: () => setState(() => _services.add(''))),
                    child: ServiceInputList(services: _services, onChanged: () => setState(() {})),
                  ),

                  const SizedBox(height: 20),

                  // ── Credentials ──
                  SectionCard(
                    title: 'Platform Credentials',
                    titleIcon: _SectionIcon('🔑', const Color(0xFFFFF8E1), const Color(0xFFE67E22)),
                    action: CrmButton('+ Add Platform', style: BtnStyle.outline,
                        onTap: () => setState(() => _credentials.add({'platform': 'facebook', 'username': '', 'password': ''}))),
                    child: CredentialInputList(credentials: _credentials, onChanged: () => setState(() {})),
                  ),

                  const SizedBox(height: 28),

                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    CrmButton('Cancel', style: BtnStyle.ghost, onTap: () => Navigator.maybePop(context)),
                    const SizedBox(width: 12),
                    CrmButton('💾  Save Client', loading: loading, width: 160, onTap: loading ? null : _submit),
                  ]),
                ]),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionIcon extends StatelessWidget {
  final String emoji;
  final Color bg, color;
  const _SectionIcon(this.emoji, this.bg, this.color);

  @override
  Widget build(BuildContext context) => Container(
    width: 28, height: 28,
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(kRadiusXs)),
    alignment: Alignment.center,
    child: Text(emoji, style: const TextStyle(fontSize: 14)),
  );
}

const double kRadiusXs = 6.0;