import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _reminders = true;
  String _units = 'INR';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _notifications = p.getBool('settings_notifications') ?? true;
      _reminders = p.getBool('settings_reminders') ?? true;
      _units = p.getString('settings_units') ?? 'INR';
    });
  }

  Future<void> _saveBool(String key, bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(key, value);
  }

  Future<void> _saveString(String key, String value) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(key, value);
  }

  void _pickOption(String title, List<String> options, String current, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Color(0xFFF0EDE6), fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          ...options.map((opt) => ListTile(
            title: Text(opt, style: TextStyle(color: opt == current ? const Color(0xFFC9A84C) : const Color(0xFFD4B896))),
            trailing: opt == current ? const Icon(Icons.check_rounded, color: Color(0xFFC9A84C)) : null,
            onTap: () { onSelect(opt); Navigator.pop(ctx); },
          )),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('settings_screen'),
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('Settings'),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 0.5, color: const Color(0xFF1A1A1A))),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('PREFERENCES', style: TextStyle(color: Color(0xFF444444), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF2A2A2A))),
            child: Column(children: [
              _switchRow('notifications_switch', Icons.notifications_outlined, 'Notifications', _notifications, (v) { setState(() => _notifications = v); _saveBool('settings_notifications', v); }),
              const Divider(color: Color(0xFF1E1E1E), height: 1, indent: 48),
              _switchRow('reminders_switch', Icons.alarm_outlined, 'Routine reminders', _reminders, (v) { setState(() => _reminders = v); _saveBool('settings_reminders', v); }),
            ]),
          ),
          const SizedBox(height: 20),
          const Text('GENERAL', style: TextStyle(color: Color(0xFF444444), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF2A2A2A))),
            child: Column(children: [
              _navRow('currency_setting', Icons.currency_rupee_rounded, 'Currency', _units, () => _pickOption('Currency', ['INR', 'USD'], _units, (v) { setState(() => _units = v); _saveString('settings_units', v); })),
            ]),
          ),
          const SizedBox(height: 20),
          const Text('ABOUT', style: TextStyle(color: Color(0xFF444444), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF2A2A2A))),
            child: Column(children: [
              _infoRow(Icons.info_outline_rounded, 'Version', '2.0.0'),
              const Divider(color: Color(0xFF1E1E1E), height: 1, indent: 48),
              _infoRow(Icons.shield_outlined, 'Privacy', 'Data stored securely on device & cloud'),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _switchRow(String key, IconData icon, String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(children: [
        Icon(icon, color: const Color(0xFF555555), size: 18),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: const TextStyle(color: Color(0xFFD4B896), fontSize: 14))),
        Switch(key: Key(key), value: value, onChanged: onChanged, activeColor: const Color(0xFFC9A84C)),
      ]),
    );
  }

  Widget _navRow(String key, IconData icon, String label, String value, VoidCallback onTap) {
    return GestureDetector(
      key: Key(key),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Icon(icon, color: const Color(0xFF555555), size: 18),
          const SizedBox(width: 14),
          Text(label, style: const TextStyle(color: Color(0xFFD4B896), fontSize: 14)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Color(0xFF888888), fontSize: 13)),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF444444), size: 18),
        ]),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Icon(icon, color: const Color(0xFF555555), size: 18),
        const SizedBox(width: 14),
        Text(label, style: const TextStyle(color: Color(0xFFD4B896), fontSize: 14)),
        const Spacer(),
        Flexible(child: Text(value, style: const TextStyle(color: Color(0xFF888888), fontSize: 12), textAlign: TextAlign.right)),
      ]),
    );
  }
}
