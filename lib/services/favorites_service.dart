import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _key = 'favorite_point_ids';

  /// Получить список ID избранных пунктов
  Future<List<String>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  /// Переключить статус (добавить или удалить)
  Future<bool> toggleFavorite(String pointId) async {
    final prefs = await SharedPreferences.getInstance();
    
  
    List<String> favorites = List.from(await getFavoriteIds());
    
    if (favorites.contains(pointId)) {
      favorites.remove(pointId);
      await prefs.setStringList(_key, favorites);
      return false; // Был удален
    } else {
      favorites.add(pointId);
      await prefs.setStringList(_key, favorites);
      return true; // Был добавлен
    }
  }

  /// Проверить, есть ли пункт в избранном
  Future<bool> isFavorite(String pointId) async {
    final favorites = await getFavoriteIds();
    return favorites.contains(pointId);
  }
}