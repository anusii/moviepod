/// Service for managing API keys in the Movie Star application.
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

import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ApiKeyService extends ChangeNotifier {
  static const String _apiKeyPrefsKey = 'movie_db_api_key';
  final SharedPreferences _prefs;

  ApiKeyService(this._prefs);

  String? getApiKey() {
    return _prefs.getString(_apiKeyPrefsKey);
  }

  Future<void> setApiKey(String apiKey) async {
    await _prefs.setString(_apiKeyPrefsKey, apiKey);
    notifyListeners();
  }

  Future<void> clearApiKey() async {
    await _prefs.remove(_apiKeyPrefsKey);
    notifyListeners();
  }
}
