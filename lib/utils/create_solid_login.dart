/// Create Solid Login Widget.
//
// Time-stamp: <Thursday 2025-05-20 10:52:11 +1000 Graham Williams>
//
/// Copyright (C) 2025, Software Innovation Institute, ANU
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html
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
/// Authors: Ashley Tang

library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solidpod/solidpod.dart';

import 'package:moviestar/main.dart';

/// Creates a Solid login widget for authentication.
///
/// This is a simplified version that provides a standard Solid authentication
/// interface for applications that need to connect to Solid PODs.
///
/// Parameters:
///   context: BuildContext for widget creation
///   prefs: SharedPreferences for accessing user preferences
///
/// Returns:
///   A Widget configured for Solid authentication.

Widget createSolidLogin(BuildContext context, SharedPreferences prefs) {
  debugPrint('🔍 Setting up Solid login widget');

  return Consumer(
    builder: (context, ref, child) {
      final serverUrl = ref.watch(serverURLProvider);

      return _buildNormalLogin(serverUrl, prefs);
    },
  );
}

/// Build the normal login widget.

Widget _buildNormalLogin(String serverUrl, SharedPreferences prefs) {
  return Builder(
    builder: (context) {
      // Wrap SolidLogin in a container with custom image.

      return Container(
        // TODO: Replace with theme configuration.
        color: Colors.black,
        child: Column(
          children: [
            Expanded(
              child: SolidLogin(
                required: false,
                title: 'Movie Star',
                appDirectory: 'moviestar',
                webID:
                    serverUrl.isNotEmpty
                        ? serverUrl
                        : 'https://pods.dev.solidcommunity.au',
                image: const AssetImage('assets/images/app_image.png'),
                logo: const AssetImage('assets/images/app_icon.png'),
                link:
                    'https://github.com/yourusername/moviestar/blob/main/README.md',

                // TODO: Replace with proper home page.
                child: MyHomePage(title: 'Movie Star Home Page', prefs: prefs),
              ),
            ),
          ],
        ),
      );
    },
  );
}

// Define provider for server URL.

final serverURLProvider = StateProvider<String>((ref) => '');
