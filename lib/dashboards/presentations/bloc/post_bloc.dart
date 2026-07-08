import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/dashboards/domain/models/post_model.dart';
import 'package:my_app/dashboards/domain/models/post_sort.dart';
import 'package:my_app/dashboards/domain/repository/post_repository.dart';
import 'post_event.dart';
import 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository repository;

  int currentPage = 1;
  bool hasMore = true;

  List<PostModel> posts = [];

  String? _lastCategory;
  bool _lastMine = false;
  int? _lastPageSize;

  PostBloc(this.repository) : super(PostInitial()) {
    on<FetchPosts>(_onFetchPosts);
    on<LoadMorePosts>(_onLoadMore);
    on<MarkPostAsRead>(_onMarkRead);
    on<CreatePostEvent>(_onCreatePost);   // REGISTER EVENT
    on<FetchPostById>(_onFetchPostById);
    on<PublishPostRequested>(_onPublish);
  }

  Future<void> _onFetchPosts(
      FetchPosts event, Emitter<PostState> emit) async {
    emit(PostLoading());

    try {
      currentPage = 1;
      _lastCategory = event.category;
      _lastMine = event.mine;
      _lastPageSize = event.pageSize;

      final List<PostModel> fetchedPosts =
      await repository.fetchPosts(
        page: currentPage,
        category: event.category,
        pageSize: event.pageSize,
        mine: event.mine,
      );

      posts = sortPostsNewestFirst(fetchedPosts);

      final pageSize = event.pageSize ?? 10;
      hasMore = fetchedPosts.length == pageSize;

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
      await repository.fetchPosts(
        page: currentPage,
        category: event.category,
        pageSize: event.pageSize,
        mine: event.mine,
      );

      posts = sortPostsNewestFirst([...posts, ...newPosts]);

      final pageSize = event.pageSize ?? 10;
      hasMore = newPosts.length == pageSize;

      emit(PostLoaded(posts, hasMore));
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<void> _onMarkRead(
      MarkPostAsRead event, Emitter<PostState> emit) async {
    await repository.markAsRead(event.postId);
    // Update UI immediately if we have a loaded list.
    final s = state;
    if (s is PostLoaded) {
      final updated = s.posts
          .map((p) => p.id == event.postId ? _markRead(p) : p)
          .toList(growable: false);
      posts = List<PostModel>.from(updated);
      emit(PostLoaded(sortPostsNewestFirst(updated), s.hasMore));
    }
  }

  PostModel _markRead(PostModel p) => p.copyWith(isRead: true);

  Future<void> _onCreatePost(
      CreatePostEvent event,
      Emitter<PostState> emit,
      ) async {
    try {
      final created = await repository.createPost(
        title: event.title,
        link: event.link,
        content: event.content,
        category: event.category,
        isAllUsers: event.isAllUsers,
        targetDepartments: event.departmentIds,
        targetDesignations: event.designationIds,
        targetUsers: event.userIds,
        attachments: event.attachments,
      );

      if (event.publishAfterCreate) {
        await repository.publish(created.id);
      }

      emit(PostCreated(created));
      add(
        FetchPosts(
          category: _lastCategory ?? event.category,
          mine: _lastMine,
          pageSize: _lastPageSize ?? 30,
        ),
      );
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<void> _onFetchPostById(
    FetchPostById event,
    Emitter<PostState> emit,
  ) async {
    try {
      final post = await repository.fetchPostById(event.postId);
      posts = posts
          .map((p) => p.id == post.id ? post : p)
          .toList(growable: false);
      emit(PostDetailLoaded(post));
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<void> _onPublish(
    PublishPostRequested event,
    Emitter<PostState> emit,
  ) async {
    try {
      await repository.publish(event.postId);
      add(
        FetchPosts(
          category: _lastCategory,
          mine: _lastMine,
          pageSize: _lastPageSize ?? 30,
        ),
      );
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }
}