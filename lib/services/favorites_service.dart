import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorites';
  final SharedPreferences _prefs;

  FavoritesService(this._prefs);

  Future<List<Movie>> getFavorites() async {
    final String? favoritesJson = _prefs.getString(_favoritesKey);
    if (favoritesJson == null) return [];

    final List<dynamic> decoded = jsonDecode(favoritesJson);
    return decoded.map((movie) => Movie.fromJson(movie)).toList();
  }

  Future<void> addToFavorites(Movie movie) async {
    final favorites = await getFavorites();
    if (!favorites.any((m) => m.id == movie.id)) {
      favorites.add(movie);
      await _saveFavorites(favorites);
    }
  }

  Future<void> removeFromFavorites(Movie movie) async {
    final favorites = await getFavorites();
    favorites.removeWhere((m) => m.id == movie.id);
    await _saveFavorites(favorites);
  }

  Future<bool> isFavorite(Movie movie) async {
    final favorites = await getFavorites();
    return favorites.any((m) => m.id == movie.id);
  }

  Future<void> _saveFavorites(List<Movie> favorites) async {
    final encoded = jsonEncode(favorites.map((m) => m.toJson()).toList());
    await _prefs.setString(_favoritesKey, encoded);
  }
}
