import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../models/asset_models.dart';
import '../../repository/asset_repository.dart';
import '../../theme/asset_theme.dart';
import '../screens/asset_detail_screen.dart';

/// Admin Guests tab — read-only list of guest logins and their asset requests.
class AssetGuestsHubBody extends StatefulWidget {
  const AssetGuestsHubBody({super.key, this.useMobileTheme = true});

  final bool useMobileTheme;

  @override
  State<AssetGuestsHubBody> createState() => _AssetGuestsHubBodyState();
}

class _AssetGuestsHubBodyState extends State<AssetGuestsHubBody> {
  final _repo = AssetRepository();
  List<AssetGuestAccess> _guests = const [];
  bool _loading = true;
  String? _error;

  bool get _mobile => widget.useMobileTheme;
  Color get _accent =>
      _mobile ? AssetMobileTheme.terracotta : AssetDesktopTheme.teal;
  Color get _textDark =>
      _mobile ? AssetMobileTheme.textDark : AssetDesktopTheme.textDark;
  Color get _textMuted =>
      _mobile ? AssetMobileTheme.textMuted : AssetDesktopTheme.textMuted;
  Color get _border =>
      _mobile ? AssetMobileTheme.border : AssetDesktopTheme.border;

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
      final list = await _repo.listGuests();
      if (!mounted) return;
      setState(() {
        _guests = list;
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

  void _openAsset(String assetCode) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AssetDetailScreen(
          assetCode: assetCode,
          useMobileTheme: widget.useMobileTheme,
          isAdmin: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      color: _accent,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Guests',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 20),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            _emptyBox(
              child: Text(
                _error!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AssetMobileTheme.danger,
                ),
              ),
            )
          else if (_guests.isEmpty)
            _emptyBox(
              child: Text(
                'No guests yet.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: _textMuted,
                ),
              ),
            )
          else
            ..._guests.map(
              (g) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _GuestCard(
                  guest: g,
                  useMobileTheme: widget.useMobileTheme,
                  onTap: g.assets.isNotEmpty
                      ? () => _openAsset(g.assets.first.assetCode)
                      : null,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _emptyBox({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: child,
    );
  }
}

class _GuestCard extends StatefulWidget {
  const _GuestCard({
    required this.guest,
    required this.useMobileTheme,
    this.onTap,
  });

  final AssetGuestAccess guest;
  final bool useMobileTheme;
  final VoidCallback? onTap;

  @override
  State<_GuestCard> createState() => _GuestCardState();
}

class _GuestCardState extends State<_GuestCard> {
  bool _expanded = false;

  bool get _mobile => widget.useMobileTheme;
  Color get _accent =>
      _mobile ? AssetMobileTheme.terracotta : AssetDesktopTheme.teal;
  Color get _textDark =>
      _mobile ? AssetMobileTheme.textDark : AssetDesktopTheme.textDark;
  Color get _textMuted =>
      _mobile ? AssetMobileTheme.textMuted : AssetDesktopTheme.textMuted;
  Color get _border =>
      _mobile ? AssetMobileTheme.border : AssetDesktopTheme.border;

  Color get _statusColor => switch (widget.guest.status) {
        AssetGuestStatus.active => const Color(0xFF059669),
        AssetGuestStatus.expired => const Color(0xFFD97706),
        AssetGuestStatus.revoked => AssetMobileTheme.danger,
      };

  Color _requestColor(AssetGuestRequestStatus s) => switch (s) {
        AssetGuestRequestStatus.pending => const Color(0xFFD97706),
        AssetGuestRequestStatus.approved => const Color(0xFF059669),
        AssetGuestRequestStatus.rejected => AssetMobileTheme.danger,
        AssetGuestRequestStatus.unknown => _textMuted,
      };

  @override
  Widget build(BuildContext context) {
    final guest = widget.guest;
    final assets = guest.assets;
    final extra = assets.length > 1 ? assets.length - 1 : 0;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      guest.name.isEmpty ? guest.username : guest.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      guest.statusLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                guest.contactDisplay,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _textMuted,
                ),
              ),
              const SizedBox(height: 8),
              if (assets.isEmpty)
                Text(
                  'No requests yet',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _textMuted,
                  ),
                )
              else ...[
                _requestLine(assets.first),
                if (extra > 0) ...[
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Text(
                      _expanded ? 'Show less' : '+$extra more',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _accent,
                      ),
                    ),
                  ),
                  if (_expanded) ...[
                    const SizedBox(height: 8),
                    ...assets.skip(1).map(
                          (a) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: _requestLine(a),
                          ),
                        ),
                  ],
                ],
              ],
              const SizedBox(height: 8),
              Text(
                guest.isSelfRegistered
                    ? 'Self-registered'
                    : 'Added by ${guest.createdByName}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _textMuted,
                ),
              ),
              if (guest.expiresAt != null) ...[
                const SizedBox(height: 2),
                Text(
                  'Expires ${DateFormat('d MMM yyyy, HH:mm').format(guest.expiresAt!)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _requestLine(AssetGuestRequestedAsset asset) {
    final color = _requestColor(asset.status);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text.rich(
            TextSpan(
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _textDark,
              ),
              children: [
                const TextSpan(text: 'Requested: '),
                TextSpan(
                  text: asset.assetName.isEmpty
                      ? asset.assetCode
                      : asset.assetName,
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            asset.statusLabel,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
