import '../entities/comment.dart';
import '../repositories/post_details_repository.dart';

class GetCommentsUseCase {
  final PostDetailsRepository repository;

  GetCommentsUseCase(this.repository);

  Future<List<Comment>> call(int postId) async {
    return await repository.getComments(postId);
  }
}
