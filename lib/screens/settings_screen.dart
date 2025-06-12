/// Screen for managing user settings and preferences.
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

library;

import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:moviestar/screens/to_watch_screen.dart';
import 'package:moviestar/screens/watched_screen.dart';
import 'package:moviestar/services/api_key_service.dart';
import 'package:moviestar/services/favorites_service.dart';
import 'package:moviestar/services/favorites_service_manager.dart';

/// A screen that displays and manages user settings.

class SettingsScreen extends StatefulWidget {
  /// Service for managing favorite movies.

  final FavoritesService favoritesService;
  final FavoritesServiceManager? favoritesServiceManager;
  final ApiKeyService apiKeyService;

  /// Whether this screen was opened from the API key prompt.

  final bool fromApiKeyPrompt;

  /// Creates a new [SettingsScreen] widget.

  const SettingsScreen({
    super.key,
    required this.favoritesService,
    required this.apiKeyService,
    this.favoritesServiceManager,
    this.fromApiKeyPrompt = false,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

/// State class for the settings screen.

class _SettingsScreenState extends State<SettingsScreen> {
  /// Whether notifications are enabled.

  bool _notificationsEnabled = true;

  /// Whether auto-play is enabled.

  bool _autoPlayEnabled = true;

  /// Whether POD storage is enabled.

  bool _podStorageEnabled = false;

  /// Selected language for the app.

  String _selectedLanguage = 'English';

  /// Selected video quality.

  String _selectedQuality = 'High';

  /// Controller for the API key input field.

  late final TextEditingController _apiKeyController;

  /// Focus node for the API key input field.

  final FocusNode _apiKeyFocusNode = FocusNode();

  /// Launch a URL in the browser.

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  /// Enable POD storage and migrate data.

  Future<void> _enablePodStorage() async {
    if (widget.favoritesServiceManager == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('POD storage manager not available.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Show loading indicator.

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('Enabling POD storage...'),
            ],
          ),
          duration: Duration(seconds: 10),
        ),
      );
    }

    try {
      final success = await widget.favoritesServiceManager!.enablePodStorage();

      if (success) {
        setState(() => _podStorageEnabled = true);

        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'POD storage enabled successfully! Your movie lists are now stored in your Solid POD.',
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 5),
            ),
          );
        }
      } else {
        setState(() => _podStorageEnabled = false);

        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Failed to enable POD storage. Please check your Solid POD login and try again.',
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _podStorageEnabled = false);

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error enabling POD storage: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  /// Disable POD storage and revert to local storage.

  Future<void> _disablePodStorage() async {
    if (widget.favoritesServiceManager == null) return;

    try {
      await widget.favoritesServiceManager!.disablePodStorage();
      setState(() => _podStorageEnabled = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('POD storage disabled. Using local storage.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error disabling POD storage: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController(
      text: widget.apiKeyService.getApiKey(),
    );

    // Initialise POD storage state from service manager.

    if (widget.favoritesServiceManager != null) {
      _podStorageEnabled = widget.favoritesServiceManager!.isPodStorageEnabled;
    }

    // If navigated from API key prompt, scroll to the API key section and focus the field.

    if (widget.fromApiKeyPrompt) {
      // Use post-frame callback to ensure the widget is fully built.

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _apiKeyFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _apiKeyFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),

          // Profile Picture.
          Center(
            child: Stack(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Settings Sections.
          _buildSection('API Configuration', [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MovieDB API Key',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: const Text(
                          'Required to fetch movie data and images',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                      if (widget.fromApiKeyPrompt)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Required',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _apiKeyController,
                    style: const TextStyle(color: Colors.white),
                    focusNode: _apiKeyFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Enter your MovieDB API key',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      // Launch TMDB website to get API key.

                      final Uri url = Uri.parse(
                        'https://www.themoviedb.org/?language=en-AU',
                      );
                      _launchUrl(url);
                    },
                    child: const Text(
                      'Get your API key from The Movie Database (TMDB)',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await widget.apiKeyService.setApiKey(
                        _apiKeyController.text,
                      );

                      if (!context.mounted) return;

                      if (mounted) {
                        // Show success message.

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('API key saved successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        // If we navigated here from the API key prompt, navigate back to home.

                        if (widget.fromApiKeyPrompt) {
                          _navigateToHomeScreen();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Save API Key'),
                  ),
                ],
              ),
            ),
          ]),
          _buildSection('Data Storage', [
            _buildSwitchTile(
              'Use Solid POD Storage',
              'Store movie lists in your Solid POD instead of locally',
              _podStorageEnabled,
              (value) async {
                if (value) {
                  await _enablePodStorage();
                } else {
                  await _disablePodStorage();
                }
              },
            ),
          ]),
          _buildSection('Preferences', [
            _buildSwitchTile(
              'Notifications',
              'Get notified about new releases',
              _notificationsEnabled,
              (value) => setState(() => _notificationsEnabled = value),
            ),
            _buildSwitchTile(
              'Auto-play',
              'Play next episode automatically',
              _autoPlayEnabled,
              (value) => setState(() => _autoPlayEnabled = value),
            ),
          ]),
          _buildSection('Playback', [
            _buildDropdownTile(
              'Language',
              _selectedLanguage,
              ['English', 'Spanish', 'French', 'German'],
              (value) => setState(() => _selectedLanguage = value!),
            ),
            _buildDropdownTile(
              'Video Quality',
              _selectedQuality,
              ['Low', 'Medium', 'High', 'Auto'],
              (value) => setState(() => _selectedQuality = value!),
            ),
          ]),
          _buildSection('Account', [
            _buildListTile('To Watch', Icons.favorite, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ToWatchScreen(
                        favoritesService: widget.favoritesService,
                      ),
                ),
              );
            }),
            _buildListTile('Watched', Icons.history, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => WatchedScreen(
                        favoritesService: widget.favoritesService,
                      ),
                ),
              );
            }),
            _buildListTile('Help & Support', Icons.help_outline, () {
              // TODO: Navigate to Help & Support.
            }),
            _buildListTile('Sign Out', Icons.logout, () {
              // TODO: Implement sign out.
            }, isDestructive: true),
          ]),
        ],
      ),
    );
  }

  /// Builds a section of settings with a title and children widgets.

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
        const Divider(color: Colors.grey),
      ],
    );
  }

  /// Builds a switch tile for boolean settings.

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.red,
    );
  }

  /// Builds a dropdown tile for selection settings.

  Widget _buildDropdownTile(
    String title,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: DropdownButton<String>(
        value: value,
        items:
            items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
        onChanged: onChanged,
        dropdownColor: Colors.grey[900],
        underline: const SizedBox(),
      ),
    );
  }

  /// Builds a list tile for navigation items.

  Widget _buildListTile(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.white),
      title: Text(
        title,
        style: TextStyle(color: isDestructive ? Colors.red : Colors.white),
      ),
      onTap: onTap,
    );
  }

  void _navigateToHomeScreen() {
    // Navigate back to the main home screen.

    Navigator.of(context).popUntil((route) => route.isFirst);

    // Find the MyHomePage instance.

    final scaffoldContext = context;

    // Try to find the nearest ancestor of type MyHomePage (or its State) and select the Home tab (index 0).

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Use the scaffold to show a message to the user.

      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        const SnackBar(
          content: Text('Movie data will now load with your new API key'),
          backgroundColor: Colors.blue,
        ),
      );
    });
  }
}
