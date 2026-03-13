import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/client_state.dart';
import 'package:my_app/client tracker/features/clients/models/client_model.dart';
import 'package:my_app/client tracker/core/constants/app_theme.dart';
import 'package:my_app/client tracker/core/constants/crm_widget.dart';
import 'package:my_app/client tracker/core/constants/app_constant.dart';
import 'package:my_app/client tracker/features/clients/screen/edit_client_screen.dart';
import 'package:my_app/client tracker/features/clients/screen/add_credential_screen.dart';

class DetailBody extends StatelessWidget {
  final ClientDetailLoaded state;
  const DetailBody({required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CrmButton(
            '← Back to Clients',
            style: BtnStyle.ghost,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 20),
          HeroCard(
            client: state.client,
            servicesCount: state.services.length,
            credsCount: state.credentials.length,
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (ctx, bc) {
              final wide = bc.maxWidth > 600;
              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: InfoCard(client: state.client)),
                    const SizedBox(width: 20),
                    Expanded(child: ServicesCard(services: state.services)),
                  ],
                );
              }
              return Column(
                children: [
                  InfoCard(client: state.client),
                  const SizedBox(height: 20),
                  ServicesCard(services: state.services),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          CredentialsCard(
            credentials: state.credentials,
            clientId: state.client.id,
          ),
        ],
      ),
    );
  }
}

class HeroCard extends StatelessWidget {
  final ClientModel client;
  final int servicesCount;
  final int credsCount;

  const HeroCard({
    required this.client,
    required this.servicesCount,
    required this.credsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E2A38), Color(0xFF243447)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(kRadius),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  client.name.isNotEmpty ? client.name[0].toUpperCase() : '?',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.name,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (client.email != null)
                      Text(
                        client.email!,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white60,
                          fontSize: 13,
                        ),
                      ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        HeroStat('$servicesCount', 'Services'),
                        const SizedBox(width: 24),
                        HeroStat('$credsCount', 'Credentials'),
                        const SizedBox(width: 24),
                        HeroStat("Mar '26", 'Joined'),
                      ],
                    ),
                  ],
                ),
              ),
              CrmButton(
                'Edit Client',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditClientScreen(client: client),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        Positioned(
          top: -40,
          right: -40,
          child: IgnorePointer(
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class HeroStat extends StatelessWidget {
  final String val;
  final String lbl;

  const HeroStat(this.val, this.lbl);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(val,
            style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800)),
        Text(lbl,
            style: GoogleFonts.plusJakartaSans(
                color: Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class InfoCard extends StatelessWidget {
  final ClientModel client;
  const InfoCard({required this.client});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Client Info',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: InfoTile(label: 'Phone', value: client.phone ?? '-')),
              const SizedBox(width: 12),
              Expanded(child: InfoTile(label: 'Email', value: client.email ?? '-')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: InfoTile(label: 'Address', value: client.address ?? '-')),
              const SizedBox(width: 12),
              Expanded(child: InfoTile(label: 'About', value: client.about ?? '-')),
            ],
          ),
        ],
      ),
    );
  }
}

class ServicesCard extends StatelessWidget {
  final List<ClientServiceModel> services;
  const ServicesCard({required this.services});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Services',
      child: services.isEmpty
          ? Text('No services added.', style: AppTextStyles.small)
          : Wrap(
        spacing: 8,
        runSpacing: 8,
        children: services
            .map((s) => Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            s.serviceName,
            style: AppTextStyles.small.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ))
            .toList(),
      ),
    );
  }
}

class CredentialsCard extends StatelessWidget {
  final List<ClientCredentialModel> credentials;
  final int clientId;

  const CredentialsCard({
    required this.credentials,
    required this.clientId,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Platform Credentials',
      action: CrmButton(
        '+ Add Credential',
        style: BtnStyle.ghost,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddCredentialScreen(clientId: clientId),
            ),
          );
        },
      ),
      child: credentials.isEmpty
          ? Text('No credentials added.', style: AppTextStyles.small)
          : Column(
        children: credentials.map((c) => CredRow(cred: c)).toList(),
      ),
    );
  }
}

class CredRow extends StatefulWidget {
  final ClientCredentialModel cred;
  const CredRow({required this.cred});

  @override
  State<CredRow> createState() => _CredRowState();
}

class _CredRowState extends State<CredRow> {
  bool _showPass = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(kRadiusSm),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PLATFORM', style: AppTextStyles.tableHdr),
                SelectableText(widget.cred.platform ?? '-',
                    style: AppTextStyles.bodyMed),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('USERNAME', style: AppTextStyles.tableHdr),
                SelectableText(widget.cred.username ?? '-',
                    style: AppTextStyles.bodyMed),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PASSWORD', style: AppTextStyles.tableHdr),
                SelectableText(
                  _showPass ? (widget.cred.password ?? '-') : '••••••••',
                  style: AppTextStyles.mono,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _showPass = !_showPass),
            child: Icon(
              _showPass
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 16,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}