import '../entities/post.dart';
import '../repositories/post_repository.dart';

class GetPostsUseCase {
  final PostRepository repository;

  GetPostsUseCase(this.repository);

  Future<List<Post>> call({int page = 1, int limit = 10}) async {
    return await repository.getPosts(page: page, limit: limit);
  }
}
