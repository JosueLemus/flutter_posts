import 'package:get_it/get_it.dart';

import '../../features/posts/data/datasources/post_remote_datasource.dart';
import '../../features/posts/data/repositories/post_repository_impl.dart';
import '../../features/posts/domain/repositories/post_repository.dart';
import '../../features/posts/domain/usecases/get_posts_usecase.dart';
import '../../features/posts/presentation/bloc/posts_bloc.dart';
import '../network/dio_client.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Core
  getIt.registerLazySingleton<DioClient>(() => DioClient());

  // Data
  getIt.registerLazySingleton<PostRemoteDataSource>(
    () => PostRemoteDataSourceImpl(dioClient: getIt()),
  );

  getIt.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(remoteDataSource: getIt()),
  );

  // Domain
  getIt.registerLazySingleton(() => GetPostsUseCase(getIt()));

  // Presentation
  getIt.registerFactory(() => PostsBloc(getPostsUseCase: getIt()));
}
