import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_local_datasource.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesLocalDataSource localDataSource;

  FavoritesRepositoryImpl({required this.localDataSource});

  @override
  Future<List<int>> getFavorites() async {
    return await localDataSource.getFavorites();
  }

  @override
  Future<void> toggleFavorite(int id) async {
    final favorites = await localDataSource.getFavorites();
    if (favorites.contains(id)) {
      await localDataSource.removeFavorite(id);
    } else {
      await localDataSource.saveFavorite(id);
    }
  }
}
