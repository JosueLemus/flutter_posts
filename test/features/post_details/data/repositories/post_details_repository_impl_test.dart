import 'package:flutter_posts/features/post_details/data/datasources/post_details_remote_datasource.dart';
import 'package:flutter_posts/features/post_details/data/models/comment_model.dart';
import 'package:flutter_posts/features/post_details/data/repositories/post_details_repository_impl.dart';
import 'package:flutter_posts/features/post_details/domain/entities/comment.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPostDetailsRemoteDataSource extends Mock
    implements PostDetailsRemoteDataSource {}

void main() {
  late PostDetailsRepositoryImpl repository;
  late MockPostDetailsRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockPostDetailsRemoteDataSource();
    repository = PostDetailsRepositoryImpl(remoteDataSource: mockDataSource);
  });

  group('getComments', () {
    const postId = 1;
    final commentModels = [
      CommentModel(
        postId: 1,
        id: 1,
        name: 'Test Comment',
        email: 'test@example.com',
        body: 'Test body',
      ),
    ];

    test('should return list of Comment entities when successful', () async {
      when(
        () => mockDataSource.getComments(postId),
      ).thenAnswer((_) async => commentModels);

      final result = await repository.getComments(postId);

      expect(result, isA<List<Comment>>());
      expect(result.length, 1);
      expect(result.first.name, 'Test Comment');
      verify(() => mockDataSource.getComments(postId)).called(1);
    });

    test('should throw exception when datasource fails', () async {
      when(
        () => mockDataSource.getComments(postId),
      ).thenThrow(Exception('Network error'));

      expect(() => repository.getComments(postId), throwsException);
    });
  });
}
