import '../entities/post.dart';
import '../repositories/post_repository.dart';

class GetPostsUseCase {
  final PostRepository repository;

  GetPostsUseCase(this.repository);

  Future<List<Post>> call() async {
    return await repository.getPosts();
  }
}
