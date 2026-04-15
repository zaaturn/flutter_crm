import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/billing/theme/billing_theme.dart';

class MediaPickerCard extends StatefulWidget {
  final String title;
  final String? url;
  final ValueChanged<XFile> onUploaded;
  final String? helperText;

  const MediaPickerCard({
    super.key,
    required this.title,
    required this.url,
    required this.onUploaded,
    this.helperText,
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
    // If the source url changes (e.g. after save), clear local preview bytes.
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
        color: Colors.grey,
      );
    }

    if (hasUrl && url.startsWith("http")) {
      return Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return const Icon(
            Icons.image_not_supported_outlined,
            color: Colors.grey,
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
            color: Colors.grey,
          );
        },
      );
    }

    // Fallback: try to load bytes from local path/blob URL.
    return FutureBuilder<Uint8List>(
      future: XFile(url ?? '').readAsBytes(),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null || snapshot.hasError) {
          return const Icon(
            Icons.image_not_supported_outlined,
            color: Colors.grey,
          );
        }
        return Image.memory(bytes, fit: BoxFit.contain);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BillingTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BillingTheme.border),
        boxShadow: [
          BoxShadow(
            color: BillingTheme.purple.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          if ((widget.helperText ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              widget.helperText!,
              style: const TextStyle(fontSize: 11, color: BillingTheme.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 12),

          _DashedBorder(
            color: BillingTheme.purple.withValues(alpha: 0.55),
            radius: 14,
            strokeWidth: 1.6,
            dash: 6,
            gap: 5,
            child: Container(
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                color: BillingTheme.scaffoldBg,
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
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),

          TextButton(
            onPressed: _pickImage,
            child: const Text(
              "Change",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
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
