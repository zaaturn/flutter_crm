import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_app/dashboards/domain/models/post_seen_by_viewer.dart';
import 'package:my_app/dashboards/domain/repository/post_repository.dart';
import 'package:my_app/dashboards/widgets/app_color.dart';

class AdminSeenByScreen extends StatelessWidget {
  final int postId;
  const AdminSeenByScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<PostRepository>();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Seen by',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: FutureBuilder<List<PostSeenByViewer>>(
        future: repo.fetchSeenBy(postId),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snap.data!;
          if (list.isEmpty) {
            return const Center(
              child: Text(
                'No one has seen this yet.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final v = list[i];
              final ago = formatPostViewTimeAgo(v.readAt);
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.cyanLight,
                      child: Text(
                        v.fullName.isNotEmpty
                            ? v.fullName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppColors.cyan,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            v.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (ago.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              ago,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(Icons.visibility_rounded,
                        color: AppColors.textMuted),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
