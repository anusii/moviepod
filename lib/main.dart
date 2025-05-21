/// Main entry point for the Movie Star application.
///
// Time-stamp: <Thursday 2025-04-10 11:47:48 +1000 Graham Williams>
///
/// Copyright (C) 2025, Software Innovation Institute, ANU.
///
/// Licensed under the GNU General Public License, Version 3 (the "License").
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html.
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// Authors: Kevin Wang

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moviestar/screens/coming_soon_screen.dart';
import 'package:moviestar/screens/downloads_screen.dart';
import 'package:moviestar/screens/home_screen.dart';
import 'package:moviestar/screens/settings_screen.dart';
import 'package:moviestar/services/api_key_service.dart';
import 'package:moviestar/services/movie_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moviestar/utils/create_solid_login.dart';
import 'package:moviestar/services/favorites_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(ProviderScope(child: MyApp(prefs: prefs)));
}

/// The root widget of the Movie Star application.
class MyApp extends StatelessWidget {
  /// Shared preferences instance for storing app data.
  final SharedPreferences prefs;

  /// Creates a new [MyApp] widget.
  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Star',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Builder(builder: (context) => createSolidLogin(context, prefs)),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final SharedPreferences prefs;
  const MyHomePage({super.key, required this.title, required this.prefs});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/// State class for the main screen.
class _MyHomePageState extends State<MyHomePage> {
  /// Index of the currently selected screen.
  int _selectedIndex = 0;

  /// Service for managing favorite movies.
  late final FavoritesService _favoritesService;
  late final ApiKeyService _apiKeyService;
  late final MovieService _movieService;

  /// List of screens to display in the bottom navigation bar.
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _favoritesService = FavoritesService(widget.prefs);
    _apiKeyService = ApiKeyService(widget.prefs);
    _movieService = MovieService(_apiKeyService);
    _screens = [
      HomeScreen(
        favoritesService: _favoritesService,
        movieService: _movieService,
      ),
      ComingSoonScreen(
        favoritesService: _favoritesService,
        movieService: _movieService,
      ),
      const DownloadsScreen(),
      SettingsScreen(
        favoritesService: _favoritesService,
        apiKeyService: _apiKeyService,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.upcoming),
            label: 'Coming Soon',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.download),
            label: 'Downloads',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Settings'),
        ],
      ),
    );
  }
}

/// A placeholder home page widget.
class HomePage extends StatelessWidget {
  /// Creates a new [HomePage] widget.
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Movie Star'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.movie, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            Text(
              'Welcome to Movie Star',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Your ultimate movie companion',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
