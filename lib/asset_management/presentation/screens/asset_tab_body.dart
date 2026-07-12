import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../bloc/asset_bloc.dart';
import '../../bloc/asset_event.dart';
import '../../bloc/asset_state.dart';
import '../../models/asset_models.dart';
import '../../repository/asset_repository.dart';
import '../../theme/asset_theme.dart';
import '../../utils/asset_file_download.dart';
import '../dialogs/asset_action_dialogs.dart';
import '../widgets/asset_common_widgets.dart';
import '../widgets/asset_guest_access_section.dart';
import 'asset_create_screen.dart';
import 'asset_detail_screen.dart';
import 'asset_scan_screen.dart';

/// Tab body content shared by desktop + mobile shells.
class AssetTabBody extends StatelessWidget {
  const AssetTabBody({
    super.key,
    required this.useMobileTheme,
  });

  final bool useMobileTheme;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AssetBloc, AssetState>(
      builder: (context, state) {
        if (state.loading && _isEmpty(state)) {
          return const Center(child: CircularProgressIndicator());
        }

        switch (state.tab) {
          case AssetShellTab.dashboard:
            return _DashboardBody(state: state, mobile: useMobileTheme);
          case AssetShellTab.inventory:
            return _InventoryBody(state: state, mobile: useMobileTheme);
          case AssetShellTab.myAssets:
            return _MyAssetsBody(state: state, mobile: useMobileTheme);
          case AssetShellTab.scan:
            return AssetScanScreen(
              useMobileTheme: useMobileTheme,
              embedded: true,
            );
          case AssetShellTab.search:
            return _SearchBody(state: state, mobile: useMobileTheme);
          case AssetShellTab.calendar:
            return _CalendarBody(state: state, mobile: useMobileTheme);
          case AssetShellTab.pendingRequests:
            return _PendingRequestsBody(state: state, mobile: useMobileTheme);
          case AssetShellTab.pendingReturns:
            return _PendingReturnsBody(state: state, mobile: useMobileTheme);
          case AssetShellTab.pendingDamage:
            return _PendingDamageBody(state: state, mobile: useMobileTheme);
          case AssetShellTab.guests:
            return AssetGuestsHubBody(useMobileTheme: useMobileTheme);
        }
      },
    );
  }

  bool _isEmpty(AssetState s) {
    switch (s.tab) {
      case AssetShellTab.dashboard:
        return s.dashboard == null;
      case AssetShellTab.inventory:
        return s.assets.isEmpty;
      case AssetShellTab.myAssets:
        return s.myAssets.isEmpty;
      case AssetShellTab.search:
        return s.searchResults.isEmpty;
      case AssetShellTab.calendar:
        return s.calendarEvents.isEmpty;
      case AssetShellTab.pendingRequests:
        return s.pendingRequests.isEmpty;
      case AssetShellTab.pendingReturns:
        return s.pendingReturns.isEmpty;
      case AssetShellTab.pendingDamage:
        return s.pendingDamage.isEmpty;
      case AssetShellTab.scan:
      case AssetShellTab.guests:
        return false;
    }
  }
}

void _openDetail(
  BuildContext context,
  String code, {
  required bool mobile,
  Asset? asset,
  bool isAdmin = false,
}) {
  Navigator.of(context)
      .push<bool>(
    MaterialPageRoute(
      builder: (_) => AssetDetailScreen(
        assetCode: code,
        initialAsset: asset,
        useMobileTheme: mobile,
        isAdmin: isAdmin,
      ),
    ),
  )
      .then((deleted) {
    if (deleted == true && context.mounted) {
      try {
        context.read<AssetBloc>().add(const AssetRefreshRequested());
      } catch (_) {}
    }
  });
}

Future<void> _saveBytes(
  BuildContext context, {
  required Uint8List bytes,
  required String filename,
}) async {
  try {
    await downloadAssetFile(
      context,
      bytes: bytes,
      filename: filename,
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not save: $e')),
    );
  }
}

