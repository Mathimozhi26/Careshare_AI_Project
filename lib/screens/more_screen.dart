import 'package:flutter/material.dart';
import 'favourites_screen.dart';
import 'history_screen.dart';
import 'routine_screen.dart';
import 'settings_screen.dart';
import 'tips_feed_screen.dart';
import 'compare_screen.dart';
import 'progress_tracker_screen.dart';
import 'reminders_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _MenuItem('routine_menu_item', '🧴', 'My routine', 'Morning & night steps', const RoutineScreen()),
      _MenuItem('reminders_menu_item', '⏰', 'Reminders', 'Routine alerts', const RemindersScreen()),
      _MenuItem('favourites_menu_item', '🤍', 'Favourites', 'Saved products', const FavouritesScreen()),
      _MenuItem('history_menu_item', '🕓', 'History', 'Past checks & scans', const HistoryScreen()),
      _MenuItem('compare_menu_item', '⚖️', 'Compare', 'Side-by-side products', const CompareScreen()),
      _MenuItem('progress_menu_item', '📸', 'Skin progress', 'Photo journal', const ProgressTrackerScreen()),
      _MenuItem('tips_menu_item', '💡', 'Daily tips', 'Skincare & haircare advice', const TipsFeedScreen()),
      _MenuItem('settings_menu_item', '⚙️', 'Settings', 'App preferences', const SettingsScreen()),
    ];

    return Scaffold(
      key: const Key('more_screen'),
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('More'),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 0.5, color: const Color(0xFF1A1A1A))),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final item = items[i];
          return GestureDetector(
            key: Key(item.key),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => item.screen)),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF2A2A2A))),
              child: Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2A2A2A))),
                  child: Center(child: Text(item.emoji, style: const TextStyle(fontSize: 20))),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.title, style: const TextStyle(color: Color(0xFFF0EDE6), fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(item.subtitle, style: const TextStyle(color: Color(0xFF666666), fontSize: 12)),
                ])),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFF444444), size: 20),
              ]),
            ),
          );
        },
      ),
    );
  }
}

class _MenuItem {
  final String key, emoji, title, subtitle;
  final Widget screen;
  _MenuItem(this.key, this.emoji, this.title, this.subtitle, this.screen);
}
