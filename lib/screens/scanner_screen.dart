import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../services/gemini_service.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});
  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _recognizer = TextRecognizer();
  File? _image;
  bool _loading = false;
  String _result = '';
  String _status = '';

  @override
  void dispose() { _recognizer.close(); super.dispose(); }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 90);
    if (picked == null) return;
    setState(() { _image = File(picked.path); _result = ''; _status = ''; });
    await _runOCR(picked.path);
  }

  Future<void> _runOCR(String path) async {
    setState(() { _loading = true; _status = 'Reading ingredients from image...'; });
    try {
      final inputImage = InputImage.fromFilePath(path);
      final recognized = await _recognizer.processImage(inputImage);
      final text = recognized.text.trim();
      if (text.isEmpty) {
        setState(() { _loading = false; _status = ''; _result = 'No text detected. Try a clearer photo with good lighting directly facing the ingredient list.'; });
        return;
      }
      setState(() => _status = 'Analysing ingredients as your personalised skincare assistant...');
      await _analyzeWithAI(text);
    } catch (e) {
      setState(() { _loading = false; _status = ''; _result = 'Scan failed: $e\n\nTip: Make sure the ingredient list is in focus and well lit.'; });
    }
  }

  Future<void> _analyzeWithAI(String ingredientText) async {
    try {
      final result = await GeminiService.analyzeIngredients(ingredientText);
      setState(() { _result = result; _loading = false; _status = ''; });
    } catch (e) {
      setState(() {
        _result = 'Analysis failed: $e\n\nPlease add your API key in Profile > AI Settings.';
        _loading = false;
        _status = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('Ingredient scanner'),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 0.5, color: const Color(0xFF1A1A1A))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: _btn(Icons.camera_alt_rounded, 'Camera', () => _pickImage(ImageSource.camera))),
            const SizedBox(width: 12),
            Expanded(child: _btn(Icons.photo_library_rounded, 'Gallery', () => _pickImage(ImageSource.gallery))),
          ]),
          const SizedBox(height: 20),

          if (_image != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(children: [
                Image.file(_image!, width: double.infinity, height: 220, fit: BoxFit.cover),
                if (_loading) Container(
                  width: double.infinity, height: 220,
                  color: Colors.black.withOpacity(0.7),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const CircularProgressIndicator(color: Color(0xFFC9A84C), strokeWidth: 2),
                    const SizedBox(height: 14),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text(_status, style: const TextStyle(color: Colors.white, fontSize: 12), textAlign: TextAlign.center)),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 16),
          ],

          if (_image == null) ...[
            Container(
              width: double.infinity, height: 200,
              decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
              child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('📷', style: TextStyle(fontSize: 40)),
                SizedBox(height: 12),
                Text('Scan ingredient list', style: TextStyle(color: Color(0xFFF0EDE6), fontSize: 15, fontWeight: FontWeight.w600)),
                SizedBox(height: 6),
                Text('Point camera at product ingredients', style: TextStyle(color: Color(0xFF555555), fontSize: 13)),
              ]),
            ),
            const SizedBox(height: 20),
          ],

          if (_result.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(children: [
                  Text('🔬', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  Text('Ingredient analysis', style: TextStyle(color: Color(0xFFC9A84C), fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                ]),
                const Divider(color: Color(0xFF1E1E1E), height: 20),
                Text(_result, style: const TextStyle(color: Color(0xFFD4B896), fontSize: 13, height: 1.7)),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => setState(() { _image = null; _result = ''; }),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF2A2A2A))),
                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.refresh_rounded, color: Color(0xFF666666), size: 16),
                      SizedBox(width: 8),
                      Text('Scan another product', style: TextStyle(color: Color(0xFF888888), fontSize: 13)),
                    ]),
                  ),
                ),
              ]),
            ),
          ],

          const SizedBox(height: 24),
          const Text('TIPS', style: TextStyle(color: Color(0xFF444444), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF2A2A2A))),
            child: Column(children: [
              _tip('💡', 'Good lighting gives best OCR results'),
              _tip('📐', 'Hold phone flat and parallel to label'),
              _tip('🔍', 'Zoom in on the ingredients section only'),
              _tip('✍️', 'Or type the product name in Products tab'),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _btn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFC9A84C), Color(0xFFE8C97A)]), borderRadius: BorderRadius.circular(14)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: const Color(0xFF0A0A0A), size: 20),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Color(0xFF0A0A0A), fontSize: 14, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }

  Widget _tip(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(color: Color(0xFF666666), fontSize: 12, height: 1.4))),
      ]),
    );
  }
}
