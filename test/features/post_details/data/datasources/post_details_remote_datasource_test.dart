import 'package:dio/dio.dart';
import 'package:flutter_posts/core/network/dio_client.dart';
import 'package:flutter_posts/features/post_details/data/datasources/post_details_remote_datasource.dart';
import 'package:flutter_posts/features/post_details/data/models/comment_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDioClient extends Mock implements DioClient {}

class MockDio extends Mock implements Dio {}

void main() {
  late PostDetailsRemoteDataSourceImpl dataSource;
  late MockDioClient mockDioClient;
  late MockDio mockDio;

  setUp(() {
    mockDioClient = MockDioClient();
    mockDio = MockDio();
    when(() => mockDioClient.dio).thenReturn(mockDio);
    dataSource = PostDetailsRemoteDataSourceImpl(dioClient: mockDioClient);
    registerFallbackValue(RequestOptions(path: ''));
  });

  group('getComments', () {
    const postId = 1;
    final commentsJson = [
      {
        'postId': 1,
        'id': 1,
        'name': 'Test Comment',
        'email': 'test@example.com',
        'body': 'Test body',
      },
    ];

    test('should return list of CommentModel when successful', () async {
      when(() => mockDio.get('/posts/$postId/comments')).thenAnswer(
        (_) async => Response(
          data: commentsJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/posts/$postId/comments'),
        ),
      );

      final result = await dataSource.getComments(postId);

      expect(result, isA<List<CommentModel>>());
      expect(result.length, 1);
      expect(result.first.name, 'Test Comment');
      verify(() => mockDio.get('/posts/$postId/comments')).called(1);
    });

    test('should throw exception when request fails', () async {
      when(() => mockDio.get('/posts/$postId/comments')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/posts/$postId/comments'),
          error: 'Network error',
        ),
      );

      expect(() => dataSource.getComments(postId), throwsException);
    });
  });
}
