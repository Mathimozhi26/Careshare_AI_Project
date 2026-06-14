import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';
import '../services/user_data_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool _isLogin = true;
  bool _obscure = true;
  bool _loading = false;
  String _errorMessage = '';

  Future<void> _submit() async {
    setState(() => _errorMessage = '');
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      if (_isLogin) {
        await _auth.signInWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        // Auto fetch profile from Firestore on login
        try {
          await UserDataService.fetchAndCacheProfile();
        } catch (e) {
          print('Fetch error: \$e');
        }
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
      } else {
        final cred = await _auth.createUserWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        );
        await cred.user?.updateDisplayName(_nameCtrl.text.trim());
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', _nameCtrl.text.trim());
        await prefs.setString('user_email', _emailCtrl.text.trim());
        await prefs.setBool('is_logged_in', true);
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()));
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _loading = false);
      String msg = 'Something went wrong. Please try again.';
      if (e.code == 'user-not-found') msg = 'No account found with this email address.';
      if (e.code == 'wrong-password') msg = 'Incorrect password. Please try again.';
      if (e.code == 'email-already-in-use') msg = 'An account already exists with this email.';
      if (e.code == 'weak-password') msg = 'Password must be at least 6 characters.';
      if (e.code == 'invalid-email') msg = 'Please enter a valid email address.';
      if (e.code == 'too-many-requests') msg = 'Too many failed attempts. Please try again later.';
      if (e.code == 'invalid-credential') msg = 'Invalid email or password. Please try again.';
      setState(() => _errorMessage = msg);
    } catch (e) {
      setState(() { _loading = false; _errorMessage = 'Error: $e'; });
    }
  }

  Future<void> _forgotPassword() async {
    if (_emailCtrl.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter your email address first.');
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email: _emailCtrl.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Password reset email sent! Check your inbox.'),
        backgroundColor: Color(0xFF0D2B1A),
      ));
    } catch (e) {
      setState(() => _errorMessage = 'Error: $e');
    }
  }

  @override
  void dispose() { _nameCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('login_screen'),
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF141414),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFC9A84C).withOpacity(0.3)),
                  ),
                  child: const Center(child: Text('✦', style: TextStyle(fontSize: 26, color: Color(0xFFC9A84C)))),
                ),
                const SizedBox(height: 28),
                Text(
                  _isLogin ? 'Welcome back' : 'Create account',
                  key: Key(_isLogin ? 'login_title' : 'signup_title'),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFFF0EDE6), letterSpacing: -0.5),
                ),
                const SizedBox(height: 6),
                Text(
                  _isLogin ? 'Sign in to CareShare AI' : 'Start your skincare journey',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF555555)),
                ),
                const SizedBox(height: 36),

                // Error message banner
                if (_errorMessage.isNotEmpty) ...[
                  Container(
                    key: const Key('error_banner'),
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B0A0A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF991B1B).withOpacity(0.5)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.error_outline_rounded, color: Color(0xFFF87171), size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_errorMessage, key: const Key('error_message'), style: const TextStyle(color: Color(0xFFF87171), fontSize: 13))),
                    ]),
                  ),
                  const SizedBox(height: 16),
                ],

                if (!_isLogin) ...[
                  TextFormField(
                    key: const Key('name_field'),
                    controller: _nameCtrl,
                    style: const TextStyle(color: Color(0xFFF0EDE6)),
                    decoration: const InputDecoration(labelText: 'Full name', prefixIcon: Icon(Icons.person_outline, color: Color(0xFF555555), size: 20)),
                    validator: (v) => v!.isEmpty ? 'Please enter your full name' : null,
                  ),
                  const SizedBox(height: 14),
                ],
                TextFormField(
                  key: const Key('email_field'),
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Color(0xFFF0EDE6)),
                  decoration: const InputDecoration(labelText: 'Email address', prefixIcon: Icon(Icons.mail_outline, color: Color(0xFF555555), size: 20)),
                  validator: (v) => !v!.contains('@') ? 'Please enter a valid email address' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  key: const Key('password_field'),
                  controller: _passCtrl,
                  obscureText: _obscure,
                  style: const TextStyle(color: Color(0xFFF0EDE6)),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF555555), size: 20),
                    suffixIcon: IconButton(
                      key: const Key('toggle_password'),
                      icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF555555), size: 20),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => v!.length < 6 ? 'Password must be at least 6 characters' : null,
                ),
                if (_isLogin) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      key: const Key('forgot_password'),
                      onTap: _forgotPassword,
                      child: const Text('Forgot password?', style: TextStyle(color: Color(0xFFC9A84C), fontSize: 13)),
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                _loading
                    ? const Center(child: CircularProgressIndicator(key: Key('loading_indicator'), color: Color(0xFFC9A84C), strokeWidth: 2))
                    : ElevatedButton(
                        key: Key(_isLogin ? 'login_button' : 'signup_button'),
                        onPressed: _submit,
                        child: Text(_isLogin ? 'Sign in' : 'Create account'),
                      ),
                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    key: const Key('toggle_auth_mode'),
                    onTap: () => setState(() { _isLogin = !_isLogin; _errorMessage = ''; }),
                    child: RichText(
                      text: TextSpan(
                        text: _isLogin ? "Don't have an account?  " : 'Already have an account?  ',
                        style: const TextStyle(color: Color(0xFF555555), fontSize: 14),
                        children: [TextSpan(
                          text: _isLogin ? 'Sign up' : 'Sign in',
                          style: const TextStyle(color: Color(0xFFC9A84C), fontWeight: FontWeight.w600),
                        )],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
