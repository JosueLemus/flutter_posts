import 'dart:async';

import '../../../posts/domain/entities/post.dart';

abstract class PostDetailEvent {}

class LoadPostDetail extends PostDetailEvent {
  final Post post;

  LoadPostDetail(this.post);
}

class RefreshComments extends PostDetailEvent {
  final int postId;
  final Completer? completer;

  RefreshComments(this.postId, [this.completer]);
}
