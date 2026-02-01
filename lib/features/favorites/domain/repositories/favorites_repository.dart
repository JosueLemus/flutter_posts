abstract class FavoritesRepository {
  Future<List<int>> getFavorites();
  Future<void> toggleFavorite(int id);
}
