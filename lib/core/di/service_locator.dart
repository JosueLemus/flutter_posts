import 'package:get_it/get_it.dart';

import '../../features/post_details/data/datasources/post_details_remote_datasource.dart';
import '../../features/post_details/data/repositories/post_details_repository_impl.dart';
import '../../features/post_details/domain/repositories/post_details_repository.dart';
import '../../features/post_details/domain/usecases/get_comments_usecase.dart';
import '../../features/post_details/presentation/bloc/post_detail_bloc.dart';
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

  // Features - Post Details
  // Data
  getIt.registerLazySingleton<PostDetailsRemoteDataSource>(
    () => PostDetailsRemoteDataSourceImpl(dioClient: getIt()),
  );
  getIt.registerLazySingleton<PostDetailsRepository>(
    () => PostDetailsRepositoryImpl(remoteDataSource: getIt()),
  );

  // Domain
  getIt.registerLazySingleton(() => GetPostsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetCommentsUseCase(getIt()));

  // Presentation
  getIt.registerFactory(() => PostsBloc(getPostsUseCase: getIt()));
  getIt.registerFactory(() => PostDetailBloc(getCommentsUseCase: getIt()));
}
