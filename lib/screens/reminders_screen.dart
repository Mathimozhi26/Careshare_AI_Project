import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});
  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _Reminder {
  String label;
  String time;
  bool enabled;
  _Reminder(this.label, this.time, this.enabled);
  Map<String, dynamic> toJson() => {'label': label, 'time': time, 'enabled': enabled};
  static _Reminder fromJson(Map<String, dynamic> j) => _Reminder(j['label'], j['time'], j['enabled'] ?? true);
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<_Reminder> _reminders = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('reminders') ?? jsonEncode([
      {'label': 'Morning routine', 'time': '08:00 AM', 'enabled': true},
      {'label': 'Night routine', 'time': '10:00 PM', 'enabled': true},
      {'label': 'Drink water', 'time': 'Every 2 hours', 'enabled': false},
    ]);
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    setState(() => _reminders = list.map((e) => _Reminder.fromJson(e)).toList());
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('reminders', jsonEncode(_reminders.map((e) => e.toJson()).toList()));
  }

  void _toggle(int i, bool v) {
    setState(() => _reminders[i].enabled = v);
    _save();
  }

  Future<void> _addReminder() async {
    final labelCtrl = TextEditingController();
    TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked == null) return;
    if (!mounted) return;
    final label = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reminder name', style: TextStyle(color: Color(0xFFF0EDE6), fontSize: 15)),
        content: TextField(controller: labelCtrl, autofocus: true, maxLength: 60, style: const TextStyle(color: Color(0xFFF0EDE6)), decoration: const InputDecoration(hintText: 'e.g. Apply sunscreen')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, labelCtrl.text), child: const Text('Add', style: TextStyle(color: Color(0xFFC9A84C), fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (label == null || label.trim().isEmpty) return;
    setState(() => _reminders.add(_Reminder(label.trim(), picked!.format(context), true)));
    _save();
  }

  void _delete(int i) {
    setState(() => _reminders.removeAt(i));
    _save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('reminders_screen'),
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('Reminders'),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 0.5, color: const Color(0xFF1A1A1A))),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_reminder_button'),
        onPressed: _addReminder,
        backgroundColor: const Color(0xFFC9A84C),
        child: const Icon(Icons.add_alarm_rounded, color: Color(0xFF0A0A0A)),
      ),
      body: ListView.builder(
        key: const Key('reminders_list'),
        padding: const EdgeInsets.all(16),
        itemCount: _reminders.length,
        itemBuilder: (_, i) {
          final r = _reminders[i];
          return Container(
            key: Key('reminder_item_$i'),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF2A2A2A))),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.alarm_rounded, color: Color(0xFFC9A84C), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r.label, style: const TextStyle(color: Color(0xFFF0EDE6), fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(r.time, style: const TextStyle(color: Color(0xFF888888), fontSize: 12)),
              ])),
              Switch(key: Key('reminder_switch_$i'), value: r.enabled, onChanged: (v) => _toggle(i, v), activeColor: const Color(0xFFC9A84C)),
              IconButton(key: Key('delete_reminder_$i'), icon: const Icon(Icons.close_rounded, color: Color(0xFF555555), size: 18), onPressed: () => _delete(i)),
            ]),
          );
        },
      ),
    );
  }
}
