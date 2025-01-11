import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserCacheService {
  static const String _userKey = 'cached_user';
  static const String _tokenKey = 'auth_token';
  
  final SharedPreferences _prefs;
  
  UserCacheService(this._prefs);
  
  static Future<UserCacheService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return UserCacheService(prefs);
  }

  // Cache user data when they log in
  Future<void> cacheUser(User user) async {
    final userData = {
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
    };
    
    await _prefs.setString(_userKey, json.encode(userData));
    
    // Cache the auth token if available
    final token = await user.getIdToken();
    if (token != null) {
      await _prefs.setString(_tokenKey, token);
    }
  }

  // Get cached user data
  Map<String, dynamic>? getCachedUser() {
    final userStr = _prefs.getString(_userKey);
    if (userStr != null) {
      return json.decode(userStr) as Map<String, dynamic>;
    }
    return null;
  }

  // Clear cached user data on logout
  Future<void> clearCache() async {
    await _prefs.remove(_userKey);
    await _prefs.remove(_tokenKey);
  }

  // Check if user is cached
  bool isUserCached() {
    return _prefs.containsKey(_userKey);
  }

  // Get cached token
  String? getAuthToken() {
    return _prefs.getString(_tokenKey);
  }
}
