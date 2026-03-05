abstract class PostEvent {}

class FetchPosts extends PostEvent {}

class LoadMorePosts extends PostEvent {}

class MarkPostAsRead extends PostEvent {
  final int postId;

  MarkPostAsRead(this.postId);
}

class CreatePostEvent extends PostEvent {
  final String title;
  final String description;
  final String category;

  CreatePostEvent({
    required this.title,
    required this.description,
    required this.category,
  });
}