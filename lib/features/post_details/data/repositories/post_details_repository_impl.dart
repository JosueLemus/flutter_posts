import '../../domain/entities/comment.dart';
import '../../domain/repositories/post_details_repository.dart';
import '../datasources/post_details_remote_datasource.dart';

class PostDetailsRepositoryImpl implements PostDetailsRepository {
  final PostDetailsRemoteDataSource remoteDataSource;

  PostDetailsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Comment>> getComments(int postId) async {
    return await remoteDataSource.getComments(postId);
  }
}
