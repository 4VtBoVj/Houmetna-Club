import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onSignedUp;
  const SignupScreen({super.key, required this.onBack, required this.onSignedUp});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _auth = AuthService();
  bool obscure = true;
  bool obscure2 = true;

  Future<void> _handleSignup() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;
    if (email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      _snack('Please fill all fields');
      return;
    }
    if (pass != confirm) {
      _snack('Passwords do not match');
      return;
    }
    try {
      await _auth.signUp(email, pass);
      widget.onSignedUp();
    } catch (e) {
      _snack('Sign up failed: $e');
    }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack), title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Text('Join HOUMETNA', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 24),
            _label('Email'),
            const SizedBox(height: 8),
            _input(hint: 'Enter your email', icon: Icons.mail, controller: _emailCtrl),
            const SizedBox(height: 16),
            _label('Password'),
            const SizedBox(height: 8),
            _input(hint: 'Enter your password', icon: Icons.lock, controller: _passCtrl, obscure: obscure, trailing: IconButton(icon: Icon(obscure ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => obscure = !obscure))),
            const SizedBox(height: 16),
            _label('Confirm Password'),
            const SizedBox(height: 8),
            _input(hint: 'Confirm your password', icon: Icons.lock, controller: _confirmCtrl, obscure: obscure2, trailing: IconButton(icon: Icon(obscure2 ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => obscure2 = !obscure2))),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _handleSignup, child: const Text('Sign Up')),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600));

  Widget _input({required String hint, required IconData icon, bool obscure = false, Widget? trailing, TextEditingController? controller}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        suffixIcon: trailing,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}
