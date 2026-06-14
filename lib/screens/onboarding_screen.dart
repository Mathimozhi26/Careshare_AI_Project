import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import '../services/user_data_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pc = PageController();
  int _page = 0;
  String _gender = '', _skinType = '', _hairType = '', _cycle = '';
  final _allergyCtrl = TextEditingController();
  final _condCtrl = TextEditingController();

  final _skinTypes = ['Oily', 'Dry', 'Combination', 'Sensitive', 'Normal'];
  final _hairTypes = ['Straight', 'Wavy', 'Curly', 'Coily', 'Fine', 'Thick'];
  final _cycles = ['Menstrual (Day 1–5)', 'Follicular (Day 6–13)', 'Ovulation (Day 14)', 'Luteal (Day 15–28)', 'Irregular', 'Prefer not to say'];

  int get _totalPages => _gender == 'Female' ? 5 : 4;

  void _next() {
    if (_page < _totalPages - 1) {
      _pc.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
      setState(() => _page++);
    } else {
      _save();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    await prefs.setString('skin_type', _skinType);
    await prefs.setString('hair_type', _hairType);
    await prefs.setString('gender', _gender);
    await prefs.setString('allergies', _allergyCtrl.text);
    await prefs.setString('conditions', _condCtrl.text);
    await prefs.setString('cycle_info', _cycle);

    // Auto save to Firestore
    try {
      await UserDataService.saveProfile({
        'skin_type': _skinType,
        'hair_type': _hairType,
        'gender': _gender,
        'allergies': _allergyCtrl.text,
        'conditions': _condCtrl.text,
        'cycle_info': _cycle,
        'user_name': prefs.getString('user_name') ?? '',
        'user_email': prefs.getString('user_email') ?? '',
      });
    } catch (e) {
      print('Firestore save error: \$e');
    }

    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
  }

  Widget _optionChip(String label, String selected, Function(String) onTap) {
    final sel = selected == label;
    return GestureDetector(
      onTap: () => onTap(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFF1C1507) : const Color(0xFF141414),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: sel ? const Color(0xFFC9A84C) : const Color(0xFF2A2A2A), width: sel ? 1.5 : 1),
        ),
        child: Text(label, style: TextStyle(color: sel ? const Color(0xFFC9A84C) : const Color(0xFF888888), fontSize: 14, fontWeight: sel ? FontWeight.w600 : FontWeight.normal)),
      ),
    );
  }

  Widget _page0() => _buildPage(
    page: 0,
    icon: '👤',
    title: 'Tell us about you',
    subtitle: 'Personalise your experience',
    child: Wrap(children: ['Male', 'Female', 'Other'].map((g) => _optionChip(g, _gender, (v) => setState(() => _gender = v))).toList()),
  );

  Widget _page1() => _buildPage(
    page: 1,
    icon: '✨',
    title: 'Your skin type',
    subtitle: 'We\'ll recommend products that work for you',
    child: Wrap(children: _skinTypes.map((s) => _optionChip(s, _skinType, (v) => setState(() => _skinType = v))).toList()),
  );

  Widget _page2() => _buildPage(
    page: 2,
    icon: '💇',
    title: 'Your hair type',
    subtitle: 'For tailored haircare recommendations',
    child: Wrap(children: _hairTypes.map((h) => _optionChip(h, _hairType, (v) => setState(() => _hairType = v))).toList()),
  );

  Widget _page3() => _buildPage(
    page: 3,
    icon: '🏥',
    title: 'Health details',
    subtitle: 'Helps us flag unsafe ingredients for you',
    canSkip: true,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Ingredient allergies', style: TextStyle(color: Color(0xFF888888), fontSize: 13, fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      TextField(controller: _allergyCtrl, style: const TextStyle(color: Color(0xFFF0EDE6)), maxLines: 2, decoration: const InputDecoration(hintText: 'e.g. parabens, sulphates, fragrance')),
      const SizedBox(height: 16),
      const Text('Medical conditions', style: TextStyle(color: Color(0xFF888888), fontSize: 13, fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      TextField(controller: _condCtrl, style: const TextStyle(color: Color(0xFFF0EDE6)), maxLines: 2, decoration: const InputDecoration(hintText: 'e.g. diabetes, thyroid, PCOS, acne')),
    ]),
  );

  Widget _page4() => _buildPage(
    page: 4,
    icon: '🌙',
    title: 'Menstrual cycle',
    subtitle: 'Hormones affect your skin — helps us personalise',
    canSkip: true,
    child: Wrap(children: _cycles.map((c) => _optionChip(c, _cycle, (v) => setState(() => _cycle = v))).toList()),
  );

  Widget _buildPage({required int page, required String icon, required String title, required String subtitle, required Widget child, bool canSkip = false}) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 8),
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(color: const Color(0xFF1C1507), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFC9A84C).withOpacity(0.3))),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
        ),
        const SizedBox(height: 20),
        Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFFF0EDE6), letterSpacing: -0.5)),
        const SizedBox(height: 6),
        Text(subtitle, style: const TextStyle(fontSize: 14, color: Color(0xFF555555))),
        const SizedBox(height: 28),
        Expanded(child: SingleChildScrollView(child: child)),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: _next, child: Text(_page == _totalPages - 1 ? 'Get started' : 'Continue')),
        if (canSkip) ...[
          const SizedBox(height: 12),
          Center(child: GestureDetector(onTap: _save, child: const Text('Skip for now', style: TextStyle(color: Color(0xFF444444), fontSize: 14)))),
        ],
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
            child: Column(children: [
              Row(children: List.generate(_totalPages, (i) => Expanded(child: Container(
                margin: EdgeInsets.only(right: i < _totalPages - 1 ? 4 : 0),
                height: 2,
                decoration: BoxDecoration(
                  color: i <= _page ? const Color(0xFFC9A84C) : const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(1),
                ),
              )))),
              const SizedBox(height: 8),
              Align(alignment: Alignment.centerRight, child: Text('${_page + 1} / $_totalPages', style: const TextStyle(color: Color(0xFF444444), fontSize: 12))),
            ]),
          ),
          Expanded(
            child: PageView(
              controller: _pc,
              physics: const NeverScrollableScrollPhysics(),
              children: [_page0(), _page1(), _page2(), _page3(), if (_gender == 'Female') _page4()],
            ),
          ),
        ]),
      ),
    );
  }
}