import '../../../posts/domain/entities/post.dart';

abstract class PostDetailEvent {}

class LoadPostDetail extends PostDetailEvent {
  final Post post;

  LoadPostDetail(this.post);
}
