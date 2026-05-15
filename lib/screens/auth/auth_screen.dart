import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import '../onboarding/onboarding_screen.dart';
import '../dashboard/main_navigation.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum AuthView { phone, otp, email }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Global State
  AuthView _currentView = AuthView.phone;
  bool _isLoading = false;

  // Phone Auth State
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  String _verificationId = '';
  ConfirmationResult? _webConfirmationResult;

  // Email Auth State
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnack(String msg, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: isError ? Colors.redAccent : Colors.green.shade700,
      duration: const Duration(seconds: 4),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _navigateNext(UserCredential? cred) {
    if (!mounted) return;
    final isNew = cred?.additionalUserInfo?.isNewUser ?? false;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => isNew ? const OnboardingScreen() : const MainNavigation()),
    );
  }

  // ── PHONE AUTH ──────────────────────────────────────────

  Future<void> _sendOtp() async {
    final rawPhone = _phoneController.text.trim();
    if (rawPhone.length < 10) {
      _showSnack('Please enter a valid mobile number');
      return;
    }
    final phone = '+91$rawPhone';

    setState(() => _isLoading = true);
    try {
      if (kIsWeb) {
        _webConfirmationResult = await FirebaseAuth.instance.signInWithPhoneNumber(phone);
        setState(() {
          _currentView = AuthView.otp;
          _isLoading = false;
        });
      } else {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phone,
          verificationCompleted: (PhoneAuthCredential credential) async {
            final userCred = await FirebaseAuth.instance.signInWithCredential(credential);
            _navigateNext(userCred);
          },
          verificationFailed: (FirebaseAuthException e) {
            _showSnack(e.message ?? 'Verification failed');
            setState(() => _isLoading = false);
          },
          codeSent: (String verificationId, int? resendToken) {
            _verificationId = verificationId;
            setState(() {
              _currentView = AuthView.otp;
              _isLoading = false;
            });
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            _verificationId = verificationId;
          },
        );
      }
    } catch (e) {
      _showSnack(e.toString());
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      _showSnack('Please enter the 6-digit OTP');
      return;
    }

    setState(() => _isLoading = true);
    try {
      UserCredential userCred;
      if (kIsWeb) {
        userCred = await _webConfirmationResult!.confirm(code);
      } else {
        final credential = PhoneAuthProvider.credential(
          verificationId: _verificationId,
          smsCode: code,
        );
        userCred = await FirebaseAuth.instance.signInWithCredential(credential);
      }
      _navigateNext(userCred);
    } catch (e) {
      _showSnack('Invalid OTP. Please try again.');
    }
    setState(() => _isLoading = false);
  }

  // ── EMAIL AUTH ──────────────────────────────────────────

  Future<void> _submitEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      UserCredential userCred;
      if (_isLogin) {
        userCred = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      } else {
        userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      }
      _navigateNext(userCred);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      if (e.code == 'email-already-in-use') {
        await _handleEmailAlreadyInUse(email, password);
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        await _handleWrongPassword(email, password);
      } else {
        _showSnack(e.message ?? 'An error occurred.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── GOOGLE AUTH ──────────────────────────────────────────

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      UserCredential userCredential;
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        userCredential = await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          setState(() => _isLoading = false);
          return;
        }
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        userCredential = await FirebaseAuth.instance.signInWithCredential(
          GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          ),
        );
      }
      _navigateNext(userCredential);
    } catch (e) {
      if (mounted) _showSnack('Google Sign-In failed: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleEmailAlreadyInUse(String email, String password) async {
    if (!mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Account Exists', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
        content: Text(
          'This email is already registered (possibly via Google).\n\nSign in with Google and we\'ll link your password so you can use both.',
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sign in with Google', style: TextStyle(color: Color(0xFFE5FF00)))),
        ],
      ),
    );
    if (confirm == true) await _signInWithGoogleAndLink(password);
  }

  Future<void> _handleWrongPassword(String email, String password) async {
    if (!mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Wrong Password', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
        content: Text(
          'Password is incorrect.\n\nIf you signed up with Google, tap below to sign in with Google and also link this password to your account.',
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Try Again')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Use Google & Link', style: TextStyle(color: Color(0xFFE5FF00)))),
        ],
      ),
    );
    if (confirm == true) await _signInWithGoogleAndLink(password);
  }

  Future<void> _signInWithGoogleAndLink(String password) async {
    setState(() => _isLoading = true);
    try {
      UserCredential userCredential;
      if (kIsWeb) {
        userCredential = await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
      } else {
        final gUser = await GoogleSignIn().signIn();
        if (gUser == null) return;
        final gAuth = await gUser.authentication;
        userCredential = await FirebaseAuth.instance.signInWithCredential(
          GoogleAuthProvider.credential(accessToken: gAuth.accessToken, idToken: gAuth.idToken),
        );
      }

      final emailCred = EmailAuthProvider.credential(email: userCredential.user!.email!, password: password);
      await userCredential.user!.linkWithCredential(emailCred);
      _showSnack('Password linked! You can now use both login methods.', isError: false);
      _navigateNext(userCredential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use' || e.code == 'provider-already-linked') {
        _showSnack('A password is already linked. Try logging in with your email & password.');
      } else {
        _showSnack(e.message ?? 'Linking failed.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── UI BUILDERS ──────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Background Aesthetic
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF101010), // Deep Dark
                    Theme.of(context).primaryColorDark.withOpacity(0.8),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(top: -100, right: -50, child: _Glow(color: const Color(0xFFE5FF00).withOpacity(0.15), size: 300)),
                  Positioned(top: 200, left: -100, child: _Glow(color: Colors.blueAccent.withOpacity(0.1), size: 400)),
                  
                  SafeArea(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: Column(
                          children: [
                            const _VideoLogoLoop(),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Sheet UI
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            bottom: bottomInset,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, -10)),
                ],
              ),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildCurrentView(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentView) {
      case AuthView.phone: return _buildPhoneView();
      case AuthView.otp: return _buildOtpView();
      case AuthView.email: return _buildEmailView();
    }
  }

  Widget _buildPhoneView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      key: const ValueKey('phone'),
      children: [
        Text('Get Started', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color, letterSpacing: -0.5)),
        const SizedBox(height: 6),
        Text('Please enter your mobile number', style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6))),
        const SizedBox(height: 32),
        
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('+91', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
              ),
              Container(width: 1, height: 24, color: Theme.of(context).dividerColor.withOpacity(0.1)),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color, letterSpacing: 1),
                  decoration: InputDecoration(
                    hintText: 'Mobile Number',
                    hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.3), fontWeight: FontWeight.normal, letterSpacing: 0),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        ElevatedButton(
          onPressed: _isLoading ? null : _sendOtp,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE5FF00),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 18),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: _isLoading 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
              : const Text('Send OTP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5)),
        ),
        
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: Divider(color: Theme.of(context).dividerColor.withOpacity(0.1))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('OR CONTINUE WITH', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.4))),
            ),
            Expanded(child: Divider(color: Theme.of(context).dividerColor.withOpacity(0.1))),
          ],
        ),
        const SizedBox(height: 24),
        
        Row(
          children: [
            Expanded(
              child: _socialButton(
                child: Image.asset('assets/images/google_logo.png', height: 22, errorBuilder: (c, e, s) => const Icon(Icons.g_mobiledata)),
                label: 'Google', 
                onTap: _signInWithGoogle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _socialButton(
                child: Icon(Icons.email_outlined, size: 22, color: Theme.of(context).textTheme.bodyLarge?.color),
                label: 'Email', 
                onTap: () => setState(() => _currentView = AuthView.email),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _socialButton({required Widget child, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.08)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            child,
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Theme.of(context).textTheme.bodyLarge?.color)),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      key: const ValueKey('otp'),
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Theme.of(context).iconTheme.color),
              onPressed: () => setState(() => _currentView = AuthView.phone),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              alignment: Alignment.centerLeft,
            ),
            Text('Verification', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color, letterSpacing: -0.5)),
          ],
        ),
        const SizedBox(height: 6),
        Text('Enter the 6-digit code sent to +91 ${_phoneController.text}', style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6))),
        const SizedBox(height: 32),
        
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 32, letterSpacing: 16, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            counterText: '',
            hintText: '000000',
            hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.1)),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 20),
          ),
        ),
        const SizedBox(height: 32),
        
        ElevatedButton(
          onPressed: _isLoading ? null : _verifyOtp,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE5FF00),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 18),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: _isLoading 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
              : const Text('Verify & Continue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5)),
        ),
      ],
    );
  }

  Widget _buildEmailView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      key: const ValueKey('email'),
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Theme.of(context).iconTheme.color),
              onPressed: () => setState(() => _currentView = AuthView.phone),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              alignment: Alignment.centerLeft,
            ),
            Text(_isLogin ? 'Welcome Back' : 'Create Account', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color, letterSpacing: -0.5)),
          ],
        ),
        const SizedBox(height: 24),
        
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15),
          decoration: InputDecoration(
            labelText: 'Email Address',
            labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5)),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: true,
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15),
          decoration: InputDecoration(
            labelText: 'Password',
            labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5)),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          ),
        ),
        const SizedBox(height: 32),
        
        ElevatedButton(
          onPressed: _isLoading ? null : _submitEmail,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE5FF00),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 18),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: _isLoading 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
              : Text(_isLogin ? 'LOGIN' : 'SIGN UP', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5)),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(() => _isLogin = !_isLogin),
          child: Text(
            _isLogin ? 'Don\'t have an account? Sign up' : 'Already have an account? Login',
            style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color;
  final double size;
  const _Glow({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 50)],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VIDEO LOGO LOOP
// ─────────────────────────────────────────────────────────────────────────────
class _VideoLogoLoop extends StatefulWidget {
  const _VideoLogoLoop();

  @override
  State<_VideoLogoLoop> createState() => _VideoLogoLoopState();
}

class _VideoLogoLoopState extends State<_VideoLogoLoop> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 420,
      height: 280,
      child: Image.asset(
        'assets/animation/loop_transparent.gif',
        fit: BoxFit.contain,
      ),
    );
  }
}

