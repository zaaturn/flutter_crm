import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/client tracker/features/clients/bloc/client_bloc.dart';
import 'package:my_app/client tracker/features/clients/bloc/client_event.dart';
import 'package:my_app/client tracker/features/clients/bloc/client_state.dart';
import 'package:my_app/client tracker/features/clients/models/client_model.dart';
import 'package:my_app/client tracker/features/clients/screen/add_credential_screen.dart';
import 'package:my_app/client tracker/features/clients/screen/edit_client_screen.dart';

import '../widget/client_tracker_mobile_top_bar.dart';

class ClientTrackerMobileClientDetail extends StatefulWidget {
  const ClientTrackerMobileClientDetail({super.key, required this.clientId});
  final int clientId;

  @override
  State<ClientTrackerMobileClientDetail> createState() => _ClientTrackerMobileClientDetailState();
}

class _ClientTrackerMobileClientDetailState extends State<ClientTrackerMobileClientDetail> {
  static const Color lightCream = Color(0xFFFAF9F6);
  static const Color darkSlate = Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ClientBloc>().add(LoadClientDetailEvent(widget.clientId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightCream,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ClientTrackerMobileTopBar(
              title: 'Client',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: BlocBuilder<ClientBloc, ClientState>(
                builder: (context, state) {
                  if (state is ClientLoading || state is ClientInitial) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFB35A38)));
                  }
                  if (state is ClientDetailLoaded) {
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                      children: [
                        _Hero(client: state.client),
                        const SizedBox(height: 16),
                        _ClientActions(
                          client: state.client,
                          onAfterEdit: () => context.read<ClientBloc>().add(LoadClientDetailEvent(widget.clientId)),
                        ),
                        const SizedBox(height: 20),
                        _InfoSection(client: state.client),
                        const SizedBox(height: 16),
                        _ServicesSection(services: state.services),
                        const SizedBox(height: 16),
                        _CredentialsSection(credentials: state.credentials),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final ClientModel client;
  const _Hero({required this.client});

  @override
  Widget build(BuildContext context) {
    const Color heroPink = Color(0xFFF9A8A8);
    const Color darkText = Color(0xFF0F172A);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: heroPink,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: darkText.withOpacity(0.15), width: 1.5),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.3),
            child: Text(
              client.name.isNotEmpty ? client.name[0].toUpperCase() : '?',
              style: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 24, color: darkText),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(client.name, style: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 20, color: darkText)),
                Text(client.email ?? '', style: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 13, color: darkText.withOpacity(0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClientActions extends StatelessWidget {
  final ClientModel client;
  final VoidCallback onAfterEdit;
  const _ClientActions({required this.client, required this.onAfterEdit});

  @override
  Widget build(BuildContext context) {
    const Color buttonPeach = Color(0xFFF4D0C2);
    const Color darkSlate = Color(0xFF0F172A);
    const Color goldenHour = Color(0xFFCED183);
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: 'Edit',
            icon: Icons.edit_note_rounded,
            bgColor: buttonPeach,
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditClientScreen(client: client)));
              onAfterEdit();
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            label: 'Credential',
            icon: Icons.vpn_key_rounded,
            bgColor: goldenHour,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddCredentialScreen(clientId: client.id))),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label; final IconData icon; final Color bgColor; final VoidCallback onTap;
  const _ActionButton({required this.label, required this.icon, required this.bgColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const Color darkText = Color(0xFF0F172A);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: darkText.withOpacity(0.15), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: darkText),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.manrope(fontWeight: FontWeight.w900, color: darkText, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final ClientModel client;
  const _InfoSection({required this.client});

  @override
  Widget build(BuildContext context) {
    return _SectionWrapper(
      title: 'Information',
      child: Column(
        children: [
          _infoRow('Phone', client.phone),
          _infoRow('Email', client.email), // Fixed: Restored Email row
          _infoRow('Address', client.address, isMultiline: true),
          _infoRow('About', client.about, isMultiline: true),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String? value, {bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: const Color(0xFF0F172A).withOpacity(0.5), fontSize: 13)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              (value == null || value.isEmpty) ? '—' : value,
              textAlign: TextAlign.right,
              style: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: const Color(0xFF0F172A), fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServicesSection extends StatelessWidget {
  final List<ClientServiceModel> services;
  const _ServicesSection({required this.services});

  @override
  Widget build(BuildContext context) {
    return _SectionWrapper(
      title: 'Active Services',
      child: services.isEmpty
          ? Text('No active services', style: GoogleFonts.manrope(color: Colors.black38))
          : Wrap(
        spacing: 8,
        runSpacing: 8,
        children: services.map((s) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: const Color(0xFFB35A38), borderRadius: BorderRadius.circular(8)),
          child: Text(s.serviceName, style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)),
        )).toList(),
      ),
    );
  }
}

class _CredentialsSection extends StatelessWidget {
  final List<ClientCredentialModel> credentials;
  const _CredentialsSection({required this.credentials});

  @override
  Widget build(BuildContext context) {
    const Color goldenHour = Color(0xFFEED397); // Swatch Color applied here
    return _SectionWrapper(
      title: 'Stored Credentials',
      child: Column(
        children: credentials.map((c) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: goldenHour, // Updated to Golden Hour
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF0F172A).withOpacity(0.1), width: 1.5),
          ),
          child: Row(
            children: [
              const Icon(Icons.lock_person_rounded, size: 16, color: Color(0xFF0F172A)),
              const SizedBox(width: 10),
              Text(c.platformDisplay ?? c.platform, style: GoogleFonts.manrope(fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
            ],
          ),
        )).toList(),
      ),
    );
  }
}

class _SectionWrapper extends StatelessWidget {
  final String title; final Widget child;
  const _SectionWrapper({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEBDDCF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF0F172A).withOpacity(0.1), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 15, color: const Color(0xFF0F172A))),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}