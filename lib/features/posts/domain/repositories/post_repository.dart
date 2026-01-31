import '../entities/post.dart';

abstract class PostRepository {
  Future<List<Post>> getPosts({int page = 1, int limit = 10});
}
