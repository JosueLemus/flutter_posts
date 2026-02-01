import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_posts_usecase.dart';
import 'posts_event.dart';
import 'posts_state.dart';

class PostsBloc extends Bloc<PostsEvent, PostsState> {
  final GetPostsUseCase getPostsUseCase;
  int _currentPage = 1;
  static const int _limit = 10;
  bool _isFetching = false;

  PostsBloc({required this.getPostsUseCase}) : super(PostsInitial()) {
    on<FetchPosts>(_onFetchPosts);
    on<RefreshPosts>(_onRefreshPosts);
  }

  Future<void> _onFetchPosts(FetchPosts event, Emitter<PostsState> emit) async {
    if (_isFetching) return;
    if (state is PostsLoaded && (state as PostsLoaded).hasReachedMax) return;

    try {
      if (state is PostsInitial || state is PostsError) {
        _currentPage = 1;
        emit(PostsLoading());
        final posts = await getPostsUseCase(page: _currentPage, limit: _limit);
        emit(PostsLoaded(posts, hasReachedMax: posts.length < _limit));
        _currentPage++;
      } else if (state is PostsLoaded) {
        _isFetching = true;
        final loadedState = state as PostsLoaded;
        final newPosts = await getPostsUseCase(
          page: _currentPage,
          limit: _limit,
        );

        _isFetching = false;

        if (newPosts.isEmpty) {
          emit(loadedState.copyWith(hasReachedMax: true));
        } else {
          emit(
            PostsLoaded(
              loadedState.posts + newPosts,
              hasReachedMax: newPosts.length < _limit,
            ),
          );
          _currentPage++;
        }
      }
    } catch (e) {
      _isFetching = false;
      emit(PostsError(e.toString()));
    }
  }

  Future<void> _onRefreshPosts(
    RefreshPosts event,
    Emitter<PostsState> emit,
  ) async {
    try {
      _currentPage = 1;
      _isFetching = true;
      final posts = await getPostsUseCase(page: _currentPage, limit: _limit);
      _isFetching = false;
      emit(PostsLoaded(posts, hasReachedMax: posts.length < _limit));
      _currentPage++;
    } catch (e) {
      _isFetching = false;
      emit(PostsError(e.toString()));
    }
  }
}
