import 'package:flutter_posts/features/post_details/domain/entities/comment.dart';
import 'package:flutter_posts/features/post_details/domain/repositories/post_details_repository.dart';
import 'package:flutter_posts/features/post_details/domain/usecases/get_comments_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPostDetailsRepository extends Mock implements PostDetailsRepository {}

void main() {
  late GetCommentsUseCase useCase;
  late MockPostDetailsRepository mockRepository;

  setUp(() {
    mockRepository = MockPostDetailsRepository();
    useCase = GetCommentsUseCase(mockRepository);
  });

  group('call', () {
    const postId = 1;
    final comments = [
      Comment(
        postId: 1,
        id: 1,
        name: 'Test Comment',
        email: 'test@example.com',
        body: 'Test body',
      ),
    ];

    test('should return list of comments from repository', () async {
      when(
        () => mockRepository.getComments(postId),
      ).thenAnswer((_) async => comments);

      final result = await useCase(postId);

      expect(result, comments);
      verify(() => mockRepository.getComments(postId)).called(1);
    });

    test('should throw exception when repository fails', () async {
      when(
        () => mockRepository.getComments(postId),
      ).thenThrow(Exception('Failed to fetch comments'));

      expect(() => useCase(postId), throwsException);
    });
  });
}