// ─── Dashboard ───────────────────────────────────────────────────────────────

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.state, required this.mobile});
  final AssetState state;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    final d = state.dashboard;
    if (d == null) {
      return const AssetEmptyState(
        icon: Icons.dashboard_outlined,
        message: 'No dashboard data',
      );
    }

    final cards = [
      ('Total', '${d.total}', const Color(0xFFAACC96), Icons.inventory_2),
      ('Free', '${d.free}', const Color(0xFF52A5CE), Icons.check_circle_outline),
      ('Engaged', '${d.engaged}', const Color(0xFFF4BEAE), Icons.person_outline),
      ('Damaged', '${d.damaged}', const Color(0xFFFF7BAC), Icons.report_outlined),
      ('Pending requests', '${d.pendingRequests}', const Color(0xFFEFCE7B),
          Icons.pending_actions),
      ('Return requests', '${d.returnRequests}', const Color(0xFFD3B6D3),
          Icons.undo),
    ];

    return RefreshIndicator(
      onRefresh: () async {
        context.read<AssetBloc>().add(const AssetRefreshRequested());
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Asset overview',
            style: mobile
                ? AssetMobileTheme.title(size: 18)
                : AssetDesktopTheme.title(size: 18),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, c) {
              final cols = c.maxWidth > 900
                  ? 4
                  : c.maxWidth > 600
                      ? 3
                      : 2;
              return GridView.count(
                crossAxisCount: cols,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.45,
                children: [
                  for (final card in cards)
                    AssetStatCard(
                      label: card.$1,
                      value: card.$2,
                      color: card.$3,
                      icon: card.$4,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Inventory ───────────────────────────────────────────────────────────────

class _InventoryBody extends StatelessWidget {
  const _InventoryBody({required this.state, required this.mobile});
  final AssetState state;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    final accent =
        mobile ? AssetMobileTheme.terracotta : AssetDesktopTheme.teal;
    final repo = AssetRepository();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  value: state.statusFilter,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All')),
                    ...AssetStatus.values
                        .where((s) => s != AssetStatus.unknown)
                        .map(
                          (s) => DropdownMenuItem(
                            value: s.apiValue,
                            child: Text(s.label),
                          ),
                        ),
                  ],
                  onChanged: (v) {
                    context.read<AssetBloc>().add(
                          AssetListFilterChanged(
                            status: v,
                            assetType: state.typeFilter,
                          ),
                        );
                  },
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<AssetBloc>(),
                        child: AssetCreateScreen(useMobileTheme: mobile),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Create'),
                style: FilledButton.styleFrom(backgroundColor: accent),
              ),
            ],
          ),
        ),
        if (state.selectedCodes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('${state.selectedCodes.length} selected'),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    final bytes = await repo.printLabelSheet(
                      state.selectedCodes.toList(),
                    );
                    if (!context.mounted) return;
                    await _saveBytes(
                      context,
                      bytes: bytes,
                      filename: 'asset-labels.pdf',
                    );
                    if (!context.mounted) return;
                    context.read<AssetBloc>().add(const AssetClearSelection());
                  },
                  child: const Text('Print label sheet'),
                ),
              ],
            ),
          ),
        Expanded(
          child: state.assets.isEmpty
              ? const AssetEmptyState(
                  icon: Icons.inventory_2_outlined,
                  message: 'No assets found',
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    context
                        .read<AssetBloc>()
                        .add(const AssetRefreshRequested());
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.assets.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final a = state.assets[i];
                      final selected =
                          state.selectedCodes.contains(a.assetCode);
                      return _AssetListTile(
                        asset: a,
                        selected: selected,
                        mobile: mobile,
                        onTap: () => _openDetail(
                          context,
                          a.assetCode,
                          mobile: mobile,
                          asset: a,
                          isAdmin: true,
                        ),
                        onSelect: () => context
                            .read<AssetBloc>()
                            .add(AssetSelectionToggled(a.assetCode)),
                        onDownloadQr: () async {
                          final bytes =
                              await repo.downloadQrPng(a.assetCode);
                          if (!context.mounted) return;
                          await _saveBytes(
                            context,
                            bytes: bytes,
                            filename: '${a.assetCode}-qr.png',
                          );
                        },
                        onPrintLabel: () async {
                          final bytes =
                              await repo.downloadLabelPdf(a.assetCode);
                          if (!context.mounted) return;
                          await _saveBytes(
                            context,
                            bytes: bytes,
                            filename: '${a.assetCode}-label.pdf',
                          );
                        },
                        onDelete: () async {
                          final result = await showAssetDeleteDialog(
                            context,
                            assetName: a.name,
                            assetCode: a.assetCode,
                          );
                          if (result == null || !context.mounted) return;
                          context.read<AssetBloc>().add(
                                AssetDeleteRequested(
                                  a.assetCode,
                                  reason: result.reason,
                                ),
                              );
                        },
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

class _AssetListTile extends StatelessWidget {
  const _AssetListTile({
    required this.asset,
    required this.selected,
    required this.mobile,
    required this.onTap,
    required this.onSelect,
    required this.onDownloadQr,
    required this.onPrintLabel,
    required this.onDelete,
  });

  final Asset asset;
  final bool selected;
  final bool mobile;
  final VoidCallback onTap;
  final VoidCallback onSelect;
  final VoidCallback onDownloadQr;
  final VoidCallback onPrintLabel;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final accent =
        mobile ? AssetMobileTheme.terracotta : AssetDesktopTheme.teal;
    final border = mobile ? AssetMobileTheme.border : AssetDesktopTheme.border;
    final textDark =
        mobile ? AssetMobileTheme.textDark : AssetDesktopTheme.textDark;
    final textMuted =
        mobile ? AssetMobileTheme.textMuted : AssetDesktopTheme.textMuted;
    final surface =
        mobile ? AssetMobileTheme.cream : AssetDesktopTheme.surfaceMuted;
    final statusColor = AssetStatusColors.of(asset.status);

    final metaBits = <(IconData, String)>[
      if (asset.assetType.trim().isNotEmpty)
        (Icons.category_outlined, asset.assetType),
      if ((asset.location ?? '').trim().isNotEmpty)
        (Icons.place_outlined, asset.location!.trim()),
      if ((asset.department ?? '').trim().isNotEmpty)
        (Icons.apartment_outlined, asset.department!.trim()),
      if ((asset.currentAssigneeName ?? '').trim().isNotEmpty)
        (Icons.person_outline_rounded, asset.currentAssigneeName!.trim()),
    ];

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? accent : border,
              width: selected ? 1.6 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (selected ? accent : Colors.black)
                    .withValues(alpha: selected ? 0.12 : 0.04),
                blurRadius: selected ? 16 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 5, color: statusColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 6, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: Checkbox(
                                value: selected,
                                onChanged: (_) => onSelect(),
                                activeColor: accent,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      asset.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                        color: textDark,
                                        height: 1.25,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  AssetStatusChip(
                                    status: asset.status,
                                    compact: true,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                asset.assetCode,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: accent,
                                ),
                              ),
                              if (metaBits.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 6,
                                  children: [
                                    for (final bit in metaBits.take(3))
                                      _InventoryMetaChip(
                                        icon: bit.$1,
                                        label: bit.$2,
                                        textMuted: textMuted,
                                        border: border,
                                        surface: surface,
                                      ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          tooltip: 'Actions',
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.more_vert_rounded,
                            color: textMuted,
                          ),
                          onSelected: (v) {
                            if (v == 'qr') onDownloadQr();
                            if (v == 'label') onPrintLabel();
                            if (v == 'delete') onDelete();
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: 'qr',
                              child: Text(
                                'Download QR',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'label',
                              child: Text(
                                'Print label',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(
                                'Delete',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                  color: AssetMobileTheme.danger,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InventoryMetaChip extends StatelessWidget {
  const _InventoryMetaChip({
    required this.icon,
    required this.label,
    required this.textMuted,
    required this.border,
    required this.surface,
  });

  final IconData icon;
  final String label;
  final Color textMuted;
  final Color border;
  final Color surface;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textMuted),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── My Assets ───────────────────────────────────────────────────────────────

class _MyAssetsBody extends StatelessWidget {
  const _MyAssetsBody({required this.state, required this.mobile});
  final AssetState state;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    if (state.myAssets.isEmpty) {
      return const AssetEmptyState(
        icon: Icons.devices_other,
        message: 'No assets assigned to you',
        subtitle: 'Scan a QR code to request an available asset',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<AssetBloc>().add(const AssetRefreshRequested());
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.myAssets.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final a = state.myAssets[i];
          return Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () =>
                  _openDetail(context, a.assetCode, mobile: mobile),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    if (a.qrCode != null && a.qrCode!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: a.qrCode!,
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) =>
                              const Icon(Icons.qr_code_2, size: 52),
                        ),
                      )
                    else
                      const Icon(Icons.devices, size: 48),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.assetName,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            a.assetCode,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AssetStatusChip(status: a.status, compact: true),
                          if (a.expectedReturnDate != null)
                            Text(
                              'Return by ${a.expectedReturnDate}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Search ──────────────────────────────────────────────────────────────────

class _SearchBody extends StatefulWidget {
  const _SearchBody({required this.state, required this.mobile});
  final AssetState state;
  final bool mobile;

  @override
  State<_SearchBody> createState() => _SearchBodyState();
}

class _SearchBodyState extends State<_SearchBody> {
  late final TextEditingController _ctrl =
      TextEditingController(text: widget.state.searchQuery);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _ctrl,
            decoration: InputDecoration(
              hintText: 'Search code, name, employee, department…',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (v) =>
                context.read<AssetBloc>().add(AssetSearchQueryChanged(v)),
          ),
        ),
        Expanded(
          child: widget.state.loading
              ? const Center(child: CircularProgressIndicator())
              : widget.state.searchResults.isEmpty
                  ? AssetEmptyState(
                      icon: Icons.search_off,
                      message: widget.state.searchQuery.isEmpty
                          ? 'Type to search assets'
                          : 'No results',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: widget.state.searchResults.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final a = widget.state.searchResults[i];
                        return ListTile(
                          tileColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: Text(a.name),
                          subtitle: Text('${a.assetCode} · ${a.status.label}'),
                          trailing: AssetStatusChip(
                            status: a.status,
                            compact: true,
                          ),
                          onTap: () => _openDetail(
                            context,
                            a.assetCode,
                            mobile: widget.mobile,
                            asset: a,
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

// ─── Calendar ────────────────────────────────────────────────────────────────

bool _calendarEventIsEngaged(AssetCalendarEvent e) {
  final status = (e.status ?? '').toLowerCase().replaceAll(' ', '_');
  if (status == 'engaged') return true;
  return e.color == AssetCalendarColor.red;
}

Color _calendarDotColor(AssetCalendarEvent e) => _calendarEventIsEngaged(e)
    ? const Color(0xFFDC2626)
    : const Color(0xFF059669);

class _CalendarBody extends StatefulWidget {
  const _CalendarBody({required this.state, required this.mobile});
  final AssetState state;
  final bool mobile;

  @override
  State<_CalendarBody> createState() => _CalendarBodyState();
}

class _CalendarBodyState extends State<_CalendarBody> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  AssetState get state => widget.state;
  bool get mobile => widget.mobile;

  @override
  void initState() {
    super.initState();
    final year = state.calendarYear ?? DateTime.now().year;
    final month = state.calendarMonth ?? DateTime.now().month;
    final now = DateTime.now();
    _focusedDay = DateTime(year, month, 1);
    // Default to today when viewing the current month; otherwise first of month.
    _selectedDay = (year == now.year && month == now.month)
        ? DateTime(now.year, now.month, now.day)
        : DateTime(year, month, 1);
  }

  @override
  void didUpdateWidget(covariant _CalendarBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    final year = state.calendarYear ?? DateTime.now().year;
    final month = state.calendarMonth ?? DateTime.now().month;
    if (year != _focusedDay.year || month != _focusedDay.month) {
      final now = DateTime.now();
      _focusedDay = DateTime(year, month, 1);
      _selectedDay = (year == now.year && month == now.month)
          ? DateTime(now.year, now.month, now.day)
          : DateTime(year, month, 1);
    }
  }

  List<AssetCalendarEvent> _eventsForDay(DateTime day) {
    final key = DateFormat('yyyy-MM-dd').format(day);
    return state.calendarEvents
        .where((e) => e.assignedDate == key || e.expectedReturnDate == key)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final accent =
        mobile ? AssetMobileTheme.terracotta : AssetDesktopTheme.teal;
    final textDark =
        mobile ? AssetMobileTheme.textDark : AssetDesktopTheme.textDark;
    final textMuted =
        mobile ? AssetMobileTheme.textMuted : AssetDesktopTheme.textMuted;
    final border =
        mobile ? AssetMobileTheme.border : AssetDesktopTheme.border;
    final selected = _selectedDay ?? _focusedDay;
    final dayEvents = _eventsForDay(selected);
    final dayLabel = DateFormat('EEE, d MMM yyyy').format(selected);

    final calendar = TableCalendar<AssetCalendarEvent>(
      firstDay: DateTime(2020),
      lastDay: DateTime(2035),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      calendarFormat: CalendarFormat.month,
      availableGestures: AvailableGestures.horizontalSwipe,
      rowHeight: mobile ? 44 : 52,
      daysOfWeekHeight: mobile ? 22 : 28,
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        headerPadding: EdgeInsets.symmetric(vertical: mobile ? 8 : 12),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800,
          color: textDark,
          fontSize: mobile ? 15 : 16,
        ),
        leftChevronIcon: Icon(Icons.chevron_left_rounded, color: accent),
        rightChevronIcon: Icon(Icons.chevron_right_rounded, color: accent),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textMuted,
        ),
        weekendStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: accent,
        ),
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: accent.withValues(alpha: 0.18),
          shape: BoxShape.circle,
        ),
        todayTextStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800,
          color: mobile
              ? AssetMobileTheme.terracottaDark
              : AssetDesktopTheme.tealDark,
        ),
        selectedDecoration: BoxDecoration(
          color: accent,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
        defaultTextStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        weekendTextStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          color: mobile
              ? AssetMobileTheme.terracottaDark
              : AssetDesktopTheme.tealDark,
        ),
        outsideTextStyle: GoogleFonts.plusJakartaSans(
          color: textMuted.withValues(alpha: 0.5),
        ),
        markersMaxCount: 3,
        markerSize: 6,
        canMarkersOverflow: false,
      ),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = DateTime(
            selectedDay.year,
            selectedDay.month,
            selectedDay.day,
          );
          _focusedDay = focusedDay;
        });
        if (focusedDay.year != (state.calendarYear ?? focusedDay.year) ||
            focusedDay.month != (state.calendarMonth ?? focusedDay.month)) {
          context.read<AssetBloc>().add(
                AssetCalendarMonthChanged(
                  focusedDay.year,
                  focusedDay.month,
                ),
              );
        }
      },
      onPageChanged: (d) {
        setState(() {
          _focusedDay = d;
          final day = (_selectedDay?.day ?? 1)
              .clamp(1, DateUtils.getDaysInMonth(d.year, d.month));
          _selectedDay = DateTime(d.year, d.month, day);
        });
        context
            .read<AssetBloc>()
            .add(AssetCalendarMonthChanged(d.year, d.month));
      },
      eventLoader: _eventsForDay,
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          if (events.isEmpty) return null;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final e in events.take(3))
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: _calendarDotColor(e),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          );
        },
      ),
    );

    final dayHeader = Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              dayLabel,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: textDark,
              ),
            ),
          ),
          Text(
            dayEvents.isEmpty
                ? 'No assets'
                : '${dayEvents.length} asset${dayEvents.length == 1 ? '' : 's'}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textMuted,
            ),
          ),
        ],
      ),
    );

    Widget eventList({required bool shrinkWrap}) {
      if (dayEvents.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: AssetEmptyState(
            icon: Icons.event_busy_rounded,
            message: 'No assets for this day',
            subtitle: 'Tap a date with dots to see assignments',
          ),
        );
      }
      if (shrinkWrap) {
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: dayEvents.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final e = dayEvents[i];
            return _CalendarEventCard(
              event: e,
              mobile: mobile,
              onTap: () => _openDetail(
                context,
                e.assetCode,
                mobile: mobile,
              ),
            );
          },
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: dayEvents.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final e = dayEvents[i];
          return _CalendarEventCard(
            event: e,
            mobile: mobile,
            onTap: () => _openDetail(
              context,
              e.assetCode,
              mobile: mobile,
            ),
          );
        },
      );
    }

    final bg = mobile ? AssetMobileTheme.cream : AssetDesktopTheme.surfaceMuted;

    // Mobile: one scroll so calendar + day list both fit like desktop function.
    if (mobile) {
      return ColoredBox(
        color: bg,
        child: RefreshIndicator(
          color: accent,
          onRefresh: () async {
            context.read<AssetBloc>().add(const AssetRefreshRequested());
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: calendar,
                  ),
                ),
              ),
              Divider(height: 1, color: border),
              dayHeader,
              eventList(shrinkWrap: true),
            ],
          ),
        ),
      );
    }

    return ColoredBox(
      color: bg,
      child: Column(
        children: [
          calendar,
          Divider(height: 1, color: border),
          dayHeader,
          Expanded(child: eventList(shrinkWrap: false)),
        ],
      ),
    );
  }
}

