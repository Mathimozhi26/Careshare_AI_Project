import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProgressTrackerScreen extends StatefulWidget {
  const ProgressTrackerScreen({super.key});
  @override
  State<ProgressTrackerScreen> createState() => _ProgressTrackerScreenState();
}

class _ProgressTrackerScreenState extends State<ProgressTrackerScreen> {
  final ImagePicker _picker = ImagePicker();
  List<Map<String, String>> _entries = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('progress_entries') ?? '[]';
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    setState(() => _entries = list.map((e) => e.map((k, v) => MapEntry(k, v.toString()))).toList().reversed.toList());
  }

  Future<void> _addPhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (picked == null) return;
    final note = await _askNote();
    final entry = {
      'path': picked.path,
      'date': DateTime.now().toString().substring(0, 16),
      'note': note ?? '',
    };
    setState(() => _entries.insert(0, entry));
    final p = await SharedPreferences.getInstance();
    final all = _entries.reversed.toList();
    await p.setString('progress_entries', jsonEncode(all));
  }

  Future<String?> _askNote() async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add a note (optional)', style: TextStyle(color: Color(0xFFF0EDE6), fontSize: 15)),
        content: TextField(controller: ctrl, style: const TextStyle(color: Color(0xFFF0EDE6)), decoration: const InputDecoration(hintText: 'How does your skin feel today?')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: const Text('Save', style: TextStyle(color: Color(0xFFC9A84C), fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('progress_tracker_screen'),
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('Skin progress'),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 0.5, color: const Color(0xFF1A1A1A))),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_progress_photo_button'),
        onPressed: _addPhoto,
        backgroundColor: const Color(0xFFC9A84C),
        child: const Icon(Icons.add_a_photo_rounded, color: Color(0xFF0A0A0A)),
      ),
      body: _entries.isEmpty
          ? Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('📸', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                const Text('Start your skin journal', style: TextStyle(color: Color(0xFFF0EDE6), fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                const Text('Tap the camera button to add\nyour first progress photo', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF555555), fontSize: 13)),
              ]),
            )
          : GridView.builder(
              key: const Key('progress_grid'),
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.8),
              itemCount: _entries.length,
              itemBuilder: (_, i) {
                final e = _entries[i];
                return Container(
                  key: Key('progress_entry_$i'),
                  decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF2A2A2A))),
                  clipBehavior: Clip.antiAlias,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: Image.file(File(e['path']!), width: double.infinity, fit: BoxFit.cover)),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(e['date'] ?? '', style: const TextStyle(color: Color(0xFF888888), fontSize: 10)),
                        if ((e['note'] ?? '').isNotEmpty) Text(e['note']!, style: const TextStyle(color: Color(0xFFD4B896), fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ]),
                    ),
                  ]),
                );
              },
            ),
    );
  }
}
