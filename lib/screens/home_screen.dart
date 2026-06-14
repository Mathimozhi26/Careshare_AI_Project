import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_screen.dart';
import 'product_screen.dart';
import 'profile_screen.dart';
import 'scanner_screen.dart';
import '../services/gemini_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _idx = 0;
  String _name = '', _skin = '', _hair = '';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _name = p.getString('user_name') ?? 'there';
      _skin = p.getString('skin_type') ?? '';
      _hair = p.getString('hair_type') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeTab(name: _name, skin: _skin, hair: _hair),
      const ProductScreen(),
      const ScannerScreen(),
      const ChatScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: pages[_idx],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.science_outlined), selectedIcon: Icon(Icons.science_rounded), label: 'Products'),
          NavigationDestination(icon: Icon(Icons.qr_code_scanner_outlined), selectedIcon: Icon(Icons.qr_code_scanner_rounded), label: 'Scanner'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline_rounded), selectedIcon: Icon(Icons.chat_bubble_rounded), label: 'AI Chat'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  final String name, skin, hair;
  const _HomeTab({required this.name, required this.skin, required this.hair});
  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  bool _tipLoading = false;
  String _tip = 'Tap ✦ to get your personalised daily insight';

  Future<void> _getTip() async {
    if (_tipLoading) return;
    setState(() => _tipLoading = true);
    try {
      final t = await GeminiService.chat('Give me one personalised skincare or haircare tip for today. Max 2 sentences. Be specific to my profile.', []);
      setState(() { _tip = t; _tipLoading = false; });
    } catch (_) {
      setState(() { _tip = 'Stay hydrated, use SPF 30+, and double cleanse tonight.'; _tipLoading = false; });
    }
  }

  Future<void> _showRecs(BuildContext ctx, String cat) async {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (_) => _RecsSheet(category: cat),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_greeting(), style: const TextStyle(color: Color(0xFF555555), fontSize: 13)),
                const SizedBox(height: 2),
                Text(widget.name, style: const TextStyle(color: Color(0xFFF0EDE6), fontSize: 22, fontWeight: FontWeight.w700)),
              ]),
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFC9A84C), Color(0xFFE8C97A)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(child: Text(widget.name.isNotEmpty ? widget.name[0].toUpperCase() : 'C', style: const TextStyle(color: Color(0xFF0A0A0A), fontSize: 18, fontWeight: FontWeight.w700))),
              ),
            ]),
            const SizedBox(height: 16),
            if (widget.skin.isNotEmpty || widget.hair.isNotEmpty)
              Wrap(spacing: 6, children: [
                if (widget.skin.isNotEmpty) _profileChip('${widget.skin} skin'),
                if (widget.hair.isNotEmpty) _profileChip('${widget.hair} hair'),
              ]),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFC9A84C).withOpacity(0.25)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Text('✦', style: TextStyle(color: Color(0xFFC9A84C), fontSize: 14)),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('Daily insight', style: TextStyle(color: Color(0xFF888888), fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5))),
                  GestureDetector(
                    onTap: _getTip,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF2A2A2A))),
                      child: _tipLoading
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFFC9A84C)))
                          : const Icon(Icons.refresh_rounded, size: 14, color: Color(0xFF666666)),
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                Text(_tip, style: const TextStyle(color: Color(0xFFD4B896), fontSize: 14, height: 1.6)),
              ]),
            ),
            const SizedBox(height: 24),
            const Text('QUICK ACTIONS', style: TextStyle(color: Color(0xFF444444), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.15,
              children: [
                _ActionCard(emoji: '🔬', title: 'Check product', subtitle: 'Scan or type name', gold: true,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductScreen()))),
                _ActionCard(emoji: '💬', title: 'Ask AI', subtitle: 'Your dermatologist',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()))),
                _ActionCard(emoji: '💆', title: 'Skincare', subtitle: 'Personalised picks',
                    onTap: () => _showRecs(context, 'skincare')),
                _ActionCard(emoji: '💇', title: 'Haircare', subtitle: 'For your hair type',
                    onTap: () => _showRecs(context, 'haircare')),
              ],
            ),
            const SizedBox(height: 24),
            const Text('ABOUT YOUR SKIN', style: TextStyle(color: Color(0xFF444444), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            _InfoCard(),
          ]),
        ),
      ),
    );
  }

  Widget _profileChip(String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1507),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC9A84C).withOpacity(0.3)),
      ),
      child: Text(label, style: const TextStyle(color: Color(0xFFC9A84C), fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }
}

class _InfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
      child: Column(children: [
        _infoRow('AM routine', 'Cleanser → Toner → Vit C → SPF'),
        const Divider(color: Color(0xFF1E1E1E), height: 16),
        _infoRow('PM routine', 'Oil cleanse → Cleanser → Niacinamide → Moisturiser'),
        const Divider(color: Color(0xFF1E1E1E), height: 16),
        _infoRow('Avoid', 'Heavy oils, comedogenic ingredients'),
      ]),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 80, child: Text(label, style: const TextStyle(color: Color(0xFF555555), fontSize: 12))),
      Expanded(child: Text(value, style: const TextStyle(color: Color(0xFFD4B896), fontSize: 12, height: 1.4))),
    ]);
  }
}

class _ActionCard extends StatelessWidget {
  final String emoji, title, subtitle;
  final VoidCallback onTap;
  final bool gold;
  const _ActionCard({required this.emoji, required this.title, required this.subtitle, required this.onTap, this.gold = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: gold ? const Color(0xFF1C1507) : const Color(0xFF141414),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: gold ? const Color(0xFFC9A84C).withOpacity(0.4) : const Color(0xFF2A2A2A)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 10),
          Text(title, style: TextStyle(color: gold ? const Color(0xFFC9A84C) : const Color(0xFFF0EDE6), fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          Text(subtitle, style: const TextStyle(color: Color(0xFF555555), fontSize: 11)),
        ]),
      ),
    );
  }
}

class _RecsSheet extends StatefulWidget {
  final String category;
  const _RecsSheet({required this.category});
  @override
  State<_RecsSheet> createState() => _RecsSheetState();
}

class _RecsSheetState extends State<_RecsSheet> {
  bool _loading = true;
  String _content = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await GeminiService.getRecommendations(widget.category);
      setState(() { _content = r; _loading = false; });
    } catch (e) {
      setState(() { _content = 'Error loading recommendations. Check your API key.'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      builder: (_, ctrl) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 36, height: 3, decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text('${widget.category[0].toUpperCase()}${widget.category.substring(1)} picks for you', style: const TextStyle(color: Color(0xFFF0EDE6), fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('Personalised based on your profile', style: TextStyle(color: Color(0xFF555555), fontSize: 13)),
          const SizedBox(height: 16),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFC9A84C), strokeWidth: 2))
                : SingleChildScrollView(controller: ctrl, child: Text(_content, style: const TextStyle(color: Color(0xFFD4B896), fontSize: 14, height: 1.7))),
          ),
        ]),
      ),
    );
  }
}