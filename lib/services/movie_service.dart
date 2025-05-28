import '../models/movie.dart';
import '../utils/network_client.dart';
import 'api_key_service.dart';

/// A service class that handles movie-related API requests.

class MovieService {
  /// Base URL for The Movie Database API.

  static const String _baseUrl = 'https://api.themoviedb.org/3';

  /// Network client for making HTTP requests.

  NetworkClient _client;

  /// Service for managing the API key.

  final ApiKeyService _apiKeyService;

  /// Creates a new MovieService instance.

  MovieService(ApiKeyService apiKeyService)
    : _client = NetworkClient(
        baseUrl: _baseUrl,
        apiKey: apiKeyService.getApiKey() ?? '',
      ),
      _apiKeyService = apiKeyService;

  /// Updates the API key and recreates the network client.

  void updateApiKey() {
    _client.dispose();
    _client = NetworkClient(
      baseUrl: _baseUrl,
      apiKey: _apiKeyService.getApiKey() ?? '',
    );
  }

  /// Gets a list of popular movies.

  Future<List<Movie>> getPopularMovies() async {
    final results = await _client.getJsonList('movie/popular');
    return results.map((movie) => Movie.fromJson(movie)).toList();
  }

  /// Gets a list of movies currently playing in theaters.

  Future<List<Movie>> getNowPlayingMovies() async {
    final results = await _client.getJsonList('movie/now_playing');
    return results.map((movie) => Movie.fromJson(movie)).toList();
  }

  /// Gets a list of top rated movies.

  Future<List<Movie>> getTopRatedMovies() async {
    final results = await _client.getJsonList('movie/top_rated');
    return results.map((movie) => Movie.fromJson(movie)).toList();
  }

  /// Gets a list of upcoming movies.

  Future<List<Movie>> getUpcomingMovies() async {
    final results = await _client.getJsonList('movie/upcoming');
    return results.map((movie) => Movie.fromJson(movie)).toList();
  }

  /// Searches for movies matching the given query.

  Future<List<Movie>> searchMovies(String query) async {
    final results = await _client.getJsonList('search/movie?query=$query');
    return results.map((movie) => Movie.fromJson(movie)).toList();
  }

  /// Gets detailed information about a specific movie.

  Future<Movie> getMovieDetails(int movieId) async {
    final data = await _client.getJson('movie/$movieId');
    return Movie.fromJson(data);
  }

  /// Disposes the network client.

  void dispose() {
    _client.dispose();
  }
}
