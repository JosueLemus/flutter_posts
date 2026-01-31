import '../../domain/entities/post.dart';

abstract class PostsState {}

class PostsInitial extends PostsState {}

class PostsLoading extends PostsState {}

class PostsLoaded extends PostsState {
  final List<Post> posts;
  final bool hasReachedMax;

  PostsLoaded(this.posts, {this.hasReachedMax = false});

  PostsLoaded copyWith({List<Post>? posts, bool? hasReachedMax}) {
    return PostsLoaded(
      posts ?? this.posts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class PostsError extends PostsState {
  final String message;

  PostsError(this.message);
}
