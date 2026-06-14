import 'package:flutter/material.dart';
import '../services/gemini_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final List<Map<String, String>> _msgs = [];
  bool _loading = false;

  final _suggestions = [
    'Is Minimalist Niacinamide good for me?',
    'Which sunscreen suits my skin type?',
    'Best serum for hair growth?',
    'Can I use Vit C with Retinol?',
    'What\'s a good routine for my skin?',
  ];

  Future<void> _send(String text) async {
    if (text.trim().isEmpty || _loading) return;
    _ctrl.clear();
    setState(() { _msgs.add({'role': 'user', 'content': text}); _loading = true; });
    _scrollBottom();
    try {
      final r = await GeminiService.chat(text, List.from(_msgs)..removeLast());
      setState(() { _msgs.add({'role': 'ai', 'content': r}); _loading = false; });
    } catch (e) {
      setState(() { _msgs.add({'role': 'ai', 'content': 'Something went wrong. Please check your API key in Profile settings and try again.'}); _loading = false; });
    }
    _scrollBottom();
  }

  void _clearChat() {
    setState(() => _msgs.clear());
  }

  void _scrollBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  @override
  void dispose() { _ctrl.dispose(); _scroll.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('chat_screen'),
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        title: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFC9A84C), Color(0xFFE8C97A)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(child: Text('✦', style: TextStyle(color: Color(0xFF0A0A0A), fontSize: 14))),
          ),
          const SizedBox(width: 10),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('CareShare AI', style: TextStyle(color: Color(0xFFF0EDE6), fontSize: 15, fontWeight: FontWeight.w600)),
            Text('Personalised skincare assistant', style: TextStyle(color: Color(0xFF555555), fontSize: 11)),
          ]),
        ]),
        actions: [
          IconButton(
            key: const Key('clear_chat_button'),
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF555555)),
            onPressed: _clearChat,
            tooltip: 'Clear chat',
          ),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 0.5, color: const Color(0xFF1A1A1A))),
      ),
      body: Column(children: [
        Expanded(
          child: _msgs.isEmpty ? _buildWelcome() : ListView.builder(
            key: const Key('chat_messages'),
            controller: _scroll,
            padding: const EdgeInsets.all(16),
            itemCount: _msgs.length + (_loading ? 1 : 0),
            itemBuilder: (_, i) {
              if (i == _msgs.length) return _buildTyping();
              final m = _msgs[i];
              return _buildBubble(m['content']!, m['role'] == 'user', i);
            },
          ),
        ),
        _buildInput(),
      ]),
    );
  }

  Widget _buildWelcome() {
    return SingleChildScrollView(
      key: const Key('chat_welcome'),
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        const SizedBox(height: 20),
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFC9A84C), Color(0xFFE8C97A)]),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Center(child: Text('✦', style: TextStyle(color: Color(0xFF0A0A0A), fontSize: 32))),
        ),
        const SizedBox(height: 16),
        const Text('Your personalised skincare assistant', style: TextStyle(color: Color(0xFFF0EDE6), fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        const Text('Ask me anything about your skin, hair, or any product.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF555555), fontSize: 13, height: 1.5)),
        const SizedBox(height: 28),
        const Align(alignment: Alignment.centerLeft, child: Text('SUGGESTED', style: TextStyle(color: Color(0xFF444444), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1))),
        const SizedBox(height: 12),
        ..._suggestions.asMap().entries.map((e) => GestureDetector(
          key: Key('suggestion_${e.key}'),
          onTap: () => _send(e.value),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2A2A2A))),
            child: Row(children: [
              Expanded(child: Text(e.value, style: const TextStyle(color: Color(0xFFD4B896), fontSize: 13))),
              const Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF444444)),
            ]),
          ),
        )),
      ]),
    );
  }

  Widget _buildBubble(String text, bool isUser, int index) {
    return Align(
      key: Key(isUser ? 'user_message_$index' : 'ai_message_$index'),
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF1C1507) : const Color(0xFF141414),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: Border.all(color: isUser ? const Color(0xFFC9A84C).withOpacity(0.3) : const Color(0xFF2A2A2A)),
        ),
        child: Text(text, style: TextStyle(color: isUser ? const Color(0xFFC9A84C) : const Color(0xFFD4B896), fontSize: 14, height: 1.5)),
      ),
    );
  }

  Widget _buildTyping() {
    return Align(
      key: const Key('typing_indicator'),
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _dot(0), const SizedBox(width: 4), _dot(200), const SizedBox(width: 4), _dot(400),
        ]),
      ),
    );
  }

  Widget _dot(int delayMs) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: Duration(milliseconds: 600 + delayMs),
      builder: (_, v, __) => Container(
        width: 6, height: 6,
        decoration: BoxDecoration(color: Color.lerp(const Color(0xFF333333), const Color(0xFFC9A84C), v), shape: BoxShape.circle),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      key: const Key('chat_input_area'),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      decoration: const BoxDecoration(color: Color(0xFF0E0E0E), border: Border(top: BorderSide(color: Color(0xFF1A1A1A)))),
      child: Row(children: [
        Expanded(
          child: TextField(
            key: const Key('chat_input_field'),
            controller: _ctrl,
            maxLines: null,
            textInputAction: TextInputAction.send,
            onSubmitted: _send,
            style: const TextStyle(color: Color(0xFFF0EDE6), fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Ask about any product or routine...',
              hintStyle: const TextStyle(color: Color(0xFF333333), fontSize: 14),
              filled: true,
              fillColor: const Color(0xFF141414),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: Color(0xFFC9A84C), width: 1)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          key: const Key('send_button'),
          onTap: () => _send(_ctrl.text),
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFC9A84C), Color(0xFFE8C97A)]),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(Icons.arrow_upward_rounded, color: Color(0xFF0A0A0A), size: 20),
          ),
        ),
      ]),
    );
  }
}
