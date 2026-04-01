import '../../domain/models/post_model.dart';

abstract class PostState {}

class PostInitial extends PostState {}

class PostLoading extends PostState {}

class PostLoaded extends PostState {
  final List<PostModel> posts;
  final bool hasMore;

  PostLoaded(this.posts, this.hasMore);
}

class PostDetailLoaded extends PostState {
  final PostModel post;
  PostDetailLoaded(this.post);
}

/// Emitted after a post is created (and optionally published) successfully.
class PostCreated extends PostState {
  final PostModel post;
  PostCreated(this.post);
}

class PostError extends PostState {
  final String message;

  PostError(this.message);
}