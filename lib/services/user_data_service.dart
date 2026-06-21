import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDataService {
  static final _db = FirebaseFirestore.instance;

  static String? get _email => FirebaseAuth.instance.currentUser?.email;

  // Save full profile to Firestore using email as primary key
  static Future<void> saveProfile(Map<String, String> data) async {
    if (_email == null) return;
    final docData = Map<String, String>.from(data);
    docData['user_email'] = _email!;
    docData['uid'] = FirebaseAuth.instance.currentUser?.uid ?? '';
    docData['updated_at'] = DateTime.now().toIso8601String();
    
    await _db.collection('users').doc(_email).set(docData, SetOptions(merge: true));
    
    // Cache locally
    final prefs = await SharedPreferences.getInstance();
    for (final entry in docData.entries) {
      await prefs.setString(entry.key, entry.value);
    }
  }

  // Fetch profile from Firestore using email as key
  static Future<void> fetchAndCacheProfile() async {
    if (_email == null) return;
    try {
      final doc = await _db.collection('users').doc(_email).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        final prefs = await SharedPreferences.getInstance();
        for (final entry in data.entries) {
          if (entry.value != null) {
            await prefs.setString(entry.key, entry.value.toString());
          }
        }
        print('Profile fetched for: ' + (_email ?? 'unknown'));
      } else {
        print('No Firestore profile found for: ' + (_email ?? 'unknown'));
      }
    } catch (e) {
      print('Firestore fetch error: \$e');
    }
  }

  // Update a single field using email as key
  static Future<void> updateField(String key, String value) async {
    if (_email == null) return;
    await _db.collection('users').doc(_email).set({
      key: value,
      'user_email': _email!,
      'updated_at': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  // Save favourites list to Firestore
  static Future<void> saveFavourites(List<Map<String, String>> favourites) async {
    if (_email == null) return;
    await _db.collection('users').doc(_email).set({
      'favourites': favourites,
      'updated_at': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  // Fetch favourites from Firestore
  static Future<List<Map<String, String>>> fetchFavourites() async {
    if (_email == null) return [];
    try {
      final doc = await _db.collection('users').doc(_email).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        final raw = data['favourites'];
        if (raw is List) {
          return raw.map((e) => Map<String, String>.from(
            (e as Map).map((k, v) => MapEntry(k.toString(), v.toString()))
          )).toList();
        }
      }
    } catch (e) {
      print('Fetch favourites error: ' + e.toString());
    }
    return [];
  }

  // Clear local cache on logout
  static Future<void> clearLocalCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
