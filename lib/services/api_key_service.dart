import 'package:shared_preferences/shared_preferences.dart';

class ApiKeyService {
  static const String _apiKeyPrefsKey = 'movie_db_api_key';
  final SharedPreferences _prefs;

  ApiKeyService(this._prefs);

  String? getApiKey() {
    return _prefs.getString(_apiKeyPrefsKey);
  }

  Future<void> setApiKey(String apiKey) async {
    await _prefs.setString(_apiKeyPrefsKey, apiKey);
  }

  Future<void> clearApiKey() async {
    await _prefs.remove(_apiKeyPrefsKey);
  }
}
