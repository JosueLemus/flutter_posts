import 'package:dio/dio.dart';
import 'package:flutter_posts/core/network/dio_client.dart';
import 'package:flutter_posts/features/posts/data/datasources/post_remote_datasource.dart';
import 'package:flutter_posts/features/posts/data/models/post_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDioClient extends Mock implements DioClient {}

class MockDio extends Mock implements Dio {}

void main() {
  late PostRemoteDataSourceImpl dataSource;
  late MockDioClient mockDioClient;
  late MockDio mockDio;

  setUp(() {
    mockDioClient = MockDioClient();
    mockDio = MockDio();
    when(() => mockDioClient.dio).thenReturn(mockDio);
    dataSource = PostRemoteDataSourceImpl(dioClient: mockDioClient);
    registerFallbackValue(RequestOptions(path: ''));
  });

  group('getPosts', () {
    final tPostModelList = [
      const PostModel(id: 1, title: 'test title', body: 'test body'),
    ];

    test(
      'should return list of PostModel when network call is successful',
      () async {
        when(
          () => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: [
              {'id': 1, 'title': 'test title', 'body': 'test body'},
            ],
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
          ),
        );

        final result = await dataSource.getPosts(page: 1, limit: 10);

        expect(result, equals(tPostModelList));
        verify(
          () => mockDio.get(
            '/posts',
            queryParameters: {'_page': 1, '_limit': 10},
          ),
        ).called(1);
      },
    );

    test('should throw Exception when network call fails', () async {
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      final call = dataSource.getPosts;

      expect(() => call(page: 1, limit: 10), throwsA(isA<Exception>()));
    });
  });
}
