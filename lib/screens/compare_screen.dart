import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/gemini_service.dart';

class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});
  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  final _ctrlA = TextEditingController();
  final _ctrlB = TextEditingController();
  List<Map<String, String>> _saved = [];
  bool _loading = false;
  String _result = '';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('scan_history') ?? '[]';
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    setState(() => _saved = list.map((e) => e.map((k, v) => MapEntry(k, v.toString()))).toList());
  }

  void _pickProduct(bool isA) {
    if (_saved.isEmpty) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          const Text('Select a product', style: TextStyle(color: Color(0xFFF0EDE6), fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Expanded(child: ListView.builder(
            itemCount: _saved.length,
            itemBuilder: (_, i) => ListTile(
              title: Text(_saved[i]['name'] ?? '', style: const TextStyle(color: Color(0xFFD4B896)), maxLines: 1, overflow: TextOverflow.ellipsis),
              onTap: () {
                setState(() {
                  if (isA) { _ctrlA.text = _saved[i]['name'] ?? ''; } else { _ctrlB.text = _saved[i]['name'] ?? ''; }
                });
                Navigator.pop(ctx);
              },
            ),
          )),
        ]),
      ),
    );
  }

  Future<void> _compare() async {
    if (_ctrlA.text.trim().isEmpty || _ctrlB.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter or select both products')));
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() { _loading = true; _result = ''; });
    try {
      final r = await GeminiService.compareProducts(_ctrlA.text.trim(), _ctrlB.text.trim());
      setState(() { _result = r; _loading = false; });
    } catch (e) {
      setState(() { _result = 'Comparison failed: $e\n\nPlease add your API key in Profile > Settings.'; _loading = false; });
    }
  }

  @override
  void dispose() { _ctrlA.dispose(); _ctrlB.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('compare_screen'),
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('Compare products'),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 0.5, color: const Color(0xFF1A1A1A))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: [
            Expanded(child: _slot('Product A', _ctrlA, () => _pickProduct(true), 'slot_a')),
            const SizedBox(width: 12),
            Expanded(child: _slot('Product B', _ctrlB, () => _pickProduct(false), 'slot_b')),
          ]),
          const SizedBox(height: 16),
          GestureDetector(
            key: const Key('compare_button'),
            onTap: _compare,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFC9A84C), Color(0xFFE8C97A)]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(child: Text('Compare with AI', style: TextStyle(color: Color(0xFF0A0A0A), fontSize: 14, fontWeight: FontWeight.w700))),
            ),
          ),
          const SizedBox(height: 20),
          if (_loading) ...[
            const SizedBox(height: 30),
            const CircularProgressIndicator(key: Key('compare_loading'), color: Color(0xFFC9A84C), strokeWidth: 2),
            const SizedBox(height: 16),
            const Text('Comparing as your personalised skincare assistant...', style: TextStyle(color: Color(0xFF888888), fontSize: 13)),
          ],
          if (_result.isNotEmpty) ...[
            Container(
              key: const Key('comparison_result'),
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(children: [
                  Text('⚖️', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  Text('AI comparison', style: TextStyle(color: Color(0xFFC9A84C), fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                ]),
                const Divider(color: Color(0xFF1E1E1E), height: 20),
                Text(_result, style: const TextStyle(color: Color(0xFFD4B896), fontSize: 13, height: 1.7)),
              ]),
            ),
          ],
          if (_result.isEmpty && !_loading) ...[
            const SizedBox(height: 30),
            const Text('⚖️', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            const Text('Pick or type two products to compare', style: TextStyle(color: Color(0xFF555555), fontSize: 13)),
          ],
        ]),
      ),
    );
  }

  Widget _slot(String label, TextEditingController ctrl, VoidCallback onPick, String key) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF2A2A2A))),
      child: Column(children: [
        TextField(
          key: Key(key),
          controller: ctrl,
          style: const TextStyle(color: Color(0xFFF0EDE6), fontSize: 12),
          decoration: InputDecoration(hintText: label, hintStyle: const TextStyle(color: Color(0xFF555555), fontSize: 12), isDense: true, border: InputBorder.none),
        ),
        if (_saved.isNotEmpty)
          GestureDetector(
            onTap: onPick,
            child: const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text('Pick from history', style: TextStyle(color: Color(0xFFC9A84C), fontSize: 11)),
            ),
          ),
      ]),
    );
  }
}
