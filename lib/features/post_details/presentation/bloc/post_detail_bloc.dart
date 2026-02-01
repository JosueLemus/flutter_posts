import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_comments_usecase.dart';
import 'post_detail_event.dart';
import 'post_detail_state.dart';

class PostDetailBloc extends Bloc<PostDetailEvent, PostDetailState> {
  final GetCommentsUseCase getCommentsUseCase;

  PostDetailBloc({required this.getCommentsUseCase})
    : super(const PostDetailState()) {
    on<LoadPostDetail>(_onLoadPostDetail);
  }

  Future<void> _onLoadPostDetail(
    LoadPostDetail event,
    Emitter<PostDetailState> emit,
  ) async {
    emit(
      state.copyWith(post: event.post, isLoadingComments: true, error: null),
    );
    try {
      final comments = await getCommentsUseCase(event.post.id);
      emit(state.copyWith(comments: comments, isLoadingComments: false));
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingComments: false,
          error: 'Failed to load comments',
        ),
      );
    }
  }
}
