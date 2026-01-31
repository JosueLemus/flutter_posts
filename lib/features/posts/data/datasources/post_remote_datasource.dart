import '../../../../core/network/dio_client.dart';
import '../models/post_model.dart';

abstract class PostRemoteDataSource {
  Future<List<PostModel>> getPosts({int page = 1, int limit = 10});
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final DioClient dioClient;

  PostRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<PostModel>> getPosts({int page = 1, int limit = 10}) async {
    try {
      final response = await dioClient.dio.get(
        '/posts',
        queryParameters: {'_page': page, '_limit': limit},
      );
      final List<dynamic> data = response.data;
      return data.map((json) => PostModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load posts');
    }
  }
}
