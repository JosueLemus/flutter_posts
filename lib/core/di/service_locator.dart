import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/favorites/data/datasources/favorites_local_datasource.dart';
import '../../features/favorites/data/repositories/favorites_repository_impl.dart';
import '../../features/favorites/domain/repositories/favorites_repository.dart';
import '../../features/favorites/domain/usecases/get_favorites_usecase.dart';
import '../../features/favorites/domain/usecases/toggle_favorite_usecase.dart';
import '../../features/favorites/presentation/cubit/favorites_cubit.dart';
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

Future<void> setupDependencies() async {
  // Core
  getIt.registerLazySingleton<DioClient>(() => DioClient());

  // Features - Posts
  // Data
  getIt.registerLazySingleton<PostRemoteDataSource>(
    () => PostRemoteDataSourceImpl(dioClient: getIt()),
  );
  getIt.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(remoteDataSource: getIt()),
  );

  // Domain
  getIt.registerLazySingleton(() => GetPostsUseCase(getIt()));

  // Features - Post Details
  // Data
  getIt.registerLazySingleton<PostDetailsRemoteDataSource>(
    () => PostDetailsRemoteDataSourceImpl(dioClient: getIt()),
  );
  getIt.registerLazySingleton<PostDetailsRepository>(
    () => PostDetailsRepositoryImpl(remoteDataSource: getIt()),
  );

  // Domain
  getIt.registerLazySingleton(() => GetCommentsUseCase(getIt()));

  // Features - Favorites
  // Shared Preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);

  // Data
  getIt.registerLazySingleton<FavoritesLocalDataSource>(
    () => FavoritesLocalDataSourceImpl(sharedPreferences: getIt()),
  );
  getIt.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(localDataSource: getIt()),
  );

  // Domain
  getIt.registerLazySingleton(() => GetFavoritesUseCase(getIt()));
  getIt.registerLazySingleton(() => ToggleFavoriteUseCase(getIt()));

  // Presentation
  getIt.registerFactory(() => PostsBloc(getPostsUseCase: getIt()));
  getIt.registerFactory(() => PostDetailBloc(getCommentsUseCase: getIt()));
  getIt.registerFactory(
    () => FavoritesCubit(
      getFavoritesUseCase: getIt(),
      toggleFavoriteUseCase: getIt(),
    ),
  );
}
