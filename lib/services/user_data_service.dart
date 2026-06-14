import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDataService {
  static final _db = FirebaseFirestore.instance;

  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // Save full profile to Firestore
  static Future<void> saveProfile(Map<String, String> data) async {
    if (_uid == null) return;
    await _db.collection('users').doc(_uid).set(data, SetOptions(merge: true));
    // Also cache locally
    final prefs = await SharedPreferences.getInstance();
    for (final entry in data.entries) {
      await prefs.setString(entry.key, entry.value);
    }
  }

  // Fetch profile from Firestore and cache locally
  static Future<void> fetchAndCacheProfile() async {
    if (_uid == null) return;
    try {
      final doc = await _db.collection('users').doc(_uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final prefs = await SharedPreferences.getInstance();
        for (final entry in data.entries) {
          await prefs.setString(entry.key, entry.value.toString());
        }
      }
    } catch (e) {
      // Use cached local data if Firestore fails
    }
  }

  // Update a single field
  static Future<void> updateField(String key, String value) async {
    if (_uid == null) return;
    await _db.collection('users').doc(_uid).set({key: value}, SetOptions(merge: true));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  // Delete user data on logout
  static Future<void> clearLocalCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
