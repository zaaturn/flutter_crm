import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/client tracker/features/clients/bloc/client_bloc.dart';
import 'package:my_app/client tracker/features/clients/bloc/client_event.dart';
import 'package:my_app/client tracker/features/clients/bloc/client_state.dart';
import 'package:my_app/client tracker/features/clients/models/client_model.dart';

import '../widget/client_tracker_mobile_top_bar.dart';
import 'client_tracker_mobile_client_detail.dart';

class ClientTrackerMobileClientsList extends StatefulWidget {
  const ClientTrackerMobileClientsList({super.key});

  @override
  State<ClientTrackerMobileClientsList> createState() =>
      _ClientTrackerMobileClientsListState();
}

class _ClientTrackerMobileClientsListState
    extends State<ClientTrackerMobileClientsList> {
  String _q = '';

  // Design Tokens
  static const Color lightCream = Color(0xFFFAF9F6);
  static const Color midCream = Color(0xFFEBDDCF);
  static const Color terracotta = Color(0xFFB35A38);
  static const Color darkSlate = Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ClientBloc>().add(LoadClientsEvent());
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
              title: 'Clients',
              onBack: () => Navigator.of(context).maybePop(),
              // Trailing Refresh button removed as requested
            ),
            Expanded(
              child: RefreshIndicator(
                color: terracotta,
                onRefresh: () async {
                  context.read<ClientBloc>().add(LoadClientsEvent());
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 120), // Extra bottom padding for BottomNav
                  children: [
                    // Search Bar
                    TextField(
                      onChanged: (v) => setState(() => _q = v.trim()),
                      style: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: darkSlate),
                      decoration: InputDecoration(
                        hintText: 'Search clients...',
                        hintStyle: GoogleFonts.manrope(color: darkSlate.withOpacity(0.4), fontWeight: FontWeight.w600),
                        prefixIcon: const Icon(Icons.search_rounded, color: terracotta),
                        filled: true,
                        fillColor: midCream,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: darkSlate.withOpacity(0.1), width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: darkSlate.withOpacity(0.1), width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    BlocBuilder<ClientBloc, ClientState>(
                      builder: (context, state) {
                        if (state is ClientLoading || state is ClientInitial) {
                          return const Padding(
                            padding: EdgeInsets.all(60),
                            child: Center(child: CircularProgressIndicator(color: terracotta)),
                          );
                        }
                        if (state is ClientError) {
                          return _ErrorCard(
                            message: state.message,
                            onRetry: () => context.read<ClientBloc>().add(LoadClientsEvent()),
                          );
                        }
                        if (state is ClientListLoaded) {
                          final list = _filter(state.clients);
                          if (list.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 60),
                              child: Center(
                                child: Text(
                                  'No clients found.',
                                  style: GoogleFonts.manrope(
                                    color: darkSlate.withOpacity(0.5),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            );
                          }
                          return Column(
                            children: [
                              for (final c in list)
                                _ClientCard(
                                  client: c,
                                  onOpen: () => Navigator.of(context).push<void>(
                                    MaterialPageRoute(
                                      builder: (_) => ClientTrackerMobileClientDetail(clientId: c.id),
                                    ),
                                  ),
                                  onDelete: () => _confirmDelete(context, c),
                                ),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ClientModel> _filter(List<ClientModel> list) {
    if (_q.isEmpty) return list;
    final q = _q.toLowerCase();
    return list.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  Future<void> _confirmDelete(BuildContext context, ClientModel client) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: lightCream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: darkSlate, width: 1.5)),
        title: Text('Delete client?', style: GoogleFonts.manrope(fontWeight: FontWeight.w900)),
        content: Text('Delete ${client.name}? This cannot be undone.', style: GoogleFonts.manrope(fontWeight: FontWeight.w600)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.manrope(color: darkSlate, fontWeight: FontWeight.w800)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    context.read<ClientBloc>().add(DeleteClientEvent(client.id));
  }
}

class _ClientCard extends StatelessWidget {
  const _ClientCard({
    required this.client,
    required this.onOpen,
    required this.onDelete,
  });

  final ClientModel client;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    const Color terracotta = Color(0xFFB35A38);
    const Color midCream = Color(0xFFEBDDCF);
    const Color darkSlate = Color(0xFF0F172A);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: midCream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: darkSlate.withOpacity(0.1), width: 1.5),
      ),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: terracotta.withOpacity(0.12),
                child: Text(
                  client.name.isNotEmpty ? client.name[0].toUpperCase() : '?',
                  style: const TextStyle(fontWeight: FontWeight.w900, color: terracotta),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: darkSlate,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      client.email ?? client.phone ?? '-',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: darkSlate.withOpacity(0.5),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: terracotta,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${client.servicesCount} SVCS',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      child: const Icon(Icons.delete_sweep_rounded, color: Color(0xFFEF4444), size: 22),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Text(message, textAlign: TextAlign.center, style: GoogleFonts.manrope(color: const Color(0xFF991B1B), fontWeight: FontWeight.w700)),
          TextButton(onPressed: onRetry, child: Text('Retry', style: GoogleFonts.manrope(fontWeight: FontWeight.w900, color: const Color(0xFFB35A38)))),
        ],
      ),
    );
  }
}