class _CalendarEventCard extends StatelessWidget {
  const _CalendarEventCard({
    required this.event,
    required this.mobile,
    required this.onTap,
  });

  final AssetCalendarEvent event;
  final bool mobile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dot = _calendarDotColor(event);
    final accent =
        mobile ? AssetMobileTheme.terracotta : AssetDesktopTheme.teal;
    final surface =
        mobile ? AssetMobileTheme.cream : AssetDesktopTheme.surfaceMuted;
    final border = mobile ? AssetMobileTheme.border : AssetDesktopTheme.border;
    final textDark =
        mobile ? AssetMobileTheme.textDark : AssetDesktopTheme.textDark;
    final textMuted =
        mobile ? AssetMobileTheme.textMuted : AssetDesktopTheme.textMuted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                color: accent,
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.assetName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            event.assetCode,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: dot,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  children: [
                    _calMeta(
                      Icons.event_outlined,
                      'Assigned',
                      _formatCalendarDate(event.assignedDate),
                      textDark: textDark,
                      textMuted: textMuted,
                      accent: accent,
                    ),
                    const SizedBox(height: 8),
                    _calMeta(
                      Icons.person_outline,
                      'Requested by',
                      event.employeeName ?? '—',
                      textDark: textDark,
                      textMuted: textMuted,
                      accent: accent,
                    ),
                    const SizedBox(height: 8),
                    _calMeta(
                      Icons.badge_outlined,
                      'Assigned by',
                      event.assignedByName ?? '—',
                      textDark: textDark,
                      textMuted: textMuted,
                      accent: accent,
                    ),
                    const SizedBox(height: 8),
                    _calMeta(
                      Icons.event_available_outlined,
                      'Return date',
                      _formatCalendarDate(event.expectedReturnDate),
                      textDark: textDark,
                      textMuted: textMuted,
                      accent: accent,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// e.g. `2026-07-11` → `Sat, 11 Jul 2026`
String _formatCalendarDate(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '—';
  final cleaned = raw.trim();
  DateTime? parsed = DateTime.tryParse(cleaned);
  if (parsed == null && cleaned.length >= 10) {
    parsed = DateTime.tryParse(cleaned.substring(0, 10));
  }
  if (parsed == null) {
    final m =
        RegExp(r'^(\d{4})[-/](\d{1,2})[-/](\d{1,2})').firstMatch(cleaned);
    if (m != null) {
      parsed = DateTime(
        int.parse(m.group(1)!),
        int.parse(m.group(2)!),
        int.parse(m.group(3)!),
      );
    }
  }
  if (parsed == null) return cleaned;
  return DateFormat('EEE, d MMM yyyy').format(parsed.toLocal());
}

Widget _calMeta(
  IconData icon,
  String label,
  String value, {
  required Color textDark,
  required Color textMuted,
  required Color accent,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 16, color: accent),
      const SizedBox(width: 8),
      SizedBox(
        width: 110,
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textMuted,
          ),
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
        ),
      ),
    ],
  );
}



