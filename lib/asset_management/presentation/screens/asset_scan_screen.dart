import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../repository/asset_repository.dart';
import '../../theme/asset_theme.dart';
import 'asset_detail_screen.dart';

/// QR scan + manual code entry. Camera uses [mobile_scanner] on mobile;
/// web/desktop fall back to manual entry.
class AssetScanScreen extends StatefulWidget {
  const AssetScanScreen({
    super.key,
    this.useMobileTheme = true,
    this.embedded = false,
  });

  final bool useMobileTheme;
  /// When true, omit [Scaffold]/[AppBar] so the screen can live inside a shell tab.
  final bool embedded;

  @override
  State<AssetScanScreen> createState() => _AssetScanScreenState();
}

class _AssetScanScreenState extends State<AssetScanScreen> {
  final _repo = AssetRepository();
  final _manualCtrl = TextEditingController();
  MobileScannerController? _camera;
  bool _handling = false;
  String? _error;

  bool get _canUseCamera =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  void initState() {
    super.initState();
    if (_canUseCamera) {
      _camera = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
      );
    }
  }

  @override
  void dispose() {
    _manualCtrl.dispose();
    _camera?.dispose();
    super.dispose();
  }

  String? _normalizeCode(String raw) {
    var code = raw.trim();
    if (code.isEmpty) return null;
    // Accept full URLs that end with AST-xxxxxx
    final match = RegExp(r'(AST-\d+)', caseSensitive: false).firstMatch(code);
    if (match != null) return match.group(1)!.toUpperCase();
    if (code.toUpperCase().startsWith('AST-')) return code.toUpperCase();
    return code.toUpperCase();
  }

  Future<void> _onCode(String raw) async {
    if (_handling) return;
    final code = _normalizeCode(raw);
    if (code == null) return;

    setState(() {
      _handling = true;
      _error = null;
    });

    try {
      final asset = await _repo.scanAsset(code);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AssetDetailScreen(
            assetCode: asset.assetCode,
            initialAsset: asset,
            useMobileTheme: widget.useMobileTheme,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _handling = false);
    }
  }

  /// Compact scan window so keyboard + manual entry fit on small phones.
  double _scanSize(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final available = size.height - keyboard;
    if (keyboard > 0) {
      return (available * 0.22).clamp(96.0, 140.0);
    }
    if (size.height < 700) {
      return (size.shortestSide * 0.42).clamp(120.0, 168.0);
    }
    return (size.shortestSide * 0.48).clamp(140.0, 200.0);
  }

  @override
  Widget build(BuildContext context) {
    final mint = !widget.useMobileTheme;
    final bg = mint ? AssetDesktopTheme.shellMint : AssetMobileTheme.cream;
    final accent =
        mint ? AssetDesktopTheme.teal : AssetMobileTheme.terracotta;
    final scanSize = _scanSize(context);

    final body = Column(
      children: [
        if (_canUseCamera)
          Expanded(
            child: ColoredBox(
              color: Colors.black.withValues(alpha: 0.04),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Align QR inside the frame',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AssetMobileTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: scanSize,
                      height: scanSize,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            MobileScanner(
                              controller: _camera,
                              onDetect: (capture) {
                                final barcodes = capture.barcodes;
                                if (barcodes.isEmpty) return;
                                final value = barcodes.first.rawValue;
                                if (value != null) _onCode(value);
                              },
                            ),
                            IgnorePointer(
                              child: CustomPaint(
                                painter: _ScanFramePainter(color: accent),
                              ),
                            ),
                            if (_handling)
                              Container(
                                color: Colors.black45,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Camera scanning is available on Android & iOS.\n'
                  'Enter an asset code below on this device.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ),
          ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.viewInsetsOf(context).bottom.clamp(0, 24),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: widget.embedded
                ? BorderRadius.zero
                : const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Or enter asset code',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _manualCtrl,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: 'AST-000123',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        isDense: true,
                      ),
                      onSubmitted: _onCode,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed:
                        _handling ? null : () => _onCode(_manualCtrl.text),
                    style: FilledButton.styleFrom(backgroundColor: accent),
                    child: Text(
                      'Go',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );

    if (widget.embedded) {
      return ColoredBox(color: bg, child: body);
    }

    return Scaffold(
      backgroundColor: bg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: mint ? Colors.white : AssetMobileTheme.terracotta,
        foregroundColor: mint ? AssetDesktopTheme.textDark : Colors.white,
        elevation: 0,
        title: Text(
          'Scan asset QR',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
      ),
      body: body,
    );
  }
}

class _ScanFramePainter extends CustomPainter {
  _ScanFramePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 22.0;
    final w = size.width;
    final h = size.height;

    // Top-left
    canvas.drawLine(const Offset(0, len), Offset.zero, paint);
    canvas.drawLine(Offset.zero, const Offset(len, 0), paint);
    // Top-right
    canvas.drawLine(Offset(w - len, 0), Offset(w, 0), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, len), paint);
    // Bottom-left
    canvas.drawLine(Offset(0, h - len), Offset(0, h), paint);
    canvas.drawLine(Offset(0, h), Offset(len, h), paint);
    // Bottom-right
    canvas.drawLine(Offset(w - len, h), Offset(w, h), paint);
    canvas.drawLine(Offset(w, h - len), Offset(w, h), paint);
  }

  @override
  bool shouldRepaint(covariant _ScanFramePainter oldDelegate) =>
      oldDelegate.color != color;
}
