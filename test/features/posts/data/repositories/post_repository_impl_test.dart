import 'package:flutter_posts/features/posts/data/datasources/post_remote_datasource.dart';
import 'package:flutter_posts/features/posts/data/models/post_model.dart';
import 'package:flutter_posts/features/posts/data/repositories/post_repository_impl.dart';
import 'package:flutter_posts/features/posts/domain/entities/post.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPostRemoteDataSource extends Mock implements PostRemoteDataSource {}

void main() {
  late PostRepositoryImpl repository;
  late MockPostRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockPostRemoteDataSource();
    repository = PostRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  group('getPosts', () {
    const tPostModel = PostModel(id: 1, title: 'test title', body: 'test body');
    const List<PostModel> tPostModelList = [tPostModel];
    const List<Post> tPostList = [tPostModel];

    test(
      'should return list of Posts from datasource when call is successful',
      () async {
        when(
          () => mockRemoteDataSource.getPosts(
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => tPostModelList);

        final result = await repository.getPosts(page: 1, limit: 10);

        expect(result, equals(tPostList));
        verify(
          () => mockRemoteDataSource.getPosts(page: 1, limit: 10),
        ).called(1);
      },
    );

    test('should propagate exception when datasource fails', () async {
      when(
        () => mockRemoteDataSource.getPosts(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(Exception('Failed to load posts'));

      final call = repository.getPosts;

      expect(() => call(page: 1, limit: 10), throwsA(isA<Exception>()));
    });
  });
}
