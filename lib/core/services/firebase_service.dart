import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Firebase.initializeApp();
      _isInitialized = true;
      print('✅ Firebase initialized successfully');
    } catch (e) {
      print('❌ Firebase initialization failed: $e');
      throw Exception('فشل في تهيئة Firebase: $e');
    }
  }

  static bool get isInitialized => _isInitialized;
}