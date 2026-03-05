import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/dashboards/domain/models/post_model.dart';
import 'package:my_app/dashboards/domain/repository/post_repository.dart';
import 'post_event.dart';
import 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository repository;

  int currentPage = 1;
  bool hasMore = true;

  List<PostModel> posts = [];

  PostBloc(this.repository) : super(PostInitial()) {
    on<FetchPosts>(_onFetchPosts);
    on<LoadMorePosts>(_onLoadMore);
    on<MarkPostAsRead>(_onMarkRead);
    on<CreatePostEvent>(_onCreatePost);   // REGISTER EVENT
  }

  Future<void> _onFetchPosts(
      FetchPosts event, Emitter<PostState> emit) async {
    emit(PostLoading());

    try {
      currentPage = 1;

      final List<PostModel> fetchedPosts =
      await repository.fetchPosts(page: currentPage);

      posts = fetchedPosts;

      hasMore = fetchedPosts.length == 10;

      emit(PostLoaded(posts, hasMore));
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<void> _onLoadMore(
      LoadMorePosts event, Emitter<PostState> emit) async {
    if (!hasMore) return;

    try {
      currentPage++;

      final List<PostModel> newPosts =
      await repository.fetchPosts(page: currentPage);

      posts.addAll(newPosts);

      hasMore = newPosts.length == 10;

      emit(PostLoaded(posts, hasMore));
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<void> _onMarkRead(
      MarkPostAsRead event, Emitter<PostState> emit) async {
    await repository.markAsRead(event.postId);
  }

  Future<void> _onCreatePost(
      CreatePostEvent event,
      Emitter<PostState> emit,
      ) async {
    try {
      await repository.createPost(
        caption: event.title,
        link: event.description,
        category: event.category,
      );

      add(FetchPosts()); // refresh posts after creating
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }
}