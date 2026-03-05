import '../../domain/models/post_model.dart';

abstract class PostState {}

class PostInitial extends PostState {}

class PostLoading extends PostState {}

class PostLoaded extends PostState {
  final List<PostModel> posts;
  final bool hasMore;

  PostLoaded(this.posts, this.hasMore);
}

class PostError extends PostState {
  final String message;

  PostError(this.message);
}