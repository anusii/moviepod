import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class ApiKeyService extends ChangeNotifier {
  static const String _apiKeySecureKey = 'movie_db_api_key';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  ApiKeyService();

  Future<String?> getApiKey() async {
    return await _secureStorage.read(key: _apiKeySecureKey);
  }

  Future<void> setApiKey(String apiKey) async {
    await _secureStorage.write(key: _apiKeySecureKey, value: apiKey);
    notifyListeners();
  }

  Future<void> clearApiKey() async {
    await _secureStorage.delete(key: _apiKeySecureKey);
    notifyListeners();
  }
}
