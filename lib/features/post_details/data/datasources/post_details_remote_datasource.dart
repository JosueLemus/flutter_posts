import '../../../../core/network/dio_client.dart';
import '../models/comment_model.dart';

abstract class PostDetailsRemoteDataSource {
  Future<List<CommentModel>> getComments(int postId);
}

class PostDetailsRemoteDataSourceImpl implements PostDetailsRemoteDataSource {
  final DioClient dioClient;

  PostDetailsRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<CommentModel>> getComments(int postId) async {
    try {
      final response = await dioClient.dio.get('/posts/$postId/comments');
      final List<dynamic> data = response.data;
      return data.map((json) => CommentModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load comments');
    }
  }
}
