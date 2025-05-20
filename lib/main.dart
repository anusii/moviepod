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
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/coming_soon_screen.dart';
import 'screens/downloads_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/search_screen.dart';
import 'services/favorites_service.dart';

/// Initializes the application and sets up shared preferences.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
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
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: MainScreen(prefs: prefs),
    );
  }
}

/// The main screen containing the bottom navigation bar and screen management.
class MainScreen extends StatefulWidget {
  /// Shared preferences instance for storing app data.
  final SharedPreferences prefs;

  /// Creates a new [MainScreen] widget.
  const MainScreen({super.key, required this.prefs});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

/// State class for the main screen.
class _MainScreenState extends State<MainScreen> {
  /// Index of the currently selected screen.
  int _selectedIndex = 0;

  /// Service for managing favorite movies.
  late final FavoritesService _favoritesService;

  /// List of screens to display in the bottom navigation bar.
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _favoritesService = FavoritesService(widget.prefs);
    _screens = [
      HomeScreen(favoritesService: _favoritesService),
      ComingSoonScreen(favoritesService: _favoritesService),
      const DownloadsScreen(),
      ProfileScreen(favoritesService: _favoritesService),
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
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
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
