import 'package:flutter/material.dart';

class TipsFeedScreen extends StatelessWidget {
  const TipsFeedScreen({super.key});

  static const _tips = [
    {'emoji': '💧', 'title': 'Hydration is key', 'body': 'Drink at least 8 glasses of water daily. Hydrated skin from within shows on the outside — it improves elasticity and reduces dryness.'},
    {'emoji': '☀️', 'title': 'Never skip sunscreen', 'body': 'Even on cloudy days, UV rays cause premature ageing and pigmentation. Use at least SPF 30, reapply every 3-4 hours outdoors.'},
    {'emoji': '🧼', 'title': 'Double cleansing for makeup days', 'body': 'Use an oil cleanser first to dissolve makeup and sunscreen, then a water-based cleanser to remove remaining dirt.'},
    {'emoji': '🌙', 'title': 'Retinol at night only', 'body': 'Retinol increases sun sensitivity. Always use it in your night routine and follow with sunscreen the next morning.'},
    {'emoji': '🥗', 'title': 'Skin reflects your diet', 'body': 'Foods rich in Vitamin C, E and Omega-3 (citrus, nuts, fish) support collagen production and reduce inflammation.'},
    {'emoji': '🧴', 'title': 'Patch test new products', 'body': 'Apply a small amount on your inner arm and wait 24-48 hours before using a new product on your face.'},
    {'emoji': '💤', 'title': 'Sleep on a clean pillowcase', 'body': 'Change pillowcases twice a week. Bacteria and oil buildup on pillowcases can trigger breakouts.'},
    {'emoji': '🧊', 'title': 'Don\'t over-exfoliate', 'body': 'Limit exfoliation to 2-3 times a week. Over-exfoliating damages your skin barrier and causes sensitivity.'},
    {'emoji': '🌿', 'title': 'Niacinamide for oily skin', 'body': 'Niacinamide regulates sebum production and minimises the appearance of pores — great for Indian humid climates.'},
    {'emoji': '🪥', 'title': 'Hair oiling before wash', 'body': 'Oiling your scalp 1-2 hours before a hair wash with coconut or castor oil strengthens roots and reduces frizz.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('tips_feed_screen'),
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('Daily tips'),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 0.5, color: const Color(0xFF1A1A1A))),
      ),
      body: ListView.builder(
        key: const Key('tips_list'),
        padding: const EdgeInsets.all(16),
        itemCount: _tips.length,
        itemBuilder: (_, i) {
          final tip = _tips[i];
          return Container(
            key: Key('tip_card_$i'),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2A2A2A))),
                child: Center(child: Text(tip['emoji']!, style: const TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tip['title']!, style: const TextStyle(color: Color(0xFFF0EDE6), fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(tip['body']!, style: const TextStyle(color: Color(0xFF888888), fontSize: 13, height: 1.5)),
              ])),
            ]),
          );
        },
      ),
    );
  }
}
