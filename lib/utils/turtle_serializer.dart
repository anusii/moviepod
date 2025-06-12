/// Utility for converting Movie objects to/from Turtle (TTL) format using solidpod RDF functions.
///
// Copyright (C) 2025, Software Innovation Institute, ANU.
//
// Licensed under the GNU General Public License, Version 3 (the "License").
//
// License: https://www.gnu.org/licenses/gpl-3.0.en.html.

library;

import 'dart:convert';

import 'package:rdflib/rdflib.dart';
// ignore: implementation_imports
import 'package:solidpod/src/solid/utils/rdf.dart'
    show tripleMapToTurtle, turtleToTripleMap;

import 'package:moviestar/models/movie.dart';

/// Utility class for serializing/deserializing movies to/from Turtle format using proper RDF.

class TurtleSerializer {
  // Define namespaces for movie data.

  static final movieNS = Namespace(ns: 'http://schema.org/');
  static final localNS = Namespace(ns: '#');

  // Define common predicates as URIRefs.

  static final movieType = movieNS.withAttr('Movie');
  static final movieListType = localNS.withAttr('MovieList');
  static final ratingListType = localNS.withAttr('RatingsList');
  static final commentListType = localNS.withAttr('CommentsList');
  static final ratingType = localNS.withAttr('Rating');
  static final commentType = localNS.withAttr('Comment');

  // Movie predicates.

  static final identifier = movieNS.withAttr('identifier');
  static final name = movieNS.withAttr('name');
  static final description = movieNS.withAttr('description');
  static final image = movieNS.withAttr('image');
  static final thumbnailUrl = movieNS.withAttr('thumbnailUrl');
  static final aggregateRating = movieNS.withAttr('aggregateRating');
  static final datePublished = movieNS.withAttr('datePublished');
  static final genre = movieNS.withAttr('genre');

  // List predicates.

  static final nameProperty = localNS.withAttr('name');
  static final moviesProperty = localNS.withAttr('movies');

  // Rating predicates.

  static final movieId = localNS.withAttr('movieId');
  static final value = localNS.withAttr('value');

  // Comment predicates.

  static final text = localNS.withAttr('text');

  // RDF type predicate.

  static final rdfType = URIRef(
    'http://www.w3.org/1999/02/22-rdf-syntax-ns#type',
  );

  /// Converts a list of movies to TTL format using proper RDF triples.

  static String moviesToTurtle(List<Movie> movies, String listName) {
    final triples = <URIRef, Map<URIRef, dynamic>>{};

    // Create the list resource.

    final listResource = localNS.withAttr(listName);
    triples[listResource] = {
      rdfType: movieListType,
      nameProperty: Literal(_escapeString(listName)),
    };

    // Add movie references to the list only if there are movies.

    if (movies.isNotEmpty) {
      final movieList =
          movies.map((m) => localNS.withAttr('movie${m.id}')).toList();
      triples[listResource]![moviesProperty] = movieList;

      // Add individual movie definitions.

      for (final movie in movies) {
        final movieResource = localNS.withAttr('movie${movie.id}');
        triples[movieResource] = {
          rdfType: movieType,
          identifier: Literal(
            '${movie.id}',
            datatype: URIRef('http://www.w3.org/2001/XMLSchema#integer'),
          ),
          name: Literal(_escapeString(movie.title)),
          description: Literal(_escapeString(movie.overview)),
          image: Literal(_escapeString(movie.posterUrl)),
          thumbnailUrl: Literal(_escapeString(movie.backdropUrl)),
          aggregateRating: Literal(
            '${movie.voteAverage}',
            datatype: URIRef('http://www.w3.org/2001/XMLSchema#double'),
          ),
          datePublished: Literal(
            movie.releaseDate.toIso8601String(),
            datatype: URIRef('http://www.w3.org/2001/XMLSchema#dateTime'),
          ),
          genre: Literal(movie.genreIds.join(',')),
        };
      }
    }

    // Define namespace bindings - only bind our custom namespaces.

    final bindNamespaces = {'': localNS, 'schema': movieNS};

    return tripleMapToTurtle(triples, bindNamespaces: bindNamespaces);
  }

  /// Converts ratings map to TTL format using proper RDF triples.

  static String ratingsToTurtle(Map<String, double> ratings) {
    final triples = <URIRef, Map<URIRef, dynamic>>{};

    // Create the ratings list resource.

    final ratingsResource = localNS.withAttr('ratings');
    triples[ratingsResource] = {
      rdfType: ratingListType,
      nameProperty: Literal('User Ratings'),
    };

    // Add individual rating definitions.

    for (final entry in ratings.entries) {
      final ratingResource = localNS.withAttr('rating${entry.key}');
      triples[ratingResource] = {
        rdfType: ratingType,
        movieId: Literal(
          entry.key,
          datatype: URIRef('http://www.w3.org/2001/XMLSchema#integer'),
        ),
        value: Literal(
          '${entry.value}',
          datatype: URIRef('http://www.w3.org/2001/XMLSchema#double'),
        ),
      };
    }

    // Define namespace bindings - only bind our custom namespaces.

    final bindNamespaces = {'': localNS};

    return tripleMapToTurtle(triples, bindNamespaces: bindNamespaces);
  }

