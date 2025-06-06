import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class ApiKeyService extends ChangeNotifier {
  static const String _apiKeySecureKey = 'movie_db_api_key';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
    mOptions: MacOsOptions(groupId: 'com.togaware.moviestar'),
  );

  ApiKeyService();

  Future<String?> getApiKey() async {
    try {
      return await _secureStorage.read(key: _apiKeySecureKey);
    } catch (e) {
      debugPrint('Error reading API key from secure storage: $e');
      return null;
    }
  }

  Future<void> setApiKey(String apiKey) async {
    try {
      await _secureStorage.write(key: _apiKeySecureKey, value: apiKey);
      notifyListeners();
    } catch (e) {
      debugPrint('Error writing API key to secure storage: $e');
      rethrow;
    }
  }

  Future<void> clearApiKey() async {
    try {
      await _secureStorage.delete(key: _apiKeySecureKey);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting API key from secure storage: $e');
      rethrow;
    }
  }
}
