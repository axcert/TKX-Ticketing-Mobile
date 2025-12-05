import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  // Initialize SharedPreferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Ensure preferences are initialized
  Future<SharedPreferences> get _preferences async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  // Save authentication token
  Future<bool> saveAuthToken(String token) async {
    final prefs = await _preferences;
    return await prefs.setString(AppConfig.authTokenKey, token);
  }

  // Get authentication token
  Future<String?> getAuthToken() async {
    final prefs = await _preferences;
    return prefs.getString(AppConfig.authTokenKey);
  }

  // Remove authentication token
  Future<bool> removeAuthToken() async {
    final prefs = await _preferences;
    return await prefs.remove(AppConfig.authTokenKey);
  }

  // Save token expiration time (as milliseconds since epoch)
  Future<bool> saveTokenExpiration(int expiresInSeconds) async {
    final prefs = await _preferences;
    final expirationTime =
        DateTime.now().millisecondsSinceEpoch + (expiresInSeconds * 1000);
    return await prefs.setInt('token_expiration', expirationTime);
  }

  // Get token expiration time
  Future<int?> getTokenExpiration() async {
    final prefs = await _preferences;
    return prefs.getInt('token_expiration');
  }

  // Check if token is expired
  Future<bool> isTokenExpired() async {
    final expirationTime = await getTokenExpiration();
    if (expirationTime == null) return true;

    final currentTime = DateTime.now().millisecondsSinceEpoch;
    return currentTime >= expirationTime;
  }

  // Save refresh token
  Future<bool> saveRefreshToken(String token) async {
    final prefs = await _preferences;
    return await prefs.setString(AppConfig.refreshTokenKey, token);
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    final prefs = await _preferences;
    return prefs.getString(AppConfig.refreshTokenKey);
  }

  // Save user ID
  Future<bool> saveUserId(String userId) async {
    final prefs = await _preferences;
    return await prefs.setString(AppConfig.userIdKey, userId);
  }

  // Get user ID
  Future<String?> getUserId() async {
    final prefs = await _preferences;
    return prefs.getString(AppConfig.userIdKey);
  }

  // Save user email
  Future<bool> saveUserEmail(String email) async {
    final prefs = await _preferences;
    return await prefs.setString(AppConfig.userEmailKey, email);
  }

  // Get user email
  Future<String?> getUserEmail() async {
    final prefs = await _preferences;
    return prefs.getString(AppConfig.userEmailKey);
  }

  // Set login status
  Future<bool> setLoggedIn(bool isLoggedIn) async {
    final prefs = await _preferences;
    return await prefs.setBool(AppConfig.isLoggedInKey, isLoggedIn);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await _preferences;
    return prefs.getBool(AppConfig.isLoggedInKey) ?? false;
  }

  // Clear all user data (logout)
  Future<bool> clearAll() async {
    final prefs = await _preferences;
    return await prefs.clear();
  }

  // Save user data (userId and email)
  Future<void> saveUserData({
    required String userId,
    required String email,
  }) async {
    await saveUserId(userId);
    await saveUserEmail(email);
    await setLoggedIn(true);
  }

  // Clear specific user data (logout but keep app settings)
  Future<void> clearUserData() async {
    await removeAuthToken();
    await _removeKey(AppConfig.refreshTokenKey);
    await _removeKey(AppConfig.userIdKey);
    await _removeKey(AppConfig.userEmailKey);
    await _removeKey('token_expiration');
    await setLoggedIn(false);
  }

  // Generic save methods
  Future<bool> saveString(String key, String value) async {
    final prefs = await _preferences;
    return await prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final prefs = await _preferences;
    return prefs.getString(key);
  }

  Future<bool> saveInt(String key, int value) async {
    final prefs = await _preferences;
    return await prefs.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    final prefs = await _preferences;
    return prefs.getInt(key);
  }

  Future<bool> saveBool(String key, bool value) async {
    final prefs = await _preferences;
    return await prefs.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    final prefs = await _preferences;
    return prefs.getBool(key);
  }

  Future<bool> saveDouble(String key, double value) async {
    final prefs = await _preferences;
    return await prefs.setDouble(key, value);
  }

  Future<double?> getDouble(String key) async {
    final prefs = await _preferences;
    return prefs.getDouble(key);
  }

  Future<bool> saveStringList(String key, List<String> value) async {
    final prefs = await _preferences;
    return await prefs.setStringList(key, value);
  }

  Future<List<String>?> getStringList(String key) async {
    final prefs = await _preferences;
    return prefs.getStringList(key);
  }

  // Remove a specific key
  Future<bool> _removeKey(String key) async {
    final prefs = await _preferences;
    return await prefs.remove(key);
  }

  // Check if a key exists
  Future<bool> hasKey(String key) async {
    final prefs = await _preferences;
    return prefs.containsKey(key);
  }

  // Save a bool
  Future<void> setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }
}