// ─── Pending queues ──────────────────────────────────────────────────────────

class _PendingRequestsBody extends StatelessWidget {
  const _PendingRequestsBody({required this.state, required this.mobile});
  final AssetState state;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    if (state.pendingRequests.isEmpty) {
      return const AssetEmptyState(
        icon: Icons.inbox_outlined,
        message: 'No pending requests',
      );
    }
    return RefreshIndicator(
      color: mobile ? AssetMobileTheme.terracotta : AssetDesktopTheme.teal,
      onRefresh: () async {
        context.read<AssetBloc>().add(const AssetRefreshRequested());
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.pendingRequests.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final r = state.pendingRequests[i];
          return _PendingActionCard(
            mobile: mobile,
            assetName: r.assetName,
            assetCode: r.assetCode,
            badge: 'Pending',
            icon: Icons.inventory_2_outlined,
            rows: [
              (Icons.person_outline, 'Requested by', r.requesterName ?? '—'),
              (Icons.flag_outlined, 'Purpose', r.purpose ?? '—'),
              (
                Icons.event_outlined,
                'Expected return',
                r.expectedReturnDate ?? '—',
              ),
              if (r.notes != null && r.notes!.trim().isNotEmpty)
                (Icons.notes_outlined, 'Notes', r.notes!),
            ],
            primaryLabel: 'Accept',
            secondaryLabel: 'Reject',
            busy: state.actionLoading,
            onPrimary: () =>
                context.read<AssetBloc>().add(AssetApproveRequest(r.id)),
            onSecondary: () async {
              final comment = await showCommentDialog(
                context,
                title: 'Reject request',
                hint: 'Optional comment',
              );
              if (comment == null || !context.mounted) return;
              context.read<AssetBloc>().add(
                    AssetRejectRequest(r.id, comment: comment),
                  );
            },
          );
        },
      ),
    );
  }
}

