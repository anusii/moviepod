import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorites';
  final SharedPreferences _prefs;
  final _favoritesController = StreamController<List<Movie>>.broadcast();
  List<Movie> _cachedFavorites = [];

  FavoritesService(this._prefs) {
    _loadFavorites();
  }

  Stream<List<Movie>> get favoritesStream => _favoritesController.stream;

  Future<void> _loadFavorites() async {
    _cachedFavorites = await getFavorites();
    _favoritesController.add(_cachedFavorites);
  }

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
    _cachedFavorites = favorites;
    _favoritesController.add(favorites);
  }

  void dispose() {
    _favoritesController.close();
  }
}
