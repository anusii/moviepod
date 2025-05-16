import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';
import '../services/favorites_service.dart';
import 'movie_details_screen.dart';

class ComingSoonScreen extends StatefulWidget {
  final FavoritesService favoritesService;

  const ComingSoonScreen({super.key, required this.favoritesService});

  @override
  State<ComingSoonScreen> createState() => _ComingSoonScreenState();
}

class _ComingSoonScreenState extends State<ComingSoonScreen> {
  final MovieService _movieService = MovieService();
  bool _isLoading = false;
  String? _error;
  List<Movie> _upcomingMovies = [];

  @override
  void initState() {
    super.initState();
    _loadUpcomingMovies();
  }

  Future<void> _loadUpcomingMovies() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final movies = await _movieService.getUpcomingMovies();
      setState(() {
        _upcomingMovies = movies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Coming Soon', style: TextStyle(color: Colors.white)),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text(_error!))
              : ListView.builder(
                itemCount: _upcomingMovies.length,
                itemBuilder: (context, index) {
                  final movie = _upcomingMovies[index];
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: CachedNetworkImage(
                        imageUrl: movie.posterUrl,
                        width: 50,
                        height: 75,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                        errorWidget:
                            (context, url, error) => const Icon(Icons.error),
                      ),
                    ),
                    title: Text(
                      movie.title,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      'Release Date: ${movie.releaseDate.day}/${movie.releaseDate.month}/${movie.releaseDate.year}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => MovieDetailsScreen(
                                movie: movie,
                                favoritesService: widget.favoritesService,
                              ),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
