import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import '../onboarding/onboarding_screen.dart';
import '../dashboard/main_navigation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        // ── Login ──────────────────────────────────────────────
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainNavigation()),
          );
        }
      } else {
        // ── Sign Up ────────────────────────────────────────────
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      if (e.code == 'email-already-in-use') {
        // Check what providers are linked to this email
        await _handleEmailAlreadyInUse(email, password);
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        // Maybe the account exists only via Google — check and inform
        await _handleWrongPassword(email, password);
      } else {
        _showSnack(e.message ?? 'An error occurred.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Called when sign-up fails with email-already-in-use.
  /// Offers to sign in with Google and link the password.
  Future<void> _handleEmailAlreadyInUse(
      String email, String password) async {
    if (!mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Account Exists',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'This email is already registered (possibly via Google).\n\n'
          'Sign in with Google and we\'ll link your password so you can use both.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white38))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sign in with Google',
                  style: TextStyle(color: Color(0xFFE5FF00)))),
        ],
      ),
    );
    if (confirm == true) await _signInWithGoogleAndLink(password);
  }

  /// Called when login fails with wrong-password / invalid-credential.
  /// Suggests Google sign-in and offers to link password.
  Future<void> _handleWrongPassword(String email, String password) async {
    if (!mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Wrong Password',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Password is incorrect.\n\n'
          'If you signed up with Google, tap below to sign in with Google '
          'and also link this password to your account.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Try Again',
                  style: TextStyle(color: Colors.white38))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Use Google & Link',
                  style: TextStyle(color: Color(0xFFE5FF00)))),
        ],
      ),
    );
    if (confirm == true) await _signInWithGoogleAndLink(password);
  }

  /// Signs in via Google (popup on web, package on mobile)
  /// then links an email/password credential to the same account.
  Future<void> _signInWithGoogleAndLink(String password) async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        userCredential = await FirebaseAuth.instance
            .signInWithPopup(GoogleAuthProvider());
      } else {
        final gUser = await GoogleSignIn().signIn();
        if (gUser == null) return;
        final gAuth = await gUser.authentication;
        userCredential = await FirebaseAuth.instance.signInWithCredential(
          GoogleAuthProvider.credential(
            accessToken: gAuth.accessToken,
            idToken: gAuth.idToken,
          ),
        );
      }

      // Now link the email/password credential
      final emailCred = EmailAuthProvider.credential(
        email: userCredential.user!.email!,
        password: password,
      );
      await userCredential.user!.linkWithCredential(emailCred);

      if (mounted) {
        _showSnack('Password linked! You can now use both login methods.',
            isError: false);
        final isNew = userCredential.additionalUserInfo?.isNewUser ?? false;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) =>
                isNew ? const OnboardingScreen() : const MainNavigation(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      // credential-already-in-use means a password is already linked
      if (e.code == 'credential-already-in-use' ||
          e.code == 'provider-already-linked') {
        _showSnack(
            'A password is already linked. Try logging in with your email & password.');
      } else {
        _showSnack(e.message ?? 'Linking failed.');
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        userCredential =
            await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          setState(() => _isLoading = false);
          return;
        }
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        userCredential = await FirebaseAuth.instance.signInWithCredential(
          GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          ),
        );
      }

      if (mounted) {
        if (userCredential.additionalUserInfo?.isNewUser ?? false) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainNavigation()),
          );
        }
      }
    } catch (e) {
      if (mounted) _showSnack('Google Sign-In failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor:
          isError ? Colors.redAccent : Colors.green.shade700,
      duration: const Duration(seconds: 4),
    ));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'GAINIQ',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  letterSpacing: 2,
                  color: Theme.of(context).primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Text(
                _isLogin ? 'Welcome Back' : 'Create Account',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.black)
                    : Text(_isLogin ? 'LOGIN' : 'SIGN UP'),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _signInWithGoogle,
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/google_logo.png',
                    height: 20,
                    width: 20,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, color: Colors.black),
                  ),
                ),
                label: const Text(
                  'Continue with Google',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(
                  _isLogin ? 'Don\'t have an account? Sign up' : 'Already have an account? Login',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
