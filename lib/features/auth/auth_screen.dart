import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _loading = true; _error = null; });

    try {
      final auth = AuthService.instance;
      bool success;

      if (_isLogin) {
        success = await auth.signInWithEmail(_email.text.trim(), _password.text);
      } else {
        success = await auth.signUp(_name.text.trim(), _email.text.trim(), _password.text);
      }

      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  Future<void> _guest() async {
    setState(() { _loading = true; _error = null; });

    try {
      await AuthService.instance.signInAsGuest();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      setState(() { _error = 'Failed to continue as guest'; });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  Future<void> _googleSignIn() async {
    setState(() { _loading = true; _error = null; });

    try {
      // Try Google Sign-In
      // For now, fallback to guest
      await AuthService.instance.signInAsGuest();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      setState(() { _error = 'Google Sign-In not available. Try Guest mode.'; });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0E21), Color(0xFF1A1E36)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 40),
                Center(
                  child: Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(20)),
                    child: const Center(child: Text('🌐', style: TextStyle(fontSize: 40))),
                  ),
                ).animate().scale(begin: const Offset(0.5, 0.5)),
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    _isLogin ? 'Welcome Back!' : 'Create Account',
                    style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    _isLogin ? 'Sign in to continue learning' : 'Start your language journey',
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
                  ),
                ).animate().fadeIn(delay: 200.ms),

                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!, style: GoogleFonts.poppins(fontSize: 14, color: AppColors.error))),
                    ]),
                  ),
                ],

                const SizedBox(height: 40),
                if (!_isLogin) ...[
                  _field(_name, 'Full Name', Icons.person_outline, validator: (v) {
                    if (v == null || v.isEmpty) return 'Name is required';
                    return null;
                  }),
                  const SizedBox(height: 16),
                ],
                _field(_email, 'Email', Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: (v) {
                  if (v == null || v.isEmpty) return 'Email is required';
                  if (!v.contains('@')) return 'Enter a valid email';
                  return null;
                }),
                const SizedBox(height: 16),
                _field(_password, 'Password', Icons.lock_outline, obscure: true, validator: (v) {
                  if (v == null || v.isEmpty) return 'Password is required';
                  if (v.length < 6) return 'Password must be at least 6 characters';
                  return null;
                }),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity, height: 56,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _loading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(_isLogin ? 'Sign In' : 'Create Account', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 24),
                Center(child: Text('OR', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white54))),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity, height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _googleSignIn,
                    icon: const Icon(Icons.g_mobiledata, size: 28),
                    label: Text('Continue with Google', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1E36),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      side: BorderSide(color: Colors.white24),
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms),

                const SizedBox(height: 16),

                // GUEST BUTTON - PROMINENT
                SizedBox(
                  width: double.infinity, height: 56,
                  child: OutlinedButton.icon(
                    onPressed: _loading ? null : _guest,
                    icon: const Icon(Icons.person_outline, size: 24),
                    label: Text('Continue as Guest', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ).animate().fadeIn(delay: 550.ms),

                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Guest users can access all German lessons',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.white54),
                  ),
                ),

                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    onTap: () => setState(() { _isLogin = !_isLogin; _error = null; }),
                    child: RichText(
                      text: TextSpan(
                        text: _isLogin ? "Don't have an account? " : 'Already have an account? ',
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
                        children: [
                          TextSpan(
                            text: _isLogin ? 'Sign Up' : 'Sign In',
                            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label,
    IconData icon, {
    bool obscure = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1E36),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: TextFormField(
        controller: c,
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: validator,
        style: GoogleFonts.poppins(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.white54),
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          filled: true,
          fillColor: const Color(0xFF1A1E36),
          errorStyle: GoogleFonts.poppins(fontSize: 12),
        ),
      ),
    );
  }
}
