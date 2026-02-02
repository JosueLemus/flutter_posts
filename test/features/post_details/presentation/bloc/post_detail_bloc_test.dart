import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_posts/features/post_details/domain/entities/comment.dart';
import 'package:flutter_posts/features/post_details/domain/usecases/get_comments_usecase.dart';
import 'package:flutter_posts/features/post_details/presentation/bloc/post_detail_bloc.dart';
import 'package:flutter_posts/features/post_details/presentation/bloc/post_detail_event.dart';
import 'package:flutter_posts/features/post_details/presentation/bloc/post_detail_state.dart';
import 'package:flutter_posts/features/posts/domain/entities/post.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCommentsUseCase extends Mock implements GetCommentsUseCase {}

void main() {
  late PostDetailBloc bloc;
  late MockGetCommentsUseCase mockGetCommentsUseCase;

  setUp(() {
    mockGetCommentsUseCase = MockGetCommentsUseCase();
    bloc = PostDetailBloc(getCommentsUseCase: mockGetCommentsUseCase);
  });

  tearDown(() {
    bloc.close();
  });

  final testPost = Post(id: 1, title: 'Test Post', body: 'Test Body');

  final testComments = [
    Comment(
      postId: 1,
      id: 1,
      name: 'Test Comment',
      email: 'test@example.com',
      body: 'Test comment body',
    ),
  ];

  group('PostDetailBloc', () {
    test('initial state is correct', () {
      expect(bloc.state, const PostDetailState());
    });

    blocTest<PostDetailBloc, PostDetailState>(
      'emits loading and loaded states when LoadPostDetail succeeds',
      build: () {
        when(
          () => mockGetCommentsUseCase(testPost.id),
        ).thenAnswer((_) async => testComments);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadPostDetail(testPost)),
      expect: () => [
        PostDetailState(post: testPost, isLoadingComments: true),
        PostDetailState(
          post: testPost,
          comments: testComments,
          isLoadingComments: false,
        ),
      ],
      verify: (_) {
        verify(() => mockGetCommentsUseCase(testPost.id)).called(1);
      },
    );

    blocTest<PostDetailBloc, PostDetailState>(
      'emits error state when LoadPostDetail fails',
      build: () {
        when(
          () => mockGetCommentsUseCase(testPost.id),
        ).thenThrow(Exception('Failed to load comments'));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadPostDetail(testPost)),
      expect: () => [
        PostDetailState(post: testPost, isLoadingComments: true),
        PostDetailState(
          post: testPost,
          error: 'Failed to load comments',
          isLoadingComments: false,
        ),
      ],
    );
  });
}