  /// Converts movie comments to TTL format using proper RDF triples.

  static String commentsToTurtle(Map<String, String> comments) {
    final triples = <URIRef, Map<URIRef, dynamic>>{};

    // Create the comments list resource.

    final commentsResource = localNS.withAttr('comments');
    triples[commentsResource] = {
      rdfType: commentListType,
      nameProperty: Literal('User Comments'),
    };

    // Add individual comment definitions.

    for (final entry in comments.entries) {
      final commentResource = localNS.withAttr('comment${entry.key}');
      triples[commentResource] = {
        rdfType: commentType,
        movieId: Literal(
          entry.key,
          datatype: URIRef('http://www.w3.org/2001/XMLSchema#integer'),
        ),
        text: Literal(_escapeString(entry.value)),
      };
    }

    // Define namespace bindings - only bind our custom namespaces.

    final bindNamespaces = {'': localNS};

    return tripleMapToTurtle(triples, bindNamespaces: bindNamespaces);
  }

  /// Parses movies from TTL content using proper RDF parsing.

  static List<Movie> moviesFromTurtle(String ttlContent) {
    try {
      // First try to parse from JSON backup for backward compatibility.

      final jsonMatch = RegExp(r'# JSON_DATA: (.+)').firstMatch(ttlContent);
      if (jsonMatch != null) {
        final jsonData = jsonMatch.group(1)!;
        final decoded = jsonDecode(jsonData) as List<dynamic>;
        return decoded.map((movie) => Movie.fromJson(movie)).toList();
      }

      // Parse using proper RDF if no JSON backup.

      final triples = turtleToTripleMap(ttlContent);
      final movies = <Movie>[];

      // Find movie resources (subjects that have movie:Movie type).

      for (final subject in triples.keys) {
        final predicates = triples[subject]!;

        // Check if this is a movie resource - look for various type URIs.

        final typeValues =
            predicates['http://www.w3.org/1999/02/22-rdf-syntax-ns#type'] ?? [];

        final isMovie = typeValues.any(
          (type) =>
              type.toString().contains('Movie') ||
              type == 'http://schema.org/Movie' ||
              type == '#Movie',
        );

        if (isMovie) {
          // Extract movie data from predicates.

          final movie = _extractMovieFromTriples(predicates);
          if (movie != null) {
            movies.add(movie);
          }
        }
      }

      return movies;
    } catch (e) {
      // Fallback to empty list if parsing fails.

      return [];
    }
  }

  /// Parses ratings from TTL content using proper RDF parsing.

  static Map<String, double> ratingsFromTurtle(String ttlContent) {
    try {
      // First try JSON backup for backward compatibility.

      final jsonMatch = RegExp(r'# JSON_DATA: (.+)').firstMatch(ttlContent);
      if (jsonMatch != null) {
        final jsonData = jsonMatch.group(1)!;
        final decoded = jsonDecode(jsonData) as Map<String, dynamic>;
        return decoded.map((key, value) => MapEntry(key, value.toDouble()));
      }

      // Parse using proper RDF.

      final triples = turtleToTripleMap(ttlContent);
      final ratings = <String, double>{};

      // Find rating resources.

      for (final subject in triples.keys) {
        final predicates = triples[subject]!;

        // Check if this is a rating resource.

        final typeValues =
            predicates['http://www.w3.org/1999/02/22-rdf-syntax-ns#type'] ?? [];
        final isRating = typeValues.any(
          (type) => type.toString().contains('Rating') || type == '#Rating',
        );

        if (isRating) {
          final movieIdValues = predicates['#movieId'] ?? [];
          final valueValues = predicates['#value'] ?? [];

          if (movieIdValues.isNotEmpty && valueValues.isNotEmpty) {
            final movieId = movieIdValues.first.toString();
            final rating = double.tryParse(valueValues.first.toString()) ?? 0.0;
            ratings[movieId] = rating;
          }
        }
      }

      return ratings;
    } catch (e) {
      return {};
    }
  }

  /// Parses comments from TTL content using proper RDF parsing.

