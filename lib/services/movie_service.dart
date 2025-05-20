import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';
import 'api_key_service.dart';

class MovieService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  final ApiKeyService _apiKeyService;

  MovieService(this._apiKeyService);

  Future<List<Movie>> getPopularMovies() async {
    return _getMovies('movie/popular');
  }

  Future<List<Movie>> getNowPlayingMovies() async {
    return _getMovies('movie/now_playing');
  }

  Future<List<Movie>> getTopRatedMovies() async {
    return _getMovies('movie/top_rated');
  }

  Future<List<Movie>> getUpcomingMovies() async {
    return _getMovies('movie/upcoming');
  }

  Future<List<Movie>> _getMovies(String endpoint) async {
    final apiKey = _apiKeyService.getApiKey();
    if (apiKey == null) {
      throw Exception('API key not configured');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/$endpoint?api_key=$apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      return results.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to load movies');
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    final apiKey = _apiKeyService.getApiKey();
    if (apiKey == null) {
      throw Exception('API key not configured');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/search/movie?api_key=$apiKey&query=$query'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      return results.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to search movies');
    }
  }

  Future<Movie> getMovieDetails(int movieId) async {
    final apiKey = _apiKeyService.getApiKey();
    if (apiKey == null) {
      throw Exception('API key not configured');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/movie/$movieId?api_key=$apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Movie.fromJson(data);
    } else {
      throw Exception('Failed to load movie details');
    }
  }
}
