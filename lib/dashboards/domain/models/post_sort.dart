import 'package:my_app/dashboards/domain/models/post_model.dart';

/// Newest posts first. Pinned posts keep a badge but do not bury fresh posts.
List<PostModel> sortPostsNewestFirst(List<PostModel> posts) {
  final list = List<PostModel>.from(posts);
  list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return list;
}
