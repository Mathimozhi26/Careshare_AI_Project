import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_data_service.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});
  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  List<Map<String, String>> _favourites = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    // Try Firestore first
    final cloud = await UserDataService.fetchFavourites();
    if (cloud.isNotEmpty) {
      setState(() { _favourites = cloud; _loading = false; });
      final p = await SharedPreferences.getInstance();
      await p.setString('favourites', jsonEncode(cloud));
      return;
    }
    // Fallback to local cache
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('favourites') ?? '[]';
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    setState(() {
      _favourites = list.map((e) => e.map((k, v) => MapEntry(k, v.toString()))).toList();
      _loading = false;
    });
  }

  Future<void> _remove(int index) async {
    setState(() => _favourites.removeAt(index));
    final p = await SharedPreferences.getInstance();
    await p.setString('favourites', jsonEncode(_favourites));
    await UserDataService.saveFavourites(_favourites);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('favourites_screen'),
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('Favourites'),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 0.5, color: const Color(0xFF1A1A1A))),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC9A84C), strokeWidth: 2))
          : _favourites.isEmpty
              ? Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text('🤍', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    const Text('No favourites yet', style: TextStyle(color: Color(0xFFF0EDE6), fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    const Text('Save products you like from\nthe Product Checker', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF555555), fontSize: 13)),
                  ]),
                )
              : ListView.builder(
                  key: const Key('favourites_list'),
                  padding: const EdgeInsets.all(16),
                  itemCount: _favourites.length,
                  itemBuilder: (_, i) {
                    final item = _favourites[i];
                    return Container(
                      key: Key('favourite_item_\$i'),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF2A2A2A))),
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(10)),
                          child: const Text('🧴', style: TextStyle(fontSize: 16)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(item['name'] ?? '', style: const TextStyle(color: Color(0xFFF0EDE6), fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(item['date'] ?? '', style: const TextStyle(color: Color(0xFF555555), fontSize: 11)),
                        ])),
                        IconButton(
                          key: Key('remove_favourite_\$i'),
                          icon: const Icon(Icons.favorite_rounded, color: Color(0xFFC9A84C), size: 20),
                          onPressed: () => _remove(i),
                        ),
                      ]),
                    );
                  },
                ),
    );
  }
}
