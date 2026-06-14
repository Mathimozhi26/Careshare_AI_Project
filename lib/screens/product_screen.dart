import 'package:flutter/material.dart';
import '../services/gemini_service.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});
  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final _ctrl = TextEditingController();
  bool _loading = false;
  String _result = '', _product = '';
  String _compatibilityLevel = '';

  final _popular = [
    'Minimalist Niacinamide 10%', 'Dot & Key Vitamin C Serum',
    'Mamaearth Onion Hair Oil', 'Plum Green Tea Toner',
    'WOW Apple Cider Vinegar Shampoo', 'mCaffeine Coffee Face Scrub',
    'Re\'equil Oily Skin Sunscreen', 'Aqualogica Glow+ Moisturiser',
  ];

  Future<void> _analyze(String product) async {
    if (product.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() { _loading = true; _result = ''; _product = product; _compatibilityLevel = ''; });
    try {
      final r = await GeminiService.analyzeProduct(product);
      final level = _detectCompatibility(r);
      setState(() { _result = r; _loading = false; _compatibilityLevel = level; });
    } catch (e) {
      setState(() { _result = 'Analysis failed: $e\n\nPlease add your API key in Profile > Settings.'; _loading = false; _compatibilityLevel = 'error'; });
    }
  }

  String _detectCompatibility(String result) {
    final lower = result.toLowerCase();
    if (lower.contains('avoid')) return 'avoid';
    if (lower.contains('caution')) return 'caution';
    return 'safe';
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('product_screen'),
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('Product checker'),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 0.5, color: const Color(0xFF1A1A1A))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: TextField(
                key: const Key('product_search_field'),
                controller: _ctrl,
                style: const TextStyle(color: Color(0xFFF0EDE6)),
                decoration: InputDecoration(
                  hintText: 'Type any product name...',
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF555555), size: 20),
                  suffixIcon: _ctrl.text.isNotEmpty
                      ? IconButton(key: const Key('clear_search'), icon: const Icon(Icons.clear_rounded, color: Color(0xFF555555), size: 18), onPressed: () { _ctrl.clear(); setState(() {}); })
                      : null,
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: _analyze,
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              key: const Key('analyze_button'),
              onTap: () => _analyze(_ctrl.text),
              child: Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFC9A84C), Color(0xFFE8C97A)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF0A0A0A), size: 22),
              ),
            ),
          ]),
          const SizedBox(height: 20),

          if (_loading) ...[
            const SizedBox(height: 40),
            Center(child: Column(children: [
              const CircularProgressIndicator(key: Key('product_loading'), color: Color(0xFFC9A84C), strokeWidth: 2),
              const SizedBox(height: 16),
              Text('Analysing "$_product"...', style: const TextStyle(color: Color(0xFF888888), fontSize: 14)),
              const SizedBox(height: 6),
              const Text('Checking against your profile', style: TextStyle(color: Color(0xFF444444), fontSize: 12)),
            ])),
          ] else if (_result.isNotEmpty) ...[
            Container(
              key: const Key('product_result_card'),
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF2A2A2A))),
                    child: const Text('🧴', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_product, style: const TextStyle(color: Color(0xFFF0EDE6), fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    _compatBadge(_compatibilityLevel),
                  ])),
                ]),
                const Divider(color: Color(0xFF1E1E1E), height: 20),
                Text(_result, key: const Key('product_analysis_text'), style: const TextStyle(color: Color(0xFFD4B896), fontSize: 13, height: 1.7)),
                const SizedBox(height: 12),
                GestureDetector(
                  key: const Key('check_another_button'),
                  onTap: () => setState(() { _result = ''; _ctrl.clear(); _compatibilityLevel = ''; }),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF2A2A2A))),
                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.refresh_rounded, color: Color(0xFF666666), size: 16),
                      SizedBox(width: 8),
                      Text('Check another product', style: TextStyle(color: Color(0xFF888888), fontSize: 13)),
                    ]),
                  ),
                ),
              ]),
            ),
          ] else ...[
            const Text('POPULAR IN INDIA', style: TextStyle(color: Color(0xFF444444), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _popular.asMap().entries.map((e) => GestureDetector(
                key: Key('popular_product_${e.key}'),
                onTap: () { _ctrl.text = e.value; _analyze(e.value); },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF2A2A2A))),
                  child: Text(e.value, style: const TextStyle(color: Color(0xFF888888), fontSize: 12)),
                ),
              )).toList(),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _compatBadge(String level) {
    final configs = {
      'safe': (const Color(0xFF0D2B1A), const Color(0xFF4ADE80), '✓ Safe for you'),
      'caution': (const Color(0xFF2B1F0A), const Color(0xFFFCD34D), '⚠ Use with caution'),
      'avoid': (const Color(0xFF2B0A0A), const Color(0xFFF87171), '✕ Avoid'),
      'error': (const Color(0xFF1A1A1A), const Color(0xFF666666), '— Unable to analyse'),
    };
    final c = configs[level] ?? configs['safe']!;
    return Container(
      key: Key('compatibility_badge_$level'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: c.$1, borderRadius: BorderRadius.circular(20), border: Border.all(color: c.$2.withOpacity(0.4))),
      child: Text(c.$3, style: TextStyle(color: c.$2, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
