import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_posts_usecase.dart';
import 'posts_event.dart';
import 'posts_state.dart';

class PostsBloc extends Bloc<PostsEvent, PostsState> {
  final GetPostsUseCase getPostsUseCase;

  PostsBloc({required this.getPostsUseCase}) : super(PostsInitial()) {
    on<FetchPosts>((event, emit) async {
      emit(PostsLoading());
      try {
        final posts = await getPostsUseCase();
        emit(PostsLoaded(posts));
      } catch (e) {
        emit(PostsError(e.toString()));
      }
    });
  }
}
