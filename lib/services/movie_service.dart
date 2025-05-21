import '../models/movie.dart';
import '../utils/network_client.dart';
import 'api_key_service.dart';

class MovieService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  // TODO: Replace with your actual API key
  static const String _apiKey = '5bec1661fa965fd845fb82f4973b1bc8';

  final NetworkClient _client;

  MovieService() : _client = NetworkClient(baseUrl: _baseUrl, apiKey: _apiKey);

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
