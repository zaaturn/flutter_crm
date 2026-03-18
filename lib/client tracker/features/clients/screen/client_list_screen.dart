import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/client_bloc.dart';
import '../bloc/client_event.dart';
import '../bloc/client_state.dart';
import 'package:my_app/client tracker/features/clients/models/client_model.dart';
import 'package:my_app/client tracker/core/constants/app_theme.dart';
import 'package:my_app/client tracker/core/constants/crm_widget.dart';
import 'client_detail_screen.dart';

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ClientBloc>().add(LoadClientsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: BlocBuilder<ClientBloc, ClientState>(
        builder: (ctx, state) {
          if (state is ClientLoading) return const Center(child: CircularProgressIndicator());
          if (state is ClientError) return _ErrorView(msg: state.message,
              onRetry: () => ctx.read<ClientBloc>().add(LoadClientsEvent()));
          if (state is ClientListLoaded) return _ClientTable(clients: state.clients);
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ClientTable extends StatefulWidget {
  final List<ClientModel> clients;
  const _ClientTable({required this.clients});

  @override
  State<_ClientTable> createState() => _ClientTableState();
}

class _ClientTableState extends State<_ClientTable> {
  String _search = '';

  List<ClientModel> get _filtered => widget.clients
      .where((c) => c.name.toLowerCase().contains(_search.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return CrmCard(
      child: Column(children: [
        // Table Header bar
        Container(
          padding: const EdgeInsets.fromLTRB(22, 16, 16, 14),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
          child: Row(children: [
            Text('All Clients', style: AppTextStyles.subheading),
            const Spacer(),
            SizedBox(
              width: 220,
              child: TextField(
                style: AppTextStyles.body,
                onChanged: (v) => setState(() => _search = v),
                decoration: InputDecoration(
                  hintText: '🔍  Search clients…',
                  hintStyle: AppTextStyles.body.copyWith(color: AppColors.textLight),
                  filled: true, fillColor: AppColors.bg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(kRadiusSm), borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(kRadiusSm), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                ),
              ),
            ),
          ]),
        ),

        // Column headers
        Container(
          color: AppColors.tableHead,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(children: [
            const SizedBox(width: 48),
            Expanded(flex: 3, child: Text('CLIENT NAME', style: AppTextStyles.tableHdr)),
            Expanded(flex: 2, child: Text('PHONE',       style: AppTextStyles.tableHdr)),
            Expanded(flex: 3, child: Text('EMAIL',       style: AppTextStyles.tableHdr)),
            Expanded(flex: 1, child: Text('SERVICES',    style: AppTextStyles.tableHdr, textAlign: TextAlign.center)),
            Expanded(flex: 1, child: Text('STATUS',      style: AppTextStyles.tableHdr)),
            const SizedBox(width: 80),
          ]),
        ),

        if (_filtered.isEmpty)
          const _EmptyState()
        else
          ...(_filtered.map((c) => _ClientRow(client: c))),
      ]),
    );
  }
}

class _ClientRow extends StatefulWidget {
  final ClientModel client;
  const _ClientRow({required this.client});

  @override
  State<_ClientRow> createState() => _ClientRowState();
}

class _ClientRowState extends State<_ClientRow> {
  bool _hovered = false;

  // Function to show confirmation before deleting
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Client?'),
        content: Text('Are you sure you want to delete ${widget.client.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              // Trigger the Bloc Event
              context.read<ClientBloc>().add(DeleteClientEvent(widget.client.id));
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.client;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => ClientDetailScreen(clientId: c.id))),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.bg : Colors.transparent,
            border: const Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(children: [
            ClientAvatar(name: c.name, size: 34, gradient: ClientAvatar.gradientFor(c.name)),
            const SizedBox(width: 12),
            Expanded(flex: 3, child: Text(c.name, style: AppTextStyles.bodyMed, overflow: TextOverflow.ellipsis)),
            Expanded(flex: 2, child: Text(c.phone ?? '-', style: AppTextStyles.body)),
            Expanded(flex: 3, child: Text(c.email ?? '-', style: AppTextStyles.body.copyWith(color: AppColors.textMuted), overflow: TextOverflow.ellipsis)),
            Expanded(flex: 1, child: Center(child: _ServicesPill(count: c.servicesCount))),
            Expanded(flex: 1, child: CrmBadge('Active', type: BadgeType.green)),

            // DELETE BUTTON SECTION
            SizedBox(
                width: 80,
                child: Row(
                  children: [
                    if (_hovered) // Only show trash icon on hover to keep UI clean
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: () => _confirmDelete(context),
                      ),
                    const Spacer(),
                    const Icon(Icons.chevron_right, color: AppColors.textLight),
                  ],
                )
            ),
          ]),
        ),
      ),
    );
  }
}

class _ServicesPill extends StatelessWidget {
  final int count;
  const _ServicesPill({required this.count});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      const Text('⚙️', style: TextStyle(fontSize: 11)),
      const SizedBox(width: 4),
      Text('$count', style: AppTextStyles.small.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
    ]),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(48),
    child: Column(children: [
      const Text('👥', style: TextStyle(fontSize: 40)),
      const SizedBox(height: 12),
      Text('No clients found', style: AppTextStyles.subheading),
      const SizedBox(height: 4),
      Text('Add your first client to get started.', style: AppTextStyles.small),
    ]),
  );
}

class _ErrorView extends StatelessWidget {
  final String msg;
  final VoidCallback onRetry;
  const _ErrorView({required this.msg, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(msg, style: AppTextStyles.body.copyWith(color: AppColors.danger)),
      const SizedBox(height: 12),
      CrmButton('Retry', onTap: onRetry),
    ]),
  );
}