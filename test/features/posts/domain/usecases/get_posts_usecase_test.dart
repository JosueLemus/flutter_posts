import 'package:flutter_posts/features/posts/domain/entities/post.dart';
import 'package:flutter_posts/features/posts/domain/repositories/post_repository.dart';
import 'package:flutter_posts/features/posts/domain/usecases/get_posts_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPostRepository extends Mock implements PostRepository {}

void main() {
  late GetPostsUseCase useCase;
  late MockPostRepository mockPostRepository;

  setUp(() {
    mockPostRepository = MockPostRepository();
    useCase = GetPostsUseCase(mockPostRepository);
  });

  const tPost = Post(id: 1, title: 'test', body: 'test body');
  const tPosts = [tPost];

  test('should get list of posts from the repository', () async {
    when(
      () => mockPostRepository.getPosts(
        page: any(named: 'page'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => tPosts);

    final result = await useCase(page: 1, limit: 10);

    expect(result, tPosts);
    verify(() => mockPostRepository.getPosts(page: 1, limit: 10)).called(1);
    verifyNoMoreInteractions(mockPostRepository);
  });
}
