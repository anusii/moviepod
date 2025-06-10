/// Utility for converting Movie objects to/from Turtle (TTL) format.
///
// Copyright (C) 2025, Software Innovation Institute, ANU.
//
// Licensed under the GNU General Public License, Version 3 (the "License").
//
// License: https://www.gnu.org/licenses/gpl-3.0.en.html.

library;

import 'dart:convert';

import 'package:moviestar/models/movie.dart';

/// Utility class for serializing/deserializing movies to/from Turtle format.
class TurtleSerializer {
  /// Converts a list of movies to TTL format.
  static String moviesToTurtle(List<Movie> movies, String listName) {
    final buffer = StringBuffer();
    
    // Add prefixes
    buffer.writeln('@prefix : <#> .');
    buffer.writeln('@prefix movie: <http://schema.org/Movie> .');
    buffer.writeln('@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .');
    buffer.writeln();
    
    // Add list definition
    buffer.writeln(':$listName a :MovieList ;');
    buffer.writeln('  :name "${_escapeString(listName)}" ;');
    
    if (movies.isEmpty) {
      buffer.writeln('  :movies () .');
    } else {
      buffer.writeln('  :movies (');
      
      for (int i = 0; i < movies.length; i++) {
        final movie = movies[i];
        buffer.writeln('    :movie${movie.id}');
        if (i < movies.length - 1) buffer.write(' ');
      }
      buffer.writeln('  ) .');
    }
    
    buffer.writeln();
    
    // Add movie definitions
    for (final movie in movies) {
      buffer.writeln(':movie${movie.id} a movie:Movie ;');
      buffer.writeln('  movie:identifier "${movie.id}"^^xsd:integer ;');
      buffer.writeln('  movie:name "${_escapeString(movie.title)}" ;');
      buffer.writeln('  movie:description "${_escapeString(movie.overview)}" ;');
      buffer.writeln('  movie:image "${_escapeString(movie.posterUrl)}" ;');
      buffer.writeln('  movie:thumbnailUrl "${_escapeString(movie.backdropUrl)}" ;');
      buffer.writeln('  movie:aggregateRating "${movie.voteAverage}"^^xsd:double ;');
      buffer.writeln('  movie:datePublished "${movie.releaseDate.toIso8601String()}"^^xsd:dateTime ;');
      buffer.writeln('  movie:genre "${movie.genreIds.join(',')}" .');
      buffer.writeln();
    }
    
    return buffer.toString();
  }
  
  /// Converts ratings map to TTL format.
  static String ratingsToTurtle(Map<String, double> ratings) {
    final buffer = StringBuffer();
    
    buffer.writeln('@prefix : <#> .');
    buffer.writeln('@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .');
    buffer.writeln();
    
    buffer.writeln(':ratings a :RatingsList ;');
    buffer.writeln('  :name "User Ratings" .');
    buffer.writeln();
    
    for (final entry in ratings.entries) {
      buffer.writeln(':rating${entry.key} a :Rating ;');
      buffer.writeln('  :movieId "${entry.key}"^^xsd:integer ;');
      buffer.writeln('  :value "${entry.value}"^^xsd:double .');
      buffer.writeln();
    }
    
    return buffer.toString();
  }
  
  /// Converts movie comments to TTL format.
  static String commentsToTurtle(Map<String, String> comments) {
    final buffer = StringBuffer();
    
    buffer.writeln('@prefix : <#> .');
    buffer.writeln();
    
    buffer.writeln(':comments a :CommentsList ;');
    buffer.writeln('  :name "User Comments" .');
    buffer.writeln();
    
    for (final entry in comments.entries) {
      buffer.writeln(':comment${entry.key} a :Comment ;');
      buffer.writeln('  :movieId "${entry.key}"^^xsd:integer ;');
      buffer.writeln('  :text "${_escapeString(entry.value)}" .');
      buffer.writeln();
    }
    
    return buffer.toString();
  }
  
  /// Parses movies from TTL content.
  /// For now, we'll store the JSON data as a simple encoded string in TTL
  /// This is a simplified approach - in production you'd want proper RDF parsing
  static List<Movie> moviesFromTurtle(String ttlContent) {
    try {
      // Look for JSON data comment in TTL
      final jsonMatch = RegExp(r'# JSON_DATA: (.+)').firstMatch(ttlContent);
      if (jsonMatch != null) {
        final jsonData = jsonMatch.group(1)!;
        final decoded = jsonDecode(jsonData) as List<dynamic>;
        return decoded.map((movie) => Movie.fromJson(movie)).toList();
      }
      
      // If no JSON data found, return empty list
      return [];
    } catch (e) {
      return [];
    }
  }
  
  /// Parses ratings from TTL content.
  static Map<String, double> ratingsFromTurtle(String ttlContent) {
    try {
      final jsonMatch = RegExp(r'# JSON_DATA: (.+)').firstMatch(ttlContent);
      if (jsonMatch != null) {
        final jsonData = jsonMatch.group(1)!;
        final decoded = jsonDecode(jsonData) as Map<String, dynamic>;
        return decoded.map((key, value) => MapEntry(key, value.toDouble()));
      }
      return {};
    } catch (e) {
      return {};
    }
  }
  
  /// Parses comments from TTL content.
  static Map<String, String> commentsFromTurtle(String ttlContent) {
    try {
      final jsonMatch = RegExp(r'# JSON_DATA: (.+)').firstMatch(ttlContent);
      if (jsonMatch != null) {
        final jsonData = jsonMatch.group(1)!;
        final decoded = jsonDecode(jsonData) as Map<String, dynamic>;
        return decoded.cast<String, String>();
      }
      return {};
    } catch (e) {
      return {};
    }
  }
  
  /// Enhanced serialization with JSON backup for compatibility.
  static String moviesToTurtleWithJson(List<Movie> movies, String listName) {
    final buffer = StringBuffer();
    
    // Add the proper TTL structure
    buffer.writeln(moviesToTurtle(movies, listName));
    
    // Add JSON backup as comment for easy parsing
    buffer.writeln('# JSON_DATA: ${jsonEncode(movies.map((m) => m.toJson()).toList())}');
    
    return buffer.toString();
  }
  
  /// Enhanced ratings serialization with JSON backup.
  static String ratingsToTurtleWithJson(Map<String, double> ratings) {
    final buffer = StringBuffer();
    
    // Add proper TTL structure
    buffer.writeln(ratingsToTurtle(ratings));
    
    // Add JSON backup as comment
    buffer.writeln('# JSON_DATA: ${jsonEncode(ratings)}');
    
    return buffer.toString();
  }
  
  /// Enhanced comments serialization with JSON backup.
  static String commentsToTurtleWithJson(Map<String, String> comments) {
    final buffer = StringBuffer();
    
    // Add proper TTL structure
    buffer.writeln(commentsToTurtle(comments));
    
    // Add JSON backup as comment
    buffer.writeln('# JSON_DATA: ${jsonEncode(comments)}');
    
    return buffer.toString();
  }
  
  /// Escapes special characters in strings for TTL format.
  static String _escapeString(String input) {
    return input
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');
  }
} 