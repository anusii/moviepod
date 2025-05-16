import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class MovieService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  // TODO: Replace with your actual API key
  static const String _apiKey = '5bec1661fa965fd845fb82f4973b1bc8';

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
    final response = await http.get(
      Uri.parse('$_baseUrl/$endpoint?api_key=$_apiKey'),
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
    final response = await http.get(
      Uri.parse('$_baseUrl/search/movie?api_key=$_apiKey&query=$query'),
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
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/$movieId?api_key=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Movie.fromJson(data);
    } else {
      throw Exception('Failed to load movie details');
    }
  }
}
