import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/billing/theme/billing_theme.dart';

class MediaPickerCard extends StatefulWidget {
  final String title;
  final String? url;
  final ValueChanged<XFile> onUploaded;
  final String? helperText;
  final BoxDecoration? decoration;

  const MediaPickerCard({
    super.key,
    required this.title,
    required this.url,
    required this.onUploaded,
    this.helperText,
    this.decoration,
  });

  @override
  State<MediaPickerCard> createState() => _MediaPickerCardState();
}

class _MediaPickerCardState extends State<MediaPickerCard> {
  Uint8List? _pickedBytes;
  String? _bytesSourceHint;

  @override
  void didUpdateWidget(covariant MediaPickerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _pickedBytes = null;
      _bytesSourceHint = null;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    if (!mounted) return;

    setState(() {
      _pickedBytes = bytes;
      _bytesSourceHint = picked.name;
    });

    widget.onUploaded(picked);
  }

  Widget _preview() {
    final url = widget.url;
    final hasUrl = url != null && url.isNotEmpty;

    if (!hasUrl && _pickedBytes == null) {
      return const Icon(
        Icons.add_a_photo_outlined,
        color: Color(0xFF74777F),
      );
    }

    if (hasUrl && url.startsWith("http")) {
      return Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return const Icon(
            Icons.image_not_supported_outlined,
            color: Color(0xFF74777F),
          );
        },
      );
    }

    if (_pickedBytes != null) {
      return Image.memory(
        _pickedBytes!,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return const Icon(
            Icons.image_not_supported_outlined,
            color: Color(0xFF74777F),
          );
        },
      );
    }

    return FutureBuilder<Uint8List>(
      future: XFile(url ?? '').readAsBytes(),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null || snapshot.hasError) {
          return const Icon(
            Icons.image_not_supported_outlined,
            color: Color(0xFF74777F),
          );
        }
        return Image.memory(bytes, fit: BoxFit.contain);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 840;

    final Color inkColor = wide ? const Color(0xFF1A1C1E) : const Color(0xFF8D5B39);
    final Color accentColor = wide ? BillingTheme.purple : const Color(0xFFB14D1E);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: widget.decoration ?? BoxDecoration(
        color: BillingTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BillingTheme.border),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            widget.title,
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: inkColor,
            ),
          ),
          if ((widget.helperText ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              widget.helperText!,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF74777F),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 12),
          _DashedBorder(
            color: accentColor.withOpacity(0.3),
            radius: 14,
            strokeWidth: 1.6,
            dash: 6,
            gap: 5,
            child: Container(
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                color: wide ? BillingTheme.scaffoldBg : const Color(0xFFFFFDFB),
                borderRadius: BorderRadius.circular(14),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Center(child: _preview()),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if ((_bytesSourceHint ?? "").isNotEmpty)
            Text(
              _bytesSourceHint!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Color(0xFF74777F)),
            ),
          TextButton(
            onPressed: _pickImage,
            child: Text(
              "Change",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final double strokeWidth;
  final double radius;
  final double dash;
  final double gap;

  const _DashedBorder({
    required this.child,
    required this.color,
    required this.strokeWidth,
    required this.radius,
    required this.dash,
    required this.gap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: color,
        strokeWidth: strokeWidth,
        radius: radius,
        dash: dash,
        gap: gap,
      ),
      child: Padding(
        padding: EdgeInsets.all(strokeWidth),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: child,
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final double dash;
  final double gap;

  const _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
    required this.dash,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final metric = metrics.first;
    double dist = 0;
    while (dist < metric.length) {
      final next = dist + dash;
      canvas.drawPath(metric.extractPath(dist, next.clamp(0, metric.length)), paint);
      dist = next + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius ||
        oldDelegate.dash != dash ||
        oldDelegate.gap != gap;
  }
}