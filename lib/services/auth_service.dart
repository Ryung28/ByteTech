import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobileapplication/services/user_cache_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final UserCacheService _cacheService;
  
  static final AuthService _instance = AuthService._internal();
  
  factory AuthService() {
    return _instance;
  }
  
  AuthService._internal();
  
  Future<void> initialize() async {
    _cacheService = await UserCacheService.init();
    
    if (_cacheService.isUserCached()) {
      final token = _cacheService.getAuthToken();
      if (token != null) {
        try {
          await _auth.signInWithCustomToken(token);
        } catch (e) {
          await _cacheService.clearCache();
        }
      }
    }
  }

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        await _cacheService.cacheUser(userCredential.user!);
      }
      
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _cacheService.clearCache();
    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Map<String, dynamic>? getCachedUserData() {
    return _cacheService.getCachedUser();
  }

  bool isLoggedIn() {
    return _auth.currentUser != null || _cacheService.isUserCached();
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
