import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, String>> _history = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('scan_history') ?? '[]';
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    setState(() => _history = list.map((e) => e.map((k, v) => MapEntry(k, v.toString()))).toList().reversed.toList());
  }

  Future<void> _clearAll() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('scan_history', '[]');
    setState(() => _history = []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('history_screen'),
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          if (_history.isNotEmpty)
            IconButton(key: const Key('clear_history_button'), icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFF555555)), onPressed: _clearAll),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 0.5, color: const Color(0xFF1A1A1A))),
      ),
      body: _history.isEmpty
          ? Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('🕓', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                const Text('No history yet', style: TextStyle(color: Color(0xFFF0EDE6), fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                const Text('Products you check or scan\nwill appear here', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF555555), fontSize: 13)),
              ]),
            )
          : ListView.builder(
              key: const Key('history_list'),
              padding: const EdgeInsets.all(16),
              itemCount: _history.length,
              itemBuilder: (_, i) {
                final item = _history[i];
                final type = item['type'] ?? 'product';
                return Container(
                  key: Key('history_item_$i'),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF2A2A2A))),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(10)),
                      child: Text(type == 'scan' ? '📷' : '🔍', style: const TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item['name'] ?? '', style: const TextStyle(color: Color(0xFFF0EDE6), fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(item['date'] ?? '', style: const TextStyle(color: Color(0xFF555555), fontSize: 11)),
                    ])),
                  ]),
                );
              },
            ),
    );
  }
}
