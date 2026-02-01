import '../../../posts/domain/entities/post.dart';
import '../../domain/entities/comment.dart';

class PostDetailState {
  final Post? post;
  final List<Comment> comments;
  final bool isLoadingComments;
  final bool isLiked;
  final String? error;

  const PostDetailState({
    this.post,
    this.comments = const [],
    this.isLoadingComments = false,
    this.isLiked = false,
    this.error,
  });

  PostDetailState copyWith({
    Post? post,
    List<Comment>? comments,
    bool? isLoadingComments,
    bool? isLiked,
    String? error,
  }) {
    return PostDetailState(
      post: post ?? this.post,
      comments: comments ?? this.comments,
      isLoadingComments: isLoadingComments ?? this.isLoadingComments,
      isLiked: isLiked ?? this.isLiked,
      error: error ?? this.error,
    );
  }
}
