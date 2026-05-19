import 'package:flutter/material.dart';
import 'package:my_app/event_management/features/events/domain/entities/event.dart';
import 'package:my_app/event_management/shared/themes/app_theme.dart';

/// Compact avatar stack for selected guests (+N overflow).
class EventGuestAvatarRow extends StatelessWidget {
  final List<Participant> participants;

  const EventGuestAvatarRow({super.key, required this.participants});

  @override
  Widget build(BuildContext context) {
    if (participants.isEmpty) {
      return Text(
        'Add',
        style: TextStyle(
          color: AppTheme.primaryBlue,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    const maxShow = 3;
    final show = participants.take(maxShow).toList();
    final extra = participants.length - show.length;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...show.asMap().entries.map((e) {
          final i = e.key;
          final p = e.value;
          return Transform.translate(
            offset: Offset(-6.0 * i, 0),
            child: _avatar(p),
          );
        }),
        if (extra > 0)
          Transform.translate(
            offset: Offset(-6.0 * show.length, 0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.borderLight,
              child: Text(
                '+$extra',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ),
        const SizedBox(width: 4),
        Icon(Icons.chevron_right_rounded, color: AppTheme.textHint, size: 22),
      ],
    );
  }

  Widget _avatar(Participant p) {
    final url = p.avatar;
    if (url != null && url.isNotEmpty) {
      return CircleAvatar(
        radius: 16,
        backgroundColor: AppTheme.borderLight,
        backgroundImage: NetworkImage(url),
        onBackgroundImageError: (_, __) {},
        child: null,
      );
    }
    final initial =
        p.username.isNotEmpty ? p.username[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: 16,
      backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.12),
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryBlue,
        ),
      ),
    );
  }
}
