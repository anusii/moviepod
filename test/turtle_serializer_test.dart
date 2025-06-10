import 'package:flutter_test/flutter_test.dart';
import 'package:moviestar/models/movie.dart';
import 'package:moviestar/utils/turtle_serializer.dart';

void main() {
  group('TurtleSerializer', () {
    test('should serialize and deserialize movies correctly', () {
      // Create test movie
      final movie = Movie(
        id: 12345,
        title: 'Test Movie',
        overview: 'A test movie description',
        posterUrl: 'https://example.com/poster.jpg',
        backdropUrl: 'https://example.com/backdrop.jpg',
        voteAverage: 8.5,
        releaseDate: DateTime(2023, 1, 1),
        genreIds: [28, 12], // Action, Adventure
      );

      final movies = [movie];
      
      // Serialize to TTL
      final ttl = TurtleSerializer.moviesToTurtleWithJson(movies, 'testList');
      
      // Verify TTL contains expected content
      expect(ttl, contains('@prefix'));
      expect(ttl, contains('testList'));
      expect(ttl, contains('Test Movie'));
      expect(ttl, contains('JSON_DATA:'));
      
      print('Generated TTL:');
      print(ttl);
      
      // Deserialize from TTL
      final deserializedMovies = TurtleSerializer.moviesFromTurtle(ttl);
      
      // Verify deserialization
      expect(deserializedMovies.length, 1);
      expect(deserializedMovies.first.id, 12345);
      expect(deserializedMovies.first.title, 'Test Movie');
      expect(deserializedMovies.first.overview, 'A test movie description');
      expect(deserializedMovies.first.voteAverage, 8.5);
    });

    test('should handle empty movie list', () {
      final movies = <Movie>[];
      
      // Serialize empty list
      final ttl = TurtleSerializer.moviesToTurtleWithJson(movies, 'emptyList');
      
      // Verify TTL structure for empty list
      expect(ttl, contains('@prefix'));
      expect(ttl, contains('emptyList'));
      expect(ttl, contains(':movies ()'));
      
      // Deserialize empty list
      final deserializedMovies = TurtleSerializer.moviesFromTurtle(ttl);
      expect(deserializedMovies.length, 0);
    });

    test('should serialize and deserialize ratings correctly', () {
      final ratings = {
        '12345': 8.5,
        '67890': 7.2,
        '11111': 9.0,
      };
      
      // Serialize ratings
      final ttl = TurtleSerializer.ratingsToTurtleWithJson(ratings);
      
      // Verify TTL contains expected content
      expect(ttl, contains('@prefix'));
      expect(ttl, contains('RatingsList'));
      expect(ttl, contains('JSON_DATA:'));
      
      print('Generated Ratings TTL:');
      print(ttl);
      
      // Deserialize ratings
      final deserializedRatings = TurtleSerializer.ratingsFromTurtle(ttl);
      
      // Verify deserialization
      expect(deserializedRatings.length, 3);
      expect(deserializedRatings['12345'], 8.5);
      expect(deserializedRatings['67890'], 7.2);
      expect(deserializedRatings['11111'], 9.0);
    });

    test('should serialize and deserialize comments correctly', () {
      final comments = {
        '12345': 'Great movie!',
        '67890': 'Not bad, but could be better',
        '11111': 'Absolutely amazing!',
      };
      
      // Serialize comments
      final ttl = TurtleSerializer.commentsToTurtleWithJson(comments);
      
      // Verify TTL contains expected content
      expect(ttl, contains('@prefix'));
      expect(ttl, contains('CommentsList'));
      expect(ttl, contains('JSON_DATA:'));
      
      print('Generated Comments TTL:');
      print(ttl);
      
      // Deserialize comments
      final deserializedComments = TurtleSerializer.commentsFromTurtle(ttl);
      
      // Verify deserialization
      expect(deserializedComments.length, 3);
      expect(deserializedComments['12345'], 'Great movie!');
      expect(deserializedComments['67890'], 'Not bad, but could be better');
      expect(deserializedComments['11111'], 'Absolutely amazing!');
    });

    test('should handle special characters in movie titles and descriptions', () {
      final movie = Movie(
        id: 99999,
        title: 'Movie with "Quotes" & Special Characters',
        overview: 'Description with\nnewlines and\ttabs and "quotes"',
        posterUrl: 'https://example.com/poster.jpg',
        backdropUrl: 'https://example.com/backdrop.jpg',
        voteAverage: 7.8,
        releaseDate: DateTime(2023, 12, 25),
        genreIds: [18], // Drama
      );

      final movies = [movie];
      
      // Serialize to TTL
      final ttl = TurtleSerializer.moviesToTurtleWithJson(movies, 'specialCharsTest');
      
      // Should not throw exceptions
      expect(ttl, contains('specialCharsTest'));
      expect(ttl, contains('JSON_DATA:'));
      
      // Deserialize should work correctly
      final deserializedMovies = TurtleSerializer.moviesFromTurtle(ttl);
      expect(deserializedMovies.length, 1);
      expect(deserializedMovies.first.title, 'Movie with "Quotes" & Special Characters');
      expect(deserializedMovies.first.overview, 'Description with\nnewlines and\ttabs and "quotes"');
    });
  });
} 