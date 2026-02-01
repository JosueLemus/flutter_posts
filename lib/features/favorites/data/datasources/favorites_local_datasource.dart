import 'package:shared_preferences/shared_preferences.dart';

abstract class FavoritesLocalDataSource {
  Future<List<int>> getFavorites();
  Future<void> saveFavorite(int id);
  Future<void> removeFavorite(int id);
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _kFavoritesKey = 'favorite_ids';

  FavoritesLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<int>> getFavorites() async {
    final List<String>? favorites = sharedPreferences.getStringList(
      _kFavoritesKey,
    );
    if (favorites == null) return [];
    return favorites.map((id) => int.parse(id)).toList();
  }

  @override
  Future<void> saveFavorite(int id) async {
    final favorites = await getFavorites();
    if (!favorites.contains(id)) {
      favorites.add(id);
      await sharedPreferences.setStringList(
        _kFavoritesKey,
        favorites.map((id) => id.toString()).toList(),
      );
    }
  }

  @override
  Future<void> removeFavorite(int id) async {
    final favorites = await getFavorites();
    if (favorites.contains(id)) {
      favorites.remove(id);
      await sharedPreferences.setStringList(
        _kFavoritesKey,
        favorites.map((id) => id.toString()).toList(),
      );
    }
  }
}