class _PendingActionCard extends StatelessWidget {
  const _PendingActionCard({
    required this.mobile,
    required this.assetName,
    required this.assetCode,
    required this.rows,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onPrimary,
    required this.onSecondary,
    this.badge = 'Pending',
    this.icon = Icons.inventory_2_outlined,
    this.busy = false,
  });

  final bool mobile;
  final String assetName;
  final String assetCode;
  final String badge;
  final IconData icon;
  final List<(IconData, String, String)> rows;
  final String primaryLabel;
  final String secondaryLabel;
  final bool busy;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    final accent =
        mobile ? AssetMobileTheme.terracotta : AssetDesktopTheme.teal;
    final accentDark =
        mobile ? AssetMobileTheme.terracottaDark : AssetDesktopTheme.tealDark;
    final surface =
        mobile ? AssetMobileTheme.cream : AssetDesktopTheme.surfaceMuted;
    final border = mobile ? AssetMobileTheme.border : AssetDesktopTheme.border;
    final textDark =
        mobile ? AssetMobileTheme.textDark : AssetDesktopTheme.textDark;
    final textMuted =
        mobile ? AssetMobileTheme.textMuted : AssetDesktopTheme.textMuted;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            color: accent,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assetName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        assetCode,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  _pendingMetaRow(
                    rows[i].$1,
                    rows[i].$2,
                    rows[i].$3,
                    accent: accent,
                    textDark: textDark,
                    textMuted: textMuted,
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: busy ? null : onSecondary,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: accentDark,
                      side: BorderSide(color: accent, width: 1.4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      secondaryLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: busy ? null : onPrimary,
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      primaryLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _pendingMetaRow(
  IconData icon,
  String label,
  String value, {
  required Color accent,
  required Color textDark,
  required Color textMuted,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 16, color: accent),
      const SizedBox(width: 8),
      SizedBox(
        width: 110,
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textMuted,
          ),
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
        ),
      ),
    ],
  );
}


