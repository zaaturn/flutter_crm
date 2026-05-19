import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/client tracker/features/clients/bloc/client_bloc.dart';
import 'package:my_app/client tracker/features/clients/bloc/client_event.dart';
import 'package:my_app/client tracker/features/clients/bloc/client_state.dart';
import 'package:my_app/client tracker/features/clients/models/client_platform_choices.dart';


class ZaaturnUI {
  static const Color background = Color(0xFFFAF3E0); // Light Cream
  static const Color cardColor = Color(0xFFEADBC8);   // Terracotta/Beige box
  static const Color fieldColor = Color(0xFFF2E6D6);  // Organic input fill
  static const Color accentOrange = Color(0xFFF3924C);
  static const Color textMain = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF5D4037);
  static const Color headerBlue = Color(0xFF0D47A1);

  static BoxDecoration cardDecoration() => BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(28),
  );
}

class ClientTrackerMobileAddClient extends StatefulWidget {
  const ClientTrackerMobileAddClient({super.key});

  @override
  State<ClientTrackerMobileAddClient> createState() =>
      _ClientTrackerMobileAddClientState();
}

class _ClientTrackerMobileAddClientState extends State<ClientTrackerMobileAddClient> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _about = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();

  final List<TextEditingController> _services = [TextEditingController()];
  final List<_CredRow> _creds = [];

  @override
  void dispose() {
    _name.dispose(); _about.dispose(); _address.dispose();
    _phone.dispose(); _email.dispose();
    for (final c in _services) c.dispose();
    for (final c in _creds) c.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final services = _services.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList();
    final credentials = _creds.map((c) => c.toJson()).toList();

    context.read<ClientBloc>().add(
      SaveClientEvent(
        clientData: {
          'name': _name.text.trim(),
          'about': _about.text.trim(),
          'address': _address.text.trim(),
          'phone': _phone.text.trim(),
          'email': _email.text.trim(),
        },
        services: services,
        credentials: credentials,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClientBloc, ClientState>(
      builder: (context, state) {
        final loading = state is ClientLoading;

        return Scaffold(
          backgroundColor: ZaaturnUI.background,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Header with the Save button on the right
                _buildHeader(context, loading),
                Expanded(
                  child: BlocListener<ClientBloc, ClientState>(
                    listener: (context, state) {
                      if (state is ClientSaved) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Client saved')));
                        _formKey.currentState?.reset();
                      }
                      if (state is ClientError) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
                      }
                    },
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      children: [
                        _buildInfoCard(),
                        const SizedBox(height: 16),
                        _servicesCard(),
                        const SizedBox(height: 16),
                        _credentialsCard(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool loading) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 16, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22, color: Colors.blueAccent),
          ),
          Text(
            'Add Client',
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: ZaaturnUI.headerBlue,
            ),
          ),
          const Spacer(),
          loading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blueAccent))
              : TextButton(
            onPressed: _submit,
            child: Text(
              'Save',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.blueAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: ZaaturnUI.cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _field(label: 'Client Name', controller: _name, required: true),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _field(label: 'Phone', controller: _phone)),
                const SizedBox(width: 12),
                Expanded(child: _field(label: 'Email', controller: _email)),
              ],
            ),
            const SizedBox(height: 12),
            _field(label: 'Address', controller: _address),
            const SizedBox(height: 12),
            _field(label: 'About', controller: _about, maxLines: 3),
          ],
        ),
      ),
    );
  }

  Widget _servicesCard() {
    return Container(
      decoration: ZaaturnUI.cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Services', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w900)),
              IconButton(
                onPressed: () => setState(() => _services.add(TextEditingController())),
                icon: const Icon(Icons.add_circle, color: ZaaturnUI.accentOrange),
              ),
            ],
          ),
          ..._services.asMap().entries.map((entry) {
            int i = entry.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(child: _field(label: 'Service ${i + 1}', controller: _services[i])),
                  if (_services.length > 1)
                    IconButton(onPressed: () => setState(() => _services.removeAt(i).dispose()), icon: const Icon(Icons.remove_circle_outline)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _credentialsCard() {
    return Container(
      decoration: ZaaturnUI.cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Credentials', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w900)),
              IconButton(
                onPressed: () => setState(() => _creds.add(_CredRow())),
                icon: const Icon(Icons.add_circle, color: ZaaturnUI.accentOrange),
              ),
            ],
          ),
          ..._creds.asMap().entries.map((entry) {
            int i = entry.key;
            return Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: ZaaturnUI.fieldColor, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  DropdownButton<String>(
                    value: _creds[i].platform,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: [for (final e in ClientPlatformChoices.entries) DropdownMenuItem(value: e['value']!, child: Text(e['label']!))],
                    onChanged: (v) { if (v != null) setState(() => _creds[i].platform = v); },
                  ),
                  _field(label: 'Username', controller: _creds[i].username),
                  const SizedBox(height: 8),
                  _field(label: 'Password', controller: _creds[i].password, obscure: true),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _field({required String label, required TextEditingController controller, bool required = false, int maxLines = 1, bool obscure = false}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      obscureText: obscure,
      validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null : null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: ZaaturnUI.fieldColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }
}

class _CredRow {
  String platform = 'youtube';
  final username = TextEditingController();
  final password = TextEditingController();
  void dispose() { username.dispose(); password.dispose(); }
  Map<String, dynamic> toJson() => {'platform': platform, 'username': username.text.trim(), 'password': password.text};
}