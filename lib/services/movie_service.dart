import '../models/movie.dart';
import '../utils/network_client.dart';
import 'api_key_service.dart';

class MovieService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  NetworkClient _client;
  final ApiKeyService _apiKeyService;

  MovieService(ApiKeyService apiKeyService)
      : _client = NetworkClient(
          baseUrl: _baseUrl,
          apiKey: apiKeyService.getApiKey() ?? '',
        ),
        _apiKeyService = apiKeyService;

  /// Updates the API key and recreates the network client
  void updateApiKey() {
    _client.dispose();
    _client = NetworkClient(
      baseUrl: _baseUrl,
      apiKey: _apiKeyService.getApiKey() ?? '',
    );
  }

  Future<List<Movie>> getPopularMovies() async {
    final results = await _client.getJsonList('movie/popular');
    return results.map((movie) => Movie.fromJson(movie)).toList();
  }

  Future<List<Movie>> getNowPlayingMovies() async {
    final results = await _client.getJsonList('movie/now_playing');
    return results.map((movie) => Movie.fromJson(movie)).toList();
  }

  Future<List<Movie>> getTopRatedMovies() async {
    final results = await _client.getJsonList('movie/top_rated');
    return results.map((movie) => Movie.fromJson(movie)).toList();
  }

  Future<List<Movie>> getUpcomingMovies() async {
    final results = await _client.getJsonList('movie/upcoming');
    return results.map((movie) => Movie.fromJson(movie)).toList();
  }

  Future<List<Movie>> searchMovies(String query) async {
    final results = await _client.getJsonList('search/movie?query=$query');
    return results.map((movie) => Movie.fromJson(movie)).toList();
  }

  Future<Movie> getMovieDetails(int movieId) async {
    final data = await _client.getJson('movie/$movieId');
    return Movie.fromJson(data);
  }

  void dispose() {
    _client.dispose();
  }
}
