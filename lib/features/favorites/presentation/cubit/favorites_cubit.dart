import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_favorites_usecase.dart';
import '../../domain/usecases/toggle_favorite_usecase.dart';

class FavoritesCubit extends Cubit<List<int>> {
  final GetFavoritesUseCase getFavoritesUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;

  FavoritesCubit({
    required this.getFavoritesUseCase,
    required this.toggleFavoriteUseCase,
  }) : super([]) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    try {
      final favorites = await getFavoritesUseCase();
      emit(favorites);
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  Future<void> toggleFavorite(int id) async {
    try {
      await toggleFavoriteUseCase(id);
      await loadFavorites();
    } catch (e) {
      debugPrint('Error toggling favorite for post $id: $e');
    }
  }

  bool isFavorite(int id) => state.contains(id);
}