class _PendingReturnsBody extends StatelessWidget {
  const _PendingReturnsBody({required this.state, required this.mobile});
  final AssetState state;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    if (state.pendingReturns.isEmpty) {
      return const AssetEmptyState(
        icon: Icons.assignment_return_outlined,
        message: 'No pending returns',
      );
    }
    return RefreshIndicator(
      color: mobile ? AssetMobileTheme.terracotta : AssetDesktopTheme.teal,
      onRefresh: () async {
        context.read<AssetBloc>().add(const AssetRefreshRequested());
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.pendingReturns.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final r = state.pendingReturns[i];
          return _PendingActionCard(
            mobile: mobile,
            assetName: r.assetName,
            assetCode: r.assetCode,
            badge: 'Return',
            icon: Icons.assignment_return_outlined,
            rows: [
              (Icons.person_outline, 'Returned by', r.employeeName ?? '—'),
              (
                Icons.event_outlined,
                'Expected return',
                r.expectedReturnDate ?? '—',
              ),
            ],
            primaryLabel: 'Accept',
            secondaryLabel: 'Reject',
            busy: state.actionLoading,
            onPrimary: () =>
                context.read<AssetBloc>().add(AssetVerifyReturn(r.id)),
            onSecondary: () async {
              final comment = await showCommentDialog(
                context,
                title: 'Reject return',
                hint: 'Rejection reason (optional)',
              );
              if (comment == null || !context.mounted) return;
              context.read<AssetBloc>().add(
                    AssetRejectReturn(r.id, comment: comment),
                  );
            },
          );
        },
      ),
    );
  }
}

