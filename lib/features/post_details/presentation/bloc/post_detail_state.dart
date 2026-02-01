import '../../../posts/domain/entities/post.dart';
import '../../domain/entities/comment.dart';

class PostDetailState {
  final Post? post;
  final List<Comment> comments;
  final bool isLoadingComments;
  final String? error;

  const PostDetailState({
    this.post,
    this.comments = const [],
    this.isLoadingComments = false,
    this.error,
  });

  PostDetailState copyWith({
    Post? post,
    List<Comment>? comments,
    bool? isLoadingComments,
    String? error,
  }) {
    return PostDetailState(
      post: post ?? this.post,
      comments: comments ?? this.comments,
      isLoadingComments: isLoadingComments ?? this.isLoadingComments,
      error: error ?? this.error,
    );
  }
}
