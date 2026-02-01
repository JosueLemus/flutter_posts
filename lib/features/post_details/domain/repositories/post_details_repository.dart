import '../entities/comment.dart';

abstract class PostDetailsRepository {
  Future<List<Comment>> getComments(int postId);
}
