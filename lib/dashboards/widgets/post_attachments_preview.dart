import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/dashboards/domain/models/post_attachment.dart';
import 'package:my_app/dashboards/widgets/post_media_utils.dart';

typedef PostAttachmentTap = void Function(PostAttachment attachment);

/// Feed-style preview for one or more image/video attachments on a post card.
class PostAttachmentsPreview extends StatelessWidget {
  const PostAttachmentsPreview({
    super.key,
    required this.attachments,
    this.onTap,
    this.borderRadius = 0,
    this.gap = 4,
    this.singleAspectRatio = 16 / 9,
  });

  final List<PostAttachment> attachments;
  final PostAttachmentTap? onTap;
  final double borderRadius;
  final double gap;
  final double singleAspectRatio;

  List<PostAttachment> get _visualAttachments => attachments
      .where(
        (a) => postAttachmentIsImage(a) || postAttachmentIsVideo(a),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    final visuals = _visualAttachments;
    if (visuals.isEmpty) return const SizedBox.shrink();

    if (visuals.length == 1) {
      return AspectRatio(
        aspectRatio: singleAspectRatio,
        child: _MediaTile(
          attachment: visuals.first,
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      );
    }

    if (visuals.length == 2) {
      return SizedBox(
        height: 220,
        width: double.infinity,
        child: Row(
          children: [
            Expanded(
              child: _MediaTile(
                attachment: visuals[0],
                onTap: onTap,
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(borderRadius),
                ),
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: _MediaTile(
                attachment: visuals[1],
                onTap: onTap,
                borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(borderRadius),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 240,
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _MediaTile(
              attachment: visuals[0],
              onTap: onTap,
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(borderRadius),
              ),
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _MediaTile(
                    attachment: visuals[1],
                    onTap: onTap,
                  ),
                ),
                SizedBox(height: gap),
                Expanded(
                  child: _MediaTile(
                    attachment: visuals[2],
                    onTap: onTap,
                    overlayLabel:
                        visuals.length > 3 ? '+${visuals.length - 3}' : null,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(borderRadius),
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

class _MediaTile extends StatelessWidget {
  const _MediaTile({
    required this.attachment,
    this.onTap,
    this.borderRadius,
    this.overlayLabel,
  });

  final PostAttachment attachment;
  final PostAttachmentTap? onTap;
  final BorderRadiusGeometry? borderRadius;
  final String? overlayLabel;

  @override
  Widget build(BuildContext context) {
    final url = attachment.resolvedUrl;
    final isVideo = postAttachmentIsVideo(attachment);

    final media = ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: ColoredBox(
        color: isVideo ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (isVideo)
              const Center(
                child: Icon(
                  Icons.play_circle_fill_rounded,
                  size: 56,
                  color: Colors.white,
                ),
              )
            else
              Image.network(
                url,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image_outlined),
                ),
              ),
            if (overlayLabel != null)
              Container(
                color: Colors.black.withValues(alpha: 0.45),
                alignment: Alignment.center,
                child: Text(
                  overlayLabel!,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (onTap == null) return media;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => onTap!(attachment),
        child: media,
      ),
    );
  }
}

/// Horizontal gallery for post detail screens.
class PostAttachmentsGallery extends StatefulWidget {
  const PostAttachmentsGallery({
    super.key,
    required this.attachments,
    this.height = 320,
    this.onTap,
  });

  final List<PostAttachment> attachments;
  final double height;
  final PostAttachmentTap? onTap;

  @override
  State<PostAttachmentsGallery> createState() => _PostAttachmentsGalleryState();
}

class _PostAttachmentsGalleryState extends State<PostAttachmentsGallery> {
  final _controller = PageController();
  int _index = 0;

  List<PostAttachment> get _visualAttachments => widget.attachments
      .where(
        (a) => postAttachmentIsImage(a) || postAttachmentIsVideo(a),
      )
      .toList();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visuals = _visualAttachments;
    if (visuals.isEmpty) return const SizedBox.shrink();

    if (visuals.length == 1) {
      return SizedBox(
        height: widget.height,
        width: double.infinity,
        child: _MediaTile(
          attachment: visuals.first,
          onTap: widget.onTap,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: widget.height,
          width: double.infinity,
          child: PageView.builder(
            controller: _controller,
            itemCount: visuals.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              return _MediaTile(
                attachment: visuals[i],
                onTap: widget.onTap,
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(visuals.length, (i) {
            final active = i == _index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: active ? 18 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFF059669)
                    : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),
      ],
    );
  }
}
