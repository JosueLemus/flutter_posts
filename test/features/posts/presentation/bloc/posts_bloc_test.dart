import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_posts/features/posts/domain/entities/post.dart';
import 'package:flutter_posts/features/posts/domain/usecases/get_posts_usecase.dart';
import 'package:flutter_posts/features/posts/presentation/bloc/posts_bloc.dart';
import 'package:flutter_posts/features/posts/presentation/bloc/posts_event.dart';
import 'package:flutter_posts/features/posts/presentation/bloc/posts_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetPostsUseCase extends Mock implements GetPostsUseCase {}

void main() {
  late PostsBloc postsBloc;
  late MockGetPostsUseCase mockGetPostsUseCase;

  setUp(() {
    mockGetPostsUseCase = MockGetPostsUseCase();
    postsBloc = PostsBloc(getPostsUseCase: mockGetPostsUseCase);
  });

  group('PostsBloc', () {
    const tPost = Post(id: 1, title: 'test', body: 'test body');
    const tPosts = [tPost];

    test('initial state is PostsInitial', () {
      expect(postsBloc.state, isA<PostsInitial>());
    });

    blocTest<PostsBloc, PostsState>(
      'emits [PostsLoading, PostsLoaded] when FetchPosts is added',
      build: () {
        when(
          () => mockGetPostsUseCase(
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => tPosts);
        return postsBloc;
      },
      act: (bloc) => bloc.add(FetchPosts()),
      expect: () => [
        isA<PostsLoading>(),
        isA<PostsLoaded>().having((state) => state.posts, 'posts', tPosts),
      ],
      verify: (_) {
        verify(() => mockGetPostsUseCase(page: 1, limit: 10)).called(1);
      },
    );

    blocTest<PostsBloc, PostsState>(
      'emits [PostsError] when FetchPosts fails',
      build: () {
        when(
          () => mockGetPostsUseCase(
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          ),
        ).thenThrow(Exception('Failed to load'));
        return postsBloc;
      },
      act: (bloc) => bloc.add(FetchPosts()),
      expect: () => [
        isA<PostsLoading>(),
        isA<PostsError>().having(
          (state) => state.message,
          'message',
          'Exception: Failed to load',
        ),
      ],
    );

    blocTest<PostsBloc, PostsState>(
      'emits [PostsLoaded] when RefreshPosts is added',
      build: () {
        when(
          () => mockGetPostsUseCase(
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => tPosts);
        return postsBloc;
      },
      act: (bloc) => bloc.add(RefreshPosts()),
      expect: () => [isA<PostsLoaded>()],
      verify: (_) {
        verify(() => mockGetPostsUseCase(page: 1, limit: 10)).called(1);
      },
    );
  });
}