class _PendingDamageBody extends StatelessWidget {
  const _PendingDamageBody({required this.state, required this.mobile});
  final AssetState state;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    if (state.pendingDamage.isEmpty) {
      return const AssetEmptyState(
        icon: Icons.build_circle_outlined,
        message: 'No open damage reports',
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AssetBloc>().add(const AssetRefreshRequested());
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.pendingDamage.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final d = state.pendingDamage[i];
          return Card(
            child: ListTile(
              title: Text(d.assetName),
              subtitle: Text(
                '${d.assetCode}\n${d.reporterName ?? '—'}'
                '\n${d.description ?? ''}',
              ),
              isThreeLine: true,
              trailing: Wrap(
                children: [
                  IconButton(
                    tooltip: 'Start repair',
                    icon: const Icon(Icons.build, color: Colors.orange),
                    onPressed: () => context
                        .read<AssetBloc>()
                        .add(AssetStartRepair(d.id)),
                  ),
                  IconButton(
                    tooltip: 'Complete repair',
                    icon: const Icon(Icons.done_all, color: Colors.green),
                    onPressed: () async {
                      final notes = await showCommentDialog(
                        context,
                        title: 'Complete repair',
                        hint: 'Resolution notes (optional)',
                      );
                      if (notes == null || !context.mounted) return;
                      context.read<AssetBloc>().add(
                            AssetCompleteRepair(d.id, notes: notes),
                          );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
