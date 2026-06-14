import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GeminiService {
  static const String _baseUrl = 'https://api.x.ai/v1/chat/completions';
  static const String _model = 'grok-3-mini';
  static const _secureStorage = FlutterSecureStorage();
  static const String _identity = 'You are CareShare AI, a personalised skincare assistant for Indian users. Always refer to yourself as a personalised skincare assistant. Never claim to be a doctor or dermatologist.';

  static Future<String> getApiKey() async {
    return await _secureStorage.read(key: 'api_key') ?? '';
  }

  static Future<void> saveApiKey(String key) async {
    await _secureStorage.write(key: 'api_key', value: key);
  }

  static Future<void> deleteApiKey() async {
    await _secureStorage.delete(key: 'api_key');
  }

  static Future<String> _userContext() async {
    final p = await SharedPreferences.getInstance();
    final name = p.getString('user_name') ?? 'User';
    final skin = p.getString('skin_type') ?? 'unknown';
    final hair = p.getString('hair_type') ?? 'unknown';
    final gender = p.getString('gender') ?? 'unknown';
    final allergies = p.getString('allergies') ?? 'none';
    final conditions = p.getString('conditions') ?? 'none';
    final cycle = p.getString('cycle_info') ?? '';
    return 'Name: $name | Gender: $gender | Skin: $skin | Hair: $hair | Allergies: $allergies | Conditions: $conditions${cycle.isNotEmpty ? ' | Cycle: $cycle' : ''}';
  }

  static String _sanitize(String input, {int maxLength = 500}) {
    final trimmed = input.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '').trim();
    return trimmed.length > maxLength ? trimmed.substring(0, maxLength) : trimmed;
  }

  static Future<String> _call(String system, String message) async {
    final apiKey = await getApiKey();
    if (apiKey.isEmpty) throw Exception('No API key set. Please add your API key in Profile > Settings.');
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $apiKey'},
      body: jsonEncode({'model': _model, 'messages': [{'role': 'system', 'content': system}, {'role': 'user', 'content': message}], 'max_tokens': 1024}),
    ).timeout(const Duration(seconds: 30));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['choices'][0]['message']['content'] as String;
    } else {
      throw Exception('API error ${response.statusCode}: ${jsonDecode(response.body)['error']['message']}');
    }
  }

  static Future<String> _callWithHistory(String system, List<Map<String, String>> messages) async {
    final apiKey = await getApiKey();
    if (apiKey.isEmpty) throw Exception('No API key set. Please add your API key in Profile > Settings.');
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $apiKey'},
      body: jsonEncode({'model': _model, 'messages': [{'role': 'system', 'content': system}, ...messages], 'max_tokens': 1024}),
    ).timeout(const Duration(seconds: 30));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['choices'][0]['message']['content'] as String;
    } else {
      throw Exception('API error ${response.statusCode}: ${jsonDecode(response.body)['error']['message']}');
    }
  }

  static Future<String> analyzeProduct(String product) async {
    final ctx = await _userContext();
    final clean = _sanitize(product, maxLength: 200);
    return await _call('$_identity User profile: $ctx. Analyse products for this user. Flag allergens and condition warnings.',
      'Analyse: "$clean"\n**Product Type**\n**Key Ingredients** - effects on this users skin/hair\n**Harmful Ingredients** - flag conflicts with their allergies/conditions\n**Compatibility** - SAFE/CAUTION/AVOID for this user\n**Verdict** - one personalised recommendation');
  }

  static Future<String> chat(String message, List<Map<String, String>> history) async {
    final ctx = await _userContext();
    final clean = _sanitize(message, maxLength: 2000);
    final system = '$_identity User profile: $ctx. Personalise advice for their skin/hair/conditions. Suggest Indian brands: Minimalist, Dot & Key, Mamaearth, Plum, mCaffeine, WOW, Aqualogica. Under 120 words unless asked more.';
    final msgs = [...history.map((m) => {'role': m['role'] == 'user' ? 'user' : 'assistant', 'content': m['content']!}), {'role': 'user', 'content': clean}];
    return await _callWithHistory(system, msgs);
  }

  static Future<String> getRecommendations(String category) async {
    final ctx = await _userContext();
    return await _call('$_identity User profile: $ctx. Give personalised Indian product recommendations 2024-2025.',
      'Top 5 Indian $category products for this user. For each: name & brand, why it suits their profile, key ingredients, price INR, where to buy.');
  }

  static Future<String> analyzeIngredients(String ingredientText) async {
    final ctx = await _userContext();
    final clean = _sanitize(ingredientText, maxLength: 3000);
    return await _call('$_identity User profile: $ctx. Analyse scanned ingredients for this user.',
      'Scanned product label:\n\n$clean\n\n**Product Type**\n**Key Ingredients** - effects on this users skin/hair\n**Harmful Ingredients** - flag conflicts with allergies/conditions\n**Compatibility** - SAFE/CAUTION/AVOID\n**Verdict** - personalised recommendation');
  }
}
