import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({super.key});
  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineStep {
  String name;
  bool done;
  _RoutineStep(this.name, this.done);
  Map<String, dynamic> toJson() => {'name': name, 'done': done};
  static _RoutineStep fromJson(Map<String, dynamic> j) => _RoutineStep(j['name'], j['done'] ?? false);
}

class _RoutineScreenState extends State<RoutineScreen> {
  List<_RoutineStep> _morning = [];
  List<_RoutineStep> _night = [];
  int _tab = 0;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final m = jsonDecode(p.getString('routine_morning') ?? jsonEncode([
      {'name': 'Cleanser', 'done': false},
      {'name': 'Toner', 'done': false},
      {'name': 'Moisturiser', 'done': false},
      {'name': 'Sunscreen (SPF 30+)', 'done': false},
    ])) as List;
    final n = jsonDecode(p.getString('routine_night') ?? jsonEncode([
      {'name': 'Cleanser', 'done': false},
      {'name': 'Serum', 'done': false},
      {'name': 'Moisturiser', 'done': false},
    ])) as List;
    setState(() {
      _morning = m.map((e) => _RoutineStep.fromJson(e)).toList();
      _night = n.map((e) => _RoutineStep.fromJson(e)).toList();
    });
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('routine_morning', jsonEncode(_morning.map((e) => e.toJson()).toList()));
    await p.setString('routine_night', jsonEncode(_night.map((e) => e.toJson()).toList()));
  }

  void _toggle(List<_RoutineStep> list, int i) {
    setState(() => list[i].done = !list[i].done);
    _save();
  }

  void _addStep(List<_RoutineStep> list) {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF141414),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Add step', style: TextStyle(color: Color(0xFFF0EDE6))),
      content: TextField(controller: ctrl, autofocus: true, maxLength: 60, style: const TextStyle(color: Color(0xFFF0EDE6)), decoration: const InputDecoration(hintText: 'e.g. Face mist')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Color(0xFF555555)))),
        TextButton(onPressed: () {
          if (ctrl.text.trim().isNotEmpty) {
            setState(() => list.add(_RoutineStep(ctrl.text.trim(), false)));
            _save();
          }
          Navigator.pop(ctx);
        }, child: const Text('Add', style: TextStyle(color: Color(0xFFC9A84C), fontWeight: FontWeight.w700))),
      ],
    ));
  }

  void _editStep(List<_RoutineStep> list, int i) {
    final ctrl = TextEditingController(text: list[i].name);
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF141414),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Edit step', style: TextStyle(color: Color(0xFFF0EDE6))),
      content: TextField(controller: ctrl, autofocus: true, maxLength: 60, style: const TextStyle(color: Color(0xFFF0EDE6)), decoration: const InputDecoration(hintText: 'Step name')),
      actions: [
        TextButton(
          onPressed: () {
            setState(() => list.removeAt(i));
            _save();
            Navigator.pop(ctx);
          },
          child: const Text('Delete', style: TextStyle(color: Color(0xFFF87171))),
        ),
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Color(0xFF555555)))),
        TextButton(onPressed: () {
          if (ctrl.text.trim().isNotEmpty) {
            setState(() => list[i].name = ctrl.text.trim());
            _save();
          }
          Navigator.pop(ctx);
        }, child: const Text('Save', style: TextStyle(color: Color(0xFFC9A84C), fontWeight: FontWeight.w700))),
      ],
    ));
  }

  void _reorder(List<_RoutineStep> list, int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = list.removeAt(oldIndex);
      list.insert(newIndex, item);
    });
    _save();
  }

  @override
  Widget build(BuildContext context) {
    final list = _tab == 0 ? _morning : _night;
    final completed = list.where((s) => s.done).length;
    return Scaffold(
      key: const Key('routine_screen'),
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('My routine'),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 0.5, color: const Color(0xFF1A1A1A))),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: _tabBtn('☀️ Morning', 0)),
            const SizedBox(width: 10),
            Expanded(child: _tabBtn('🌙 Night', 1)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            Text('$completed/${list.length} done', style: const TextStyle(color: Color(0xFF888888), fontSize: 13)),
            const Spacer(),
            const Text('Tap to check • Hold to edit', style: TextStyle(color: Color(0xFF444444), fontSize: 11)),
            const SizedBox(width: 12),
            GestureDetector(key: const Key('add_step_button'), onTap: () => _addStep(list), child: const Row(children: [Icon(Icons.add_rounded, color: Color(0xFFC9A84C), size: 16), SizedBox(width: 4), Text('Add', style: TextStyle(color: Color(0xFFC9A84C), fontSize: 13))])),
          ]),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ReorderableListView.builder(
            key: const Key('routine_list'),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: list.length,
            onReorder: (oldI, newI) => _reorder(list, oldI, newI),
            itemBuilder: (_, i) => Container(
              key: Key('routine_step_$i'),
              margin: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => _toggle(list, i),
                  onLongPress: () => _editStep(list, i),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: list[i].done ? const Color(0xFF0D2B1A) : const Color(0xFF141414),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: list[i].done ? const Color(0xFF166534) : const Color(0xFF2A2A2A)),
                    ),
                    child: Row(children: [
                      Icon(list[i].done ? Icons.check_circle_rounded : Icons.circle_outlined, color: list[i].done ? const Color(0xFF4ADE80) : const Color(0xFF555555), size: 22),
                      const SizedBox(width: 12),
                      Expanded(child: Text(list[i].name, style: TextStyle(color: list[i].done ? const Color(0xFF4ADE80) : const Color(0xFFD4B896), fontSize: 14, decoration: list[i].done ? TextDecoration.lineThrough : null))),
                      Icon(Icons.drag_handle_rounded, color: const Color(0xFF333333), size: 18),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _tabBtn(String label, int idx) {
    final active = _tab == idx;
    return GestureDetector(
      key: Key('routine_tab_$idx'),
      onTap: () => setState(() => _tab = idx),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF1C1507) : const Color(0xFF141414),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? const Color(0xFFC9A84C) : const Color(0xFF2A2A2A)),
        ),
        child: Center(child: Text(label, style: TextStyle(color: active ? const Color(0xFFC9A84C) : const Color(0xFF666666), fontSize: 13, fontWeight: FontWeight.w600))),
      ),
    );
  }
}