  static Map<String, String> commentsFromTurtle(String ttlContent) {
    try {
      // First try JSON backup for backward compatibility.

      final jsonMatch = RegExp(r'# JSON_DATA: (.+)').firstMatch(ttlContent);
      if (jsonMatch != null) {
        final jsonData = jsonMatch.group(1)!;
        final decoded = jsonDecode(jsonData) as Map<String, dynamic>;
        return decoded.cast<String, String>();
      }

      // Parse using proper RDF.

      final triples = turtleToTripleMap(ttlContent);
      final comments = <String, String>{};

      // Find comment resources.

      for (final subject in triples.keys) {
        final predicates = triples[subject]!;

        // Check if this is a comment resource.

        final typeValues =
            predicates['http://www.w3.org/1999/02/22-rdf-syntax-ns#type'] ?? [];
        final isComment = typeValues.any(
          (type) => type.toString().contains('Comment') || type == '#Comment',
        );

        if (isComment) {
          final movieIdValues = predicates['#movieId'] ?? [];
          final textValues = predicates['#text'] ?? [];

          if (movieIdValues.isNotEmpty && textValues.isNotEmpty) {
            final movieId = movieIdValues.first.toString();
            final comment = textValues.first.toString();
            comments[movieId] = comment;
          }
        }
      }

      return comments;
    } catch (e) {
      return {};
    }
  }

  /// Enhanced serialization with JSON backup for compatibility.

  static String moviesToTurtleWithJson(List<Movie> movies, String listName) {
    final buffer = StringBuffer();

    // Add the proper TTL structure.

    buffer.writeln(moviesToTurtle(movies, listName));

    // Add JSON backup as comment for easy parsing and backward compatibility.

    buffer.writeln();
    buffer.writeln(
      '# JSON_DATA: ${jsonEncode(movies.map((m) => m.toJson()).toList())}',
    );

    return buffer.toString();
  }

  /// Enhanced ratings serialization with JSON backup.

  static String ratingsToTurtleWithJson(Map<String, double> ratings) {
    final buffer = StringBuffer();

    // Add proper TTL structure.

    buffer.writeln(ratingsToTurtle(ratings));

    // Add JSON backup as comment.

    buffer.writeln();
    buffer.writeln('# JSON_DATA: ${jsonEncode(ratings)}');

    return buffer.toString();
  }

  /// Enhanced comments serialization with JSON backup.

  static String commentsToTurtleWithJson(Map<String, String> comments) {
    final buffer = StringBuffer();

    // Add proper TTL structure.

    buffer.writeln(commentsToTurtle(comments));

    // Add JSON backup as comment.

    buffer.writeln();
    buffer.writeln('# JSON_DATA: ${jsonEncode(comments)}');

    return buffer.toString();
  }

  /// Extract Movie object from RDF triples.

  static Movie? _extractMovieFromTriples(
    Map<String, List<dynamic>> predicates,
  ) {
    try {
      // Try different namespace variations for predicates.

      final idValues =
          predicates['http://schema.org/identifier'] ??
          predicates['identifier'] ??
          predicates['#identifier'] ??
          [];
      final titleValues =
          predicates['http://schema.org/name'] ??
          predicates['name'] ??
          predicates['#name'] ??
          [];
      final overviewValues =
          predicates['http://schema.org/description'] ??
          predicates['description'] ??
          predicates['#description'] ??
          [];
      final posterValues =
          predicates['http://schema.org/image'] ??
          predicates['image'] ??
          predicates['#image'] ??
          [];
      final backdropValues =
          predicates['http://schema.org/thumbnailUrl'] ??
          predicates['thumbnailUrl'] ??
          predicates['#thumbnailUrl'] ??
          [];
      final ratingValues =
          predicates['http://schema.org/aggregateRating'] ??
          predicates['aggregateRating'] ??
          predicates['#aggregateRating'] ??
          [];
      final dateValues =
          predicates['http://schema.org/datePublished'] ??
          predicates['datePublished'] ??
          predicates['#datePublished'] ??
          [];
      final genreValues =
          predicates['http://schema.org/genre'] ??
          predicates['genre'] ??
          predicates['#genre'] ??
          [];

      if (idValues.isEmpty || titleValues.isEmpty) {
        return null;
      }

      final id = int.tryParse(idValues.first.toString()) ?? 0;
      final title = titleValues.first.toString();
      final overview =
          overviewValues.isNotEmpty ? overviewValues.first.toString() : '';
      final posterUrl =
          posterValues.isNotEmpty ? posterValues.first.toString() : '';
      final backdropUrl =
          backdropValues.isNotEmpty ? backdropValues.first.toString() : '';
      final voteAverage =
          double.tryParse(
            ratingValues.isNotEmpty ? ratingValues.first.toString() : '0',
          ) ??
          0.0;
      final releaseDate =
          dateValues.isNotEmpty
              ? DateTime.tryParse(dateValues.first.toString()) ?? DateTime.now()
              : DateTime.now();
      final genreString =
          genreValues.isNotEmpty ? genreValues.first.toString() : '';
      final genreIds =
          genreString.isNotEmpty
              ? genreString
                  .split(',')
                  .map((s) => int.tryParse(s.trim()) ?? 0)
                  .toList()
              : <int>[];

      return Movie(
        id: id,
        title: title,
        overview: overview,
        posterUrl: posterUrl,
        backdropUrl: backdropUrl,
        voteAverage: voteAverage,
        releaseDate: releaseDate,
        genreIds: genreIds,
      );
    } catch (e) {
      return null;
    }
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
