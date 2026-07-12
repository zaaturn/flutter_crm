import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/asset_models.dart';
import '../../repository/asset_repository.dart';
import '../../theme/asset_theme.dart';
import '../dialogs/asset_action_dialogs.dart';
import '../widgets/asset_common_widgets.dart';

class AssetDetailScreen extends StatefulWidget {
  const AssetDetailScreen({
    super.key,
    required this.assetCode,
    this.initialAsset,
    this.useMobileTheme = false,
    this.isAdmin = false,
  });

  final String assetCode;
  final Asset? initialAsset;
  final bool useMobileTheme;
  final bool isAdmin;

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen> {
  final _repo = AssetRepository();
  late Asset? _asset = widget.initialAsset;
  bool _loading = true;
  String? _error;
  bool _busy = false;

  bool get _mint => !widget.useMobileTheme;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Prefer scan endpoint so actions booleans are present.
      Asset asset;
      try {
        asset = await _repo.scanAsset(widget.assetCode);
      } catch (_) {
        asset = await _repo.getAsset(widget.assetCode);
      }
      if (!mounted) return;
      setState(() {
        _asset = asset;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _request() async {
    final data = await showAssetRequestSheet(context);
    if (data == null || !mounted) return;
    setState(() => _busy = true);
    try {
      await _repo.requestAsset(
        widget.assetCode,
        purpose: data.purpose,
        expectedReturnDate: data.expectedReturnDate,
        notes: data.notes,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request submitted')),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
      return;
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _return() async {
    final ok = await showAssetReturnConfirm(context);
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    try {
      await _repo.returnAsset(widget.assetCode);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Return submitted')),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _damage() async {
    final desc = await showAssetDamageDialog(context);
    if (desc == null || !mounted) return;
    setState(() => _busy = true);
    try {
      await _repo.reportDamage(widget.assetCode, description: desc);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Damage reported')),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final a = _asset;
    if (a == null) return;
    final result = await showAssetDeleteDialog(
      context,
      assetName: a.name,
      assetCode: a.assetCode,
    );
    if (result == null || !mounted) return;
    setState(() => _busy = true);
    try {
      await _repo.deleteAsset(
        a.assetCode,
        reason: result.reason,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Asset deleted')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = _mint ? AssetDesktopTheme.shellMint : AssetMobileTheme.cream;
    final accent = _mint ? AssetDesktopTheme.teal : AssetMobileTheme.terracotta;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: _mint ? Colors.white : AssetMobileTheme.terracotta,
        foregroundColor: _mint ? AssetDesktopTheme.textDark : Colors.white,
        elevation: 0,
        title: Text(
          'Asset detail',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
        actions: [
          if (widget.isAdmin && _asset != null)
            IconButton(
              tooltip: 'Delete',
              onPressed: _busy ? null : _delete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      body: _loading && _asset == null
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _asset == null
              ? AssetEmptyState(
                  icon: Icons.error_outline,
                  message: _error!,
                  subtitle: 'Pull to retry',
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _headerCard(accent),
                      const SizedBox(height: 16),
                      _actionsRow(accent),
                      const SizedBox(height: 20),
                      Text(
                        'Timeline',
                        style: _mint
                            ? AssetDesktopTheme.title(size: 16)
                            : AssetMobileTheme.title(size: 16),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _mint
                                ? AssetDesktopTheme.border
                                : AssetMobileTheme.border,
                          ),
                        ),
                        child: AssetTimelineList(
                          events: _asset?.timeline ?? const [],
                          mint: _mint,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }

  Widget _headerCard(Color accent) {
    final a = _asset!;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _mint ? AssetDesktopTheme.border : AssetMobileTheme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (a.qrCode != null && a.qrCode!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: a.qrCode!,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      width: 72,
                      height: 72,
                      color: Colors.grey.shade100,
                      child: Icon(Icons.qr_code_2, color: accent),
                    ),
                  ),
                )
              else
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.inventory_2_outlined, color: accent),
                ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _mint
                            ? AssetDesktopTheme.textDark
                            : AssetMobileTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      a.assetCode,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AssetStatusChip(status: a.status),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _meta('Type', a.assetType.isEmpty ? '—' : a.assetType),
              if (a.brand != null) _meta('Brand', a.brand!),
              if (a.modelName != null) _meta('Model', a.modelName!),
              if (a.department != null) _meta('Department', a.department!),
              if (a.location != null) _meta('Location', a.location!),
              if (a.vendor != null && a.vendor!.isNotEmpty)
                _meta('Vendor', a.vendor!),
              if (a.currentAssigneeName != null)
                _meta('Assignee', a.currentAssigneeName!),
              if (a.warrantyExpiry != null)
                _meta(
                  'Warranty',
                  a.isWarrantyActive
                      ? 'Active · ${a.warrantyExpiry}'
                      : a.warrantyExpiry!,
                ),
            ],
          ),
          if (_busy) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _meta(String label, String value) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionsRow(Color accent) {
    final actions = _asset?.actions ?? const AssetActions();
    final buttons = <Widget>[];

    if (actions.canRequest) {
      buttons.add(
        FilledButton.icon(
          onPressed: _busy ? null : _request,
          icon: const Icon(Icons.handshake_outlined),
          label: const Text('Request'),
          style: FilledButton.styleFrom(backgroundColor: accent),
        ),
      );
    }
    if (actions.canReturn) {
      buttons.add(
        FilledButton.icon(
          onPressed: _busy ? null : _return,
          icon: const Icon(Icons.undo_rounded),
          label: const Text('Return'),
        ),
      );
    }
    if (actions.canReportDamage) {
      buttons.add(
        OutlinedButton.icon(
          onPressed: _busy ? null : _damage,
          icon: const Icon(Icons.report_outlined),
          label: const Text('Report damage'),
        ),
      );
    }
    if (widget.isAdmin) {
      buttons.add(
        OutlinedButton.icon(
          onPressed: _busy ? null : _delete,
          icon: const Icon(Icons.delete_outline_rounded),
          label: const Text('Delete'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AssetMobileTheme.danger,
            side: const BorderSide(color: AssetMobileTheme.danger),
          ),
        ),
      );
    }

    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: buttons,
    );
  }
}
