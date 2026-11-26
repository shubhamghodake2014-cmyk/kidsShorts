
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';

import 'firebase_options.dart';

const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://192.168.31.92:3000',
);

const MethodChannel kidsModeChannel = MethodChannel(
  'com.example.kidz_shorts/kids_mode',
);

final RouteObserver<ModalRoute<dynamic>> kidzRouteObserver =
    RouteObserver<ModalRoute<dynamic>>();

const Color primaryColor = Color(0xFF7551E8);
const Color darkColor = Color(0xFF302052);
const Color backgroundColor = Color(0xFFF7F5FF);
const Color pinkColor = Color(0xFFFF8EB7);
const Color purpleLight = Color(0xFFECE6FF);

String createPinHash(String uid, String pin) {
  return sha256.convert(utf8.encode('${uid}_$pin')).toString();
}

DocumentReference<Map<String, dynamic>> parentSettingsRef(String uid) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('settings')
      .doc('parent');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const KidzShortsApp());
}

class KidzShortsApp extends StatelessWidget {
  const KidzShortsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KidzShorts',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: darkColor,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: darkColor,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFFFCFF),
          contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 17),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(color: Color(0xFFECE5FA)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(color: Color(0xFFECE5FA)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(color: primaryColor, width: 1.7),
          ),
        ),
      ),
      navigatorObservers: [kidzRouteObserver],
      home: const AuthGate(),
    );
  }
}

// ============================================================
// COMMON UI HELPERS
// ============================================================

void showAppMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
  );
}

Widget sectionHeading(String title, String subtitle, IconData icon) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      children: [
        Container(
          height: 43,
          width: 43,
          decoration: BoxDecoration(
            color: purpleLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: darkColor,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget premiumCard({required Widget child, EdgeInsets? padding}) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 240),
    curve: Curves.easeOutCubic,
    width: double.infinity,
    padding: padding ?? const EdgeInsets.all(19),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white, Color(0xFFFFFDFF)],
      ),
      borderRadius: BorderRadius.circular(25),
      border: Border.all(color: const Color(0xFFEFE9FA)),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF493477).withValues(alpha: 0.075),
          blurRadius: 22,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: child,
  );
}

Widget primaryButton({
  required String label,
  required VoidCallback? onPressed,
  IconData icon = Icons.arrow_forward_rounded,
  bool loading = false,
}) {
  return SizedBox(
    width: double.infinity,
    height: 57,
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7551E8), Color(0xFF9C73F4)],
        ),
        borderRadius: BorderRadius.circular(19),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.28),
            blurRadius: 17,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Icon(icon),
        label: Text(
          loading ? 'Please wait...' : label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    ),
  );
}

IconData _avatarIcon(int index) {
  const avatars = [
    Icons.child_care,
    Icons.face,
    Icons.face_3,
    Icons.face_4,
    Icons.boy,
    Icons.girl,
  ];

  if (index < 0 || index >= avatars.length) return avatars.first;
  return avatars[index];
}

// ============================================================
// AUTH GATE
// ============================================================

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        }

        final user = snapshot.data;

        if (user == null) {
          return const LoginScreen();
        }

        return UserSettingsGate(user: user);
      },
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3FF),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.82, end: 1),
              duration: const Duration(milliseconds: 850),
              curve: Curves.elasticOut,
              builder: (context, value, child) => Transform.scale(
                scale: value,
                child: child,
              ),
              child: Container(
                height: 88,
                width: 88,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7551E8), Color(0xFFFF91BD)],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.22),
                      blurRadius: 22,
                      offset: const Offset(0, 9),
                    ),
                  ],
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 58),
              ),
            ),
            const SizedBox(height: 17),
            const Text('KidzShorts', style: TextStyle(color: darkColor, fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            const SizedBox(width: 110, child: LinearProgressIndicator(minHeight: 5, borderRadius: BorderRadius.all(Radius.circular(9)), color: pinkColor, backgroundColor: Color(0xFFE9E1FA))),
            const SizedBox(height: 9),
            const Text('Getting the fun ready...', style: TextStyle(color: Colors.black45, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class UserSettingsGate extends StatelessWidget {
  final User user;

  const UserSettingsGate({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: parentSettingsRef(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: backgroundColor,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    size: 55,
                    color: primaryColor,
                  ),
                  const SizedBox(height: 12),
                  const Text('Settings load झाले नाहीत.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserSettingsGate(user: user),
                        ),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                  TextButton(
                    onPressed: () => FirebaseAuth.instance.signOut(),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
          );
        }

        final data = snapshot.data?.data();

        if (data == null || data['setupCompleted'] != true) {
          return const ParentDashboard(isInitialSetup: true);
        }

        return KidsHomeScreen(
          language: data['language'] ?? 'Marathi',
          categories: List<String>.from(
            data['categories'] ?? ['Rhymes', 'Education'],
          ),
        );
      },
    );
  }
}

// ============================================================
// LOGIN SCREEN
// ============================================================

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6846D9),
              Color(0xFF9875F2),
              Color(0xFFFFC5DF),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                const SizedBox(height: 28),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.72, end: 1),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) => Transform.scale(scale: value, child: child),
                  child: Container(
                    height: 108,
                    width: 108,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(35),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.75), width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: darkColor.withValues(alpha: 0.2),
                          blurRadius: 26,
                          offset: const Offset(0, 11),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.play_circle_fill_rounded, color: primaryColor, size: 76),
                  ),
                ),
                const SizedBox(height: 17),
                const Text(
                  'KidzShorts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                const Text(
                  'Little Smiles, Safe Entertainment!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 35),
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: darkColor.withValues(alpha: 0.12),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Welcome Back!',
                        style: TextStyle(
                          color: darkColor,
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 9),
                      const Text(
                        'A little world of learning, fun and smiles.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            showAppMessage(
                              context,
                              'Google Login will be added next.',
                            );
                          },
                          icon: const Icon(
                            Icons.g_mobiledata,
                            size: 32,
                            color: Color(0xFF4285F4),
                          ),
                          label: const Text('Continue with Google'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: darkColor,
                            side: const BorderSide(
                              color: Color(0xFFE4DDF4),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(17),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 13),
                      primaryButton(
                        label: 'Continue with Email',
                        icon: Icons.email_rounded,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EmailAuthScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      const Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'NEW TO KIDZSHORTS?',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EmailAuthScreen(
                                  createAccount: true,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.person_add_alt_1_rounded),
                          label: const Text(
                            'Create Account',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: const BorderSide(
                              color: primaryColor,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(17),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.verified_user_rounded,
                            color: primaryColor,
                          ),
                          SizedBox(width: 9),
                          Text(
                            'A safer little screen for little smiles',
                            style: TextStyle(
                              color: darkColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  'MADE FOR LITTLE EXPLORERS ✨',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
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

// ============================================================
// EMAIL LOGIN / SIGNUP
// ============================================================

class EmailAuthScreen extends StatefulWidget {
  final bool createAccount;

  const EmailAuthScreen({super.key, this.createAccount = false});

  @override
  State<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends State<EmailAuthScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  String getFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
      case 'invalid-credential':
      case 'wrong-password':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password must contain at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Please check your internet connection.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }

  Future<void> authenticate() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final isSignup = widget.createAccount;

    if (isSignup && nameController.text.trim().isEmpty) {
      showAppMessage(context, 'Please enter your name.');
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      showAppMessage(context, 'Please enter a valid email address.');
      return;
    }

    if (password.length < 6) {
      showAppMessage(context, 'Password must contain at least 6 characters.');
      return;
    }

    setState(() => isLoading = true);

    try {
      final auth = FirebaseAuth.instance;

      if (isSignup) {
        final credential = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        await credential.user?.updateDisplayName(
          nameController.text.trim(),
        );
      } else {
        await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }

      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      if (mounted) showAppMessage(context, getFirebaseError(e));
    } catch (e) {
      debugPrint('AUTH ERROR: $e');
      if (mounted) {
        showAppMessage(context, 'Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  InputDecoration inputDecoration(
    String label,
    IconData icon, {
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryColor),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF8F6FF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: Color(0xFFECE6FA)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSignup = widget.createAccount;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(isSignup ? 'Create Account' : 'Email Login'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(23),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              Center(
                child: Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [primaryColor, Color(0xFFAD8AF8)],
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Icon(
                    isSignup
                        ? Icons.rocket_launch_rounded
                        : Icons.lock_rounded,
                    size: 46,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 23),
              Center(
                child: Text(
                  isSignup ? 'Join the Fun!' : 'Welcome Back!',
                  style: const TextStyle(
                    color: darkColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 7),
              Center(
                child: Text(
                  isSignup
                      ? 'Create your family account'
                      : 'Sign in to your family account',
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
              const SizedBox(height: 35),
              if (isSignup) ...[
                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: inputDecoration(
                    'Your Name',
                    Icons.person_outline_rounded,
                  ),
                ),
                const SizedBox(height: 17),
              ],
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: inputDecoration(
                  'Email Address',
                  Icons.email_outlined,
                ),
              ),
              const SizedBox(height: 17),
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                autofillHints: [
                  isSignup ? AutofillHints.newPassword : AutofillHints.password,
                ],
                decoration: inputDecoration(
                  'Password',
                  Icons.lock_outline_rounded,
                  suffix: IconButton(
                    onPressed: () {
                      setState(() => obscurePassword = !obscurePassword);
                    },
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              primaryButton(
                label: isSignup ? 'Create My Account' : 'Login Securely',
                icon: isSignup
                    ? Icons.person_add_alt_1_rounded
                    : Icons.login_rounded,
                loading: isLoading,
                onPressed: isLoading ? null : authenticate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PARENT PIN LOGIN
// ============================================================

class ParentLoginScreen extends StatefulWidget {
  const ParentLoginScreen({super.key});

  @override
  State<ParentLoginScreen> createState() => _ParentLoginScreenState();
}

class _ParentLoginScreenState extends State<ParentLoginScreen> {
  final pinController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final pin = pinController.text.trim();

    if (pin.length != 4) {
      showAppMessage(context, 'Please enter a 4-digit PIN.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showAppMessage(context, 'Please login again.');
      return;
    }

    setState(() => isLoading = true);

    try {
      final doc = await parentSettingsRef(user.uid).get();
      final data = doc.data();

      if (data == null || data['parentPinHash'] == null) {
        if (mounted) showAppMessage(context, 'Parent PIN is not configured.');
        return;
      }

      if (createPinHash(user.uid, pin) != data['parentPinHash']) {
        if (mounted) showAppMessage(context, 'Incorrect PIN. Try again.');
        pinController.clear();
        return;
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ParentDashboard(initialSettings: data),
        ),
      );
    } catch (e) {
      debugPrint('PIN ERROR: $e');
      if (mounted) {
        showAppMessage(context, 'Unable to verify PIN. Please try again.');
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6040CC),
              Color(0xFF9D7CF0),
              Color(0xFFE8B9E7),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(23),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(27),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: darkColor.withValues(alpha: 0.16),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 86,
                      width: 86,
                      decoration: const BoxDecoration(
                        color: purpleLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        size: 48,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Parent Zone',
                      style: TextStyle(
                        fontSize: 29,
                        color: darkColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This space is just for parents.\nEnter your secret PIN to continue.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: pinController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 4,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 30,
                        letterSpacing: 17,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '••••',
                        hintStyle: const TextStyle(
                          letterSpacing: 12,
                          color: Colors.black26,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8F6FF),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: Color(0xFFE8E0FA),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: primaryColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    primaryButton(
                      label: 'Unlock Parent Zone',
                      icon: Icons.lock_open_rounded,
                      loading: isLoading,
                      onPressed: isLoading ? null : login,
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_user_rounded,
                          color: primaryColor,
                          size: 18,
                        ),
                        SizedBox(width: 7),
                        Text(
                          'Parent access protected',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PARENT DASHBOARD
// ============================================================

class ParentDashboard extends StatefulWidget {
  final bool isInitialSetup;
  final Map<String, dynamic>? initialSettings;

  const ParentDashboard({
    super.key,
    this.isInitialSetup = false,
    this.initialSettings,
  });

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  String ageGroup = '2–4 Years';
  String language = 'Marathi';
  double screenTime = 30;

  String childName = '';
  DateTime? birthDate;
  int avatarIndex = 0;

  final pinController = TextEditingController();
  final confirmPinController = TextEditingController();

  bool isSaving = false;

  final List<String> categories = [
    'Rhymes',
    'Education',
    'Stories',
    'Cartoons',
    'Animals',
    'Drawing',
  ];

  final Set<String> selectedCategories = {
    'Rhymes',
    'Education',
  };

  final Map<String, IconData> categoryIcons = {
    'Rhymes': Icons.music_note_rounded,
    'Education': Icons.school_rounded,
    'Stories': Icons.auto_stories_rounded,
    'Cartoons': Icons.smart_toy_rounded,
    'Animals': Icons.pets_rounded,
    'Drawing': Icons.palette_rounded,
  };

  final Map<String, Color> categoryColors = {
    'Rhymes': const Color(0xFFFFE8F1),
    'Education': const Color(0xFFE5EFFF),
    'Stories': const Color(0xFFFFF0D9),
    'Cartoons': const Color(0xFFEAE4FF),
    'Animals': const Color(0xFFE1F5E9),
    'Drawing': const Color(0xFFFFE9DF),
  };

  @override
  void initState() {
    super.initState();

    final data = widget.initialSettings;

    if (data != null) {
      ageGroup = data['ageGroup'] ?? ageGroup;
      language = data['language'] ?? language;
      screenTime = (data['screenTimeMinutes'] ?? 30).toDouble();
      childName = data['childName'] ?? '';

      final savedDate = data['birthDate'];
      if (savedDate is Timestamp) {
        birthDate = savedDate.toDate();
      }

      avatarIndex = data['avatarIndex'] ?? 0;

      selectedCategories
        ..clear()
        ..addAll(
          List<String>.from(
            data['categories'] ?? ['Rhymes', 'Education'],
          ),
        );
    }
  }

  @override
  void dispose() {
    pinController.dispose();
    confirmPinController.dispose();
    super.dispose();
  }

  Future<void> openChildProfile() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => ChildProfileScreen(
          initialName: childName,
          initialBirthDate: birthDate,
          initialAvatar: avatarIndex,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        childName = result['childName'];
        birthDate = result['birthDate'];
        avatarIndex = result['avatarIndex'];
      });
    }
  }

  Future<void> exitKidsMode() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Exit Kids Mode?'),
          content: const Text(
            'KidzShorts will close and your phone will return to normal mode.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Exit Kids Mode'),
            ),
          ],
        );
      },
    );

    if (shouldExit == true && mounted) {
      try {
        await kidsModeChannel.invokeMethod<void>(
          'setProtectionEnabled',
          {'enabled': false},
        );
      } catch (e) {
        debugPrint('DISABLE KIDS MODE PROTECTION ERROR: $e');
      }

      await SystemNavigator.pop();
    }
  }

  Future<void> saveSettings() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    if (childName.trim().isEmpty || birthDate == null) {
      showAppMessage(context, 'Please complete Child Profile first.');
      return;
    }

    if (selectedCategories.isEmpty) {
      showAppMessage(context, 'Select at least one category.');
      return;
    }

    final pin = pinController.text.trim();
    final confirmPin = confirmPinController.text.trim();

    if (widget.isInitialSetup && pin.length != 4) {
      showAppMessage(context, 'Please create a 4-digit Parent PIN.');
      return;
    }

    if (pin.isNotEmpty || confirmPin.isNotEmpty) {
      if (pin.length != 4 || confirmPin.length != 4) {
        showAppMessage(context, 'Both PIN fields must contain 4 digits.');
        return;
      }

      if (pin != confirmPin) {
        showAppMessage(context, 'PIN and Confirm PIN do not match.');
        return;
      }
    }

    setState(() => isSaving = true);

    try {
      final ref = parentSettingsRef(user.uid);
      final existing = await ref.get();

      final Map<String, dynamic> settings = {
        'childName': childName.trim(),
        'birthDate': Timestamp.fromDate(birthDate!),
        'avatarIndex': avatarIndex,
        'ageGroup': ageGroup,
        'language': language,
        'screenTimeMinutes': screenTime.toInt(),
        'categories': selectedCategories.toList(),
        'setupCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (pin.isNotEmpty) {
        settings['parentPinHash'] = createPinHash(user.uid, pin);
      } else if (existing.exists) {
        settings['parentPinHash'] = existing.data()?['parentPinHash'];
      }

      await ref.set(settings, SetOptions(merge: true));

      if (!mounted) return;

      showAppMessage(context, 'Your settings have been saved!');

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => KidsHomeScreen(
            language: language,
            categories: selectedCategories.toList(),
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      debugPrint('SAVE SETTINGS ERROR: $e');
      if (mounted) {
        showAppMessage(context, 'Unable to save settings. Please try again.');
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Widget buildChildCard() {
    return InkWell(
      borderRadius: BorderRadius.circular(25),
      onTap: openChildProfile,
      child: Container(
        padding: const EdgeInsets.all(19),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6949D9),
              Color(0xFF9D7AF0),
              Color(0xFFC19AF8),
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.2),
              blurRadius: 17,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 76,
              width: 76,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.7),
                  width: 3,
                ),
              ),
              child: Icon(
                _avatarIcon(avatarIndex),
                color: primaryColor,
                size: 48,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CHILD PROFILE',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    childName.isEmpty ? 'Add your child' : childName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    birthDate == null
                        ? 'Create a little profile'
                        : 'Born ${birthDate!.day}/${birthDate!.month}/${birthDate!.year}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 39,
              width: 39,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildScreenTime() {
    final presets = [15, 30, 45, 60, 90, 120];

    return premiumCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9E5FF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.timer_rounded,
                  color: primaryColor,
                  size: 27,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Screen Time',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: darkColor,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Choose a daily viewing target',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            height: 125,
            width: 125,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF2EEFF),
              border: Border.all(
                color: const Color(0xFFE2D9FF),
                width: 9,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  screenTime.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: primaryColor,
                  ),
                ),
                const Text(
                  'MINUTES',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: darkColor,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 9,
            alignment: WrapAlignment.center,
            children: presets.map((minutes) {
              final selected = screenTime.toInt() == minutes;

              return ChoiceChip(
                label: Text('$minutes min'),
                selected: selected,
                onSelected: (_) {
                  setState(() => screenTime = minutes.toDouble());
                },
                selectedColor: primaryColor,
                backgroundColor: const Color(0xFFF5F2FC),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : darkColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
                side: BorderSide(
                  color: selected ? primaryColor : const Color(0xFFECE6F6),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Slider(
            value: screenTime,
            min: 15,
            max: 120,
            divisions: 21,
            activeColor: primaryColor,
            inactiveColor: const Color(0xFFEAE4F8),
            onChanged: (value) {
              setState(() => screenTime = value);
            },
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '15 minutes',
                style: TextStyle(color: Colors.black45, fontSize: 11),
              ),
              Text(
                '120 minutes',
                style: TextStyle(color: Colors.black45, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildAgeGroup() {
    final options = ['2–4 Years', '5–7 Years', '8–12 Years'];

    return premiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionHeading(
            'Age Group',
            'Choose content suitable for your child',
            Icons.child_friendly_rounded,
          ),
          ...options.map((age) {
            final selected = ageGroup == age;

            return Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () => setState(() => ageGroup = age),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? purpleLight : const Color(0xFFFAF9FD),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: selected
                          ? primaryColor
                          : const Color(0xFFEFEAF6),
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.face_rounded,
                        color: selected ? primaryColor : Colors.black38,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          age,
                          style: TextStyle(
                            color: selected ? darkColor : Colors.black87,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Icon(
                        selected
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        color: selected ? primaryColor : Colors.black26,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget buildLanguage() {
    final languages = [
      {'name': 'Marathi', 'symbol': 'अ', 'subtitle': 'मराठी'},
      {'name': 'Hindi', 'symbol': 'अ', 'subtitle': 'हिन्दी'},
      {'name': 'English', 'symbol': 'A', 'subtitle': 'English'},
    ];

    return premiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionHeading(
            'Preferred Language',
            'Pick your child’s favourite language',
            Icons.translate_rounded,
          ),
          Row(
            children: languages.map((item) {
              final name = item['name']!;
              final selected = language == name;

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => language = name),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: selected ? purpleLight : const Color(0xFFFAF9FD),
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(
                        color: selected
                            ? primaryColor
                            : const Color(0xFFEFEAF6),
                        width: selected ? 1.6 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          item['symbol']!,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                            color: selected ? primaryColor : darkColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: selected ? primaryColor : darkColor,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item['subtitle']!,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black45,
                          ),
                        ),
                        if (selected)
                          const Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Icon(
                              Icons.check_circle,
                              color: primaryColor,
                              size: 17,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget buildCategories() {
    return premiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionHeading(
            'Content Preferences',
            'Choose what your child can watch',
            Icons.grid_view_rounded,
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.2,
            ),
            itemBuilder: (context, index) {
              final category = categories[index];
              final selected = selectedCategories.contains(category);

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  setState(() {
                    if (selected) {
                      selectedCategories.remove(category);
                    } else {
                      selectedCategories.add(category);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? categoryColors[category]
                        : const Color(0xFFFAF9FD),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected
                          ? primaryColor.withValues(alpha: 0.5)
                          : const Color(0xFFEFEAF6),
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        categoryIcons[category],
                        color: selected ? primaryColor : Colors.black45,
                        size: 23,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          category,
                          style: TextStyle(
                            color: darkColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Icon(
                        selected
                            ? Icons.check_circle_rounded
                            : Icons.add_circle_outline_rounded,
                        color: selected ? primaryColor : Colors.black26,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            '${selectedCategories.length} categories selected',
            style: const TextStyle(
              color: primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPinSetup() {
    return premiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionHeading(
            'Parent Security',
            'Protect settings with your private PIN',
            Icons.shield_rounded,
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F0FF),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_rounded, color: primaryColor, size: 26),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Only parents with the PIN can access these controls.',
                    style: TextStyle(
                      color: darkColor,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 17),
          TextField(
            controller: pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 4,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              labelText: 'Create 4-digit PIN',
              prefixIcon: const Icon(Icons.lock_outline),
              counterText: '',
              filled: true,
              fillColor: const Color(0xFFFAF9FD),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: confirmPinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 4,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              labelText: 'Confirm 4-digit PIN',
              prefixIcon: const Icon(Icons.verified_user_outlined),
              counterText: '',
              filled: true,
              fillColor: const Color(0xFFFAF9FD),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (!widget.isInitialSetup) ...[
            const SizedBox(height: 8),
            const Text(
              'Leave both fields empty to keep your existing PIN.',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 15, 12, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF5D3BCB), Color(0xFF8965E8), Color(0xFFB18CF4)],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(color: Color(0x334D32A5), blurRadius: 20, offset: Offset(0, 8)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isInitialSetup ? 'Let’s Get Started!' : 'Parent Dashboard',
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.3),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Your child. Your choices. Your control.',
                          style: TextStyle(color: Color(0xD9FFFFFF), fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.17), borderRadius: BorderRadius.circular(20)),
                          child: const Text('✦  PARENT SPACE', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Logout',
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(17, 19, 17, 25),
                children: [
                  if (widget.isInitialSetup)
                    Container(
                      padding: const EdgeInsets.all(15),
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1D9),
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            color: Color(0xFFDE9A2F),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Set up your child’s profile and preferences to begin!',
                              style: TextStyle(
                                color: Color(0xFF80561A),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  buildChildCard(),
                  const SizedBox(height: 23),
                  sectionHeading(
                    'Personalize Experience',
                    'Make KidzShorts just right for your child',
                    Icons.auto_awesome_rounded,
                  ),
                  buildScreenTime(),
                  const SizedBox(height: 17),
                  buildAgeGroup(),
                  const SizedBox(height: 17),
                  buildLanguage(),
                  const SizedBox(height: 17),
                  buildCategories(),
                  const SizedBox(height: 17),
                  buildPinSetup(),
                  if (!widget.isInitialSetup) ...[
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => KidsHomeScreen(
                                language: language,
                                categories: selectedCategories.toList(),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.play_circle_fill_rounded),
                        label: const Text(
                          'Preview Kids Feed',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          side: const BorderSide(color: primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 52,
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: exitKidsMode,
                        icon: const Icon(Icons.exit_to_app_rounded),
                        label: const Text(
                          'Exit Kids Mode',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  primaryButton(
                    label: widget.isInitialSetup
                        ? 'Save & Start KidzShorts'
                        : 'Save All Settings',
                    icon: Icons.check_circle_rounded,
                    loading: isSaving,
                    onPressed: isSaving ? null : saveSettings,
                  ),
                  const SizedBox(height: 14),
                  const Center(
                    child: Text(
                      'Made with ❤️ for little explorers',
                      style: TextStyle(
                        color: Colors.black38,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CHILD PROFILE
// ============================================================

class ChildProfileScreen extends StatefulWidget {
  final String initialName;
  final DateTime? initialBirthDate;
  final int initialAvatar;

  const ChildProfileScreen({
    super.key,
    this.initialName = '',
    this.initialBirthDate,
    this.initialAvatar = 0,
  });

  @override
  State<ChildProfileScreen> createState() => _ChildProfileScreenState();
}

class _ChildProfileScreenState extends State<ChildProfileScreen> {
  final nameController = TextEditingController();

  DateTime? birthDate;
  int selectedAvatar = 0;

  final List<IconData> avatars = [
    Icons.child_care,
    Icons.face,
    Icons.face_3,
    Icons.face_4,
    Icons.boy,
    Icons.girl,
  ];

  @override
  void initState() {
    super.initState();
    nameController.text = widget.initialName;
    birthDate = widget.initialBirthDate;
    selectedAvatar = widget.initialAvatar;
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  int calculateAge(DateTime dob) {
    final today = DateTime.now();
    int age = today.year - dob.year;

    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }

    return age;
  }

  Future<void> selectBirthDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: birthDate ?? now,
      firstDate: DateTime(2010),
      lastDate: now,
      helpText: 'Select Child Date of Birth',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryColor,
              primary: primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => birthDate = picked);
    }
  }

  void saveProfile() {
    if (nameController.text.trim().isEmpty) {
      showAppMessage(context, 'Please enter child name.');
      return;
    }

    if (birthDate == null) {
      showAppMessage(context, 'Please select date of birth.');
      return;
    }

    final age = calculateAge(birthDate!);

    if (age < 0 || age > 12) {
      showAppMessage(context, 'Please select a valid age (0–12).');
      return;
    }

    Navigator.pop(context, {
      'childName': nameController.text.trim(),
      'birthDate': birthDate,
      'avatarIndex': selectedAvatar,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Child Profile',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(19),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(23),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7450DF), Color(0xFFAE8AF4)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  children: [
                    const Text(
                      'A Little Star Is Here!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Create a cute profile for your little one',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 23),
                    Container(
                      height: 112,
                      width: 112,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white70,
                          width: 4,
                        ),
                      ),
                      child: Icon(
                        avatars[selectedAvatar],
                        size: 67,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'CHOOSE YOUR AVATAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: List.generate(avatars.length, (index) {
                        final selected = selectedAvatar == index;

                        return GestureDetector(
                          onTap: () {
                            setState(() => selectedAvatar = index);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFFFFD9EB)
                                  : Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selected
                                    ? Colors.white
                                    : Colors.white38,
                                width: selected ? 2.5 : 1,
                              ),
                            ),
                            child: Icon(
                              avatars[index],
                              color: selected ? primaryColor : Colors.white,
                              size: 27,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              premiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionHeading(
                      'What should we call them?',
                      'Enter your child’s name',
                      Icons.person_rounded,
                    ),
                    TextField(
                      controller: nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: 'Enter child name',
                        prefixIcon: const Icon(
                          Icons.face_rounded,
                          color: primaryColor,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFFAF9FD),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 17),
              premiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionHeading(
                      'Date of Birth',
                      'We use this to understand their age group',
                      Icons.cake_rounded,
                    ),
                    InkWell(
                      onTap: selectBirthDate,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(17),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF9FD),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFECE6F6),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_rounded,
                              color: primaryColor,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                birthDate == null
                                    ? 'Select Date of Birth'
                                    : '${birthDate!.day}/${birthDate!.month}/${birthDate!.year}',
                                style: const TextStyle(
                                  color: darkColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.black38,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (birthDate != null) ...[
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF8F0),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.celebration_rounded,
                              color: Color(0xFF36A66A),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Age: ${calculateAge(birthDate!)} Years',
                              style: const TextStyle(
                                color: Color(0xFF26794D),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 23),
              primaryButton(
                label: 'Save Child Profile',
                icon: Icons.check_circle_rounded,
                onPressed: saveProfile,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}


// ============================================================
// KIDZSHORTS HOME - LANDSCAPE VIDEO DISCOVERY
// ============================================================

class KidsHomeScreen extends StatefulWidget {
  final String language;
  final List<String> categories;
  const KidsHomeScreen({super.key, required this.language, required this.categories});

  @override
  State<KidsHomeScreen> createState() => _KidsHomeScreenState();
}

class _KidsHomeScreenState extends State<KidsHomeScreen> {
  static const List<String> homeCategories = ['All', 'Rhymes', 'Learning', 'Stories', 'Cartoons', 'Animals'];
  String selected = 'All';
  List<Map<String, dynamic>> videos = [];
  bool loading = true;
  String? error;
  int requestId = 0;

  String get languageCode => widget.language == 'Marathi' ? 'mr' : widget.language == 'Hindi' ? 'hi' : 'en';

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    WidgetsBinding.instance.addPostFrameCallback((_) => _enableProtection());
    loadHomeVideos('All');
  }

  Future<void> _enableProtection() async {
    try {
      final enabled = await kidsModeChannel.invokeMethod<bool>('isAccessibilityEnabled') ?? false;
      await kidsModeChannel.invokeMethod<void>('setProtectionEnabled', {'enabled': enabled});
    } catch (e) { debugPrint('HOME KIDS MODE: $e'); }
  }

  Future<void> loadHomeVideos(String category) async {
    final request = ++requestId;
    setState(() { selected = category; loading = true; error = null; videos = []; });
    try {
      final uri = Uri.parse('$apiBaseUrl/home-videos').replace(queryParameters: {'category': category, 'language': languageCode});
      final response = await http.get(uri).timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) throw Exception('Server error: ${response.statusCode}');
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final list = (data['videos'] as List? ?? []).map((v) => Map<String, dynamic>.from(v)).toList();
      if (!mounted || request != requestId) return;
      setState(() { videos = list; loading = false; });
    } catch (e) {
      if (!mounted || request != requestId) return;
      setState(() { loading = false; error = e.toString(); });
    }
  }

  Future<void> openParentControls() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const ParentLoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101014),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101014), foregroundColor: Colors.white,
        titleSpacing: 16,
        title: Row(children: [
          Container(width: 34, height: 30, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF4F91), Color(0xFF7651E8)]), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 25)),
          const SizedBox(width: 9), const Text('KidzShorts', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        ]),
        actions: [IconButton(tooltip: 'Parent Controls', onPressed: openParentControls, icon: const Icon(Icons.lock_outline_rounded)), const SizedBox(width: 5)],
      ),
      body: Column(children: [
        SizedBox(height: 52, child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7), scrollDirection: Axis.horizontal,
          itemCount: homeCategories.length, separatorBuilder: (_, __) => const SizedBox(width: 9),
          itemBuilder: (context, i) {
            final c = homeCategories[i]; final active = selected == c;
            return ChoiceChip(label: Text(c), selected: active, onSelected: (_) => loadHomeVideos(c), showCheckmark: false,
              labelStyle: TextStyle(fontWeight: FontWeight.w800, color: active ? const Color(0xFF25183F) : Colors.white),
              selectedColor: const Color(0xFFFFD45E), backgroundColor: const Color(0xFF303036), side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)));
          },
        )),
        Expanded(child: loading ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD45E)))
          : error != null ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.wifi_off_rounded, color: Colors.white70, size: 42), const SizedBox(height: 12), const Text('Videos load nahi zale', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), const SizedBox(height: 12), Text(error!, style: const TextStyle(color: Colors.white60), textAlign: TextAlign.center), TextButton(onPressed: () => loadHomeVideos(selected), child: const Text('Retry'))])))
          : videos.isEmpty ? const Center(child: Text('No videos found. Try another category.', style: TextStyle(color: Colors.white70)))
          : RefreshIndicator(color: const Color(0xFFFFD45E), onRefresh: () => loadHomeVideos(selected), child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20), itemCount: videos.length, itemBuilder: (context, index) {
                final video = videos[index];
                final thumb = video['thumbnail']?.toString() ?? '';
                final title = video['title']?.toString() ?? 'Kids video';
                return Padding(padding: const EdgeInsets.only(bottom: 20), child: InkWell(
                  borderRadius: BorderRadius.circular(17), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HomeVideoPlayerScreen(video: video))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    ClipRRect(borderRadius: BorderRadius.circular(17), child: AspectRatio(aspectRatio: 16/9, child: Stack(fit: StackFit.expand, children: [
                      thumb.isNotEmpty ? Image.network(thumb, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF34313D), child: const Icon(Icons.video_library_rounded, color: Colors.white54, size: 45))) : Container(color: const Color(0xFF34313D)),
                      Align(alignment: Alignment.bottomRight, child: Container(margin: const EdgeInsets.all(10), padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(8)), child: const Text('▶ PLAY', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)))),
                    ]))),
                    const SizedBox(height: 10), Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(width: 36, height: 36, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFFFF9CC5), Color(0xFF8D70F2)])), child: const Icon(Icons.child_friendly_rounded, color: Colors.white, size: 21)),
                      const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text('${video['channelTitle'] ?? 'KidzShorts'}  •  Kids video', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white60, fontSize: 11))])),
                      const Icon(Icons.more_vert_rounded, color: Colors.white70),
                    ]),
                  ]),
                ));
              },
            )),
        ),
      ]),
      bottomNavigationBar: _KidzBottomBar(selectedIndex: 0, onHome: () {}, onShorts: () => Navigator.push(context, MaterialPageRoute(builder: (_) => KidsFeedScreen(language: widget.language, categories: widget.categories)))),
    );
  }
}

class HomeVideoPlayerScreen extends StatefulWidget {
  final Map<String, dynamic> video;
  const HomeVideoPlayerScreen({super.key, required this.video});
  @override
  State<HomeVideoPlayerScreen> createState() => _HomeVideoPlayerScreenState();
}

class _HomeVideoPlayerScreenState extends State<HomeVideoPlayerScreen> {
  late final YoutubePlayerController controller;
  @override
  void initState() {
    super.initState();
    final id = widget.video['videoId'].toString();
    controller = YoutubePlayerController.fromVideoId(videoId: id, autoPlay: true, params: const YoutubePlayerParams(showControls: true, showFullscreenButton: false));
  }
  @override
  void dispose() { controller.close(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: Colors.black, appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white, title: const Text('KidzShorts')), body: Column(children: [AspectRatio(aspectRatio: 16/9, child: YoutubePlayer(controller: controller, aspectRatio: 16/9)), Padding(padding: const EdgeInsets.all(16), child: Text(widget.video['title']?.toString() ?? '', style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)))]));
}

class _KidzBottomBar extends StatelessWidget {
  final int selectedIndex; final VoidCallback onHome; final VoidCallback onShorts;
  const _KidzBottomBar({required this.selectedIndex, required this.onHome, required this.onShorts});
  @override
  Widget build(BuildContext context) => Container(color: const Color(0xFF17171C), child: SafeArea(top: false, child: SizedBox(height: 61, child: Row(children: [
    Expanded(child: InkWell(onTap: onHome, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.home_rounded, color: selectedIndex == 0 ? const Color(0xFFFFD45E) : Colors.white60), Text('Home', style: TextStyle(color: selectedIndex == 0 ? const Color(0xFFFFD45E) : Colors.white60, fontSize: 11, fontWeight: FontWeight.w800))]))),
    Expanded(child: InkWell(onTap: onShorts, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.smart_display_rounded, color: selectedIndex == 1 ? const Color(0xFFFFD45E) : Colors.white60), Text('Shorts', style: TextStyle(color: selectedIndex == 1 ? const Color(0xFFFFD45E) : Colors.white60, fontSize: 11, fontWeight: FontWeight.w800))]))),
  ]))));
}

// ============================================================
// KIDS SHORTS FEED
// ============================================================



class KidsFeedScreen extends StatefulWidget {
  final List<String> categories;
  final String language;

  const KidsFeedScreen({
    super.key,
    required this.categories,
    required this.language,
  });

  @override
  State<KidsFeedScreen> createState() => _KidsFeedScreenState();
}

class _KidsFeedScreenState extends State<KidsFeedScreen>
    with WidgetsBindingObserver, RouteAware {
  bool _accessibilityPromptShown = false;
  bool _resumeAfterParentControls = false;
  bool _resumeAfterAppBackground = false;
  ModalRoute<dynamic>? _subscribedRoute;
  final List<String> supportedCategories = [
    'Rhymes',
    'Education',
    'Stories',
    'Cartoons',
  ];

  final PageController pageController = PageController();

  YoutubePlayerController? player;
  YoutubePlayerController? standbyPlayer;

  StreamSubscription? playerSubscription;
  Timer? controlsTimer;

  List<String> availableCategories = [];
  List<Map<String, dynamic>> videos = [];

  String selectedCategory = 'Rhymes';
  String? errorMessage;
  String? nextPageToken;
  String? standbyVideoId;

  int currentIndex = 0;
  int requestVersion = 0;

  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMoreVideos = true;
  bool isReplaying = false;
  bool showPlaybackControls = false;
  bool isPlaying = true;

  final Set<String> loadedVideoIds = {};

  String get languageCode {
    switch (widget.language) {
      case 'Marathi':
        return 'mr';
      case 'Hindi':
        return 'hi';
      default:
        return 'en';
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _activateKidsModeProtection();
    });

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    availableCategories = widget.categories
        .where((category) => supportedCategories.contains(category))
        .toList();

    if (availableCategories.isEmpty) {
      availableCategories = ['Rhymes'];
    }

    selectedCategory = availableCategories.first;
    fetchVideos(selectedCategory);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final route = ModalRoute.of(context);
    if (route != null && route != _subscribedRoute) {
      if (_subscribedRoute != null) {
        kidzRouteObserver.unsubscribe(this);
      }
      _subscribedRoute = route;
      kidzRouteObserver.subscribe(this, route);
    }
  }

  // A parent screen (PIN, dashboard, settings or child profile) covers the
  // feed without changing the app lifecycle. Pause BOTH YouTube players.
  @override
  void didPushNext() {
    _resumeAfterParentControls = isPlaying;
    pauseAllPlayers();
    if (mounted) {
      setState(() {
        isPlaying = false;
        showPlaybackControls = false;
      });
    }
  }

  // Resume only when the parent flow is fully closed and the feed is visible.
  @override
  void didPopNext() {
    if (_resumeAfterParentControls && mounted) {
      player?.playVideo();
      setState(() => isPlaying = true);
    }
    _resumeAfterParentControls = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _resumeAfterAppBackground = isPlaying;
      pauseAllPlayers();
      if (mounted && isPlaying) {
        setState(() => isPlaying = false);
      }
      return;
    }

    if (state == AppLifecycleState.resumed) {
      // Resume only if the feed was playing before the app went to background
      // and no parent screen is currently covering it.
      if (_resumeAfterAppBackground && _subscribedRoute?.isCurrent == true) {
        player?.playVideo();
        if (mounted) setState(() => isPlaying = true);
      }
      _resumeAfterAppBackground = false;

      _activateKidsModeProtection(showPermissionPrompt: false);
    }
  }

  void pauseAllPlayers() {
    player?.pauseVideo();
    standbyPlayer?.pauseVideo();
  }

  Future<void> _activateKidsModeProtection({
    bool showPermissionPrompt = true,
  }) async {
    try {
      final serviceEnabled =
          await kidsModeChannel.invokeMethod<bool>('isAccessibilityEnabled') ??
              false;

      if (serviceEnabled) {
        await kidsModeChannel.invokeMethod<void>(
          'setProtectionEnabled',
          {'enabled': true},
        );
        return;
      }

      await kidsModeChannel.invokeMethod<void>(
        'setProtectionEnabled',
        {'enabled': false},
      );

      if (!showPermissionPrompt ||
          !mounted ||
          _accessibilityPromptShown) {
        return;
      }

      _accessibilityPromptShown = true;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Enable Kids Mode Protection'),
            content: const Text(
              'To bring KidzShorts back when Home or another app is opened, '
              'enable the KidzShorts Accessibility Service in Android Settings. '
              'This permission is used only for Kids Mode protection.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Later'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  try {
                    await kidsModeChannel.invokeMethod<void>(
                      'openAccessibilitySettings',
                    );
                  } catch (e) {
                    debugPrint('OPEN ACCESSIBILITY SETTINGS ERROR: $e');
                  }
                },
                child: const Text('Open Settings'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      debugPrint('KIDS MODE ACTIVATION ERROR: $e');
    }
  }

  void cancelControlsTimer() {
    controlsTimer?.cancel();
    controlsTimer = null;
  }

  void showControlsTemporarily() {
    if (!mounted) return;

    cancelControlsTimer();

    setState(() {
      showPlaybackControls = true;
    });

    controlsTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      setState(() {
        showPlaybackControls = false;
      });
    });
  }

  void togglePlayback() {
    final currentPlayer = player;
    if (currentPlayer == null) return;

    if (isPlaying) {
      currentPlayer.pauseVideo();
    } else {
      currentPlayer.playVideo();
    }

    setState(() {
      isPlaying = !isPlaying;
    });

    showControlsTemporarily();
  }

  void closePlayers() {
    playerSubscription?.cancel();
    playerSubscription = null;

    cancelControlsTimer();

    player?.close();
    player = null;

    standbyPlayer?.close();
    standbyPlayer = null;
    standbyVideoId = null;
  }

  void listenToActivePlayer(YoutubePlayerController controller) {
    playerSubscription?.cancel();

    playerSubscription = controller.stream.listen((value) {
      if (!mounted) return;

      if (value.playerState == PlayerState.playing) {
        if (!isPlaying) {
          setState(() => isPlaying = true);
        }
      } else if (value.playerState == PlayerState.paused) {
        if (isPlaying) {
          setState(() => isPlaying = false);
        }
      }

      if (value.playerState == PlayerState.ended && !isReplaying) {
        replayCurrentVideo();
      }
    });
  }

  YoutubePlayerController createController(
    String videoId, {
    required bool autoPlay,
  }) {
    return YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: autoPlay,
      params: const YoutubePlayerParams(
        showControls: false,
        showFullscreenButton: false,
        mute: false,
      ),
    );
  }

  void createPlayer(String videoId) {
    closePlayers();

    final newPlayer = createController(
      videoId,
      autoPlay: true,
    );

    player = newPlayer;
    isPlaying = true;

    listenToActivePlayer(newPlayer);

    if (mounted) {
      setState(() {});
    }

    prepareNextVideo(currentIndex);
  }

  void prepareNextVideo(int index) {
    if (!mounted) return;

    final nextIndex = index + 1;

    if (nextIndex >= videos.length) {
      return;
    }

    final nextId = videos[nextIndex]['videoId']?.toString() ?? '';

    if (nextId.isEmpty) return;
    if (standbyVideoId == nextId && standbyPlayer != null) return;

    standbyPlayer?.close();
    standbyPlayer = null;
    standbyVideoId = null;

    final preparedPlayer = createController(
      nextId,
      autoPlay: false,
    );

    standbyPlayer = preparedPlayer;
    standbyVideoId = nextId;

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> fetchVideos(String category) async {
    if (!mounted) return;

    final currentRequest = ++requestVersion;

    closePlayers();

    loadedVideoIds.clear();
    nextPageToken = null;
    hasMoreVideos = true;
    isLoadingMore = false;
    isReplaying = false;
    showPlaybackControls = false;

    setState(() {
      selectedCategory = category;
      isLoading = true;
      errorMessage = null;
      videos = [];
      currentIndex = 0;
    });

    try {
      final uri = Uri.parse('$apiBaseUrl/videos').replace(
        queryParameters: {
          'category': category,
          'language': languageCode,
        },
      );

      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.statusCode}');
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> videoList = data['videos'] ?? [];

      final result = videoList
          .map((video) => Map<String, dynamic>.from(video))
          .where((video) {
            final id = video['videoId']?.toString() ?? '';
            return id.isNotEmpty && loadedVideoIds.add(id);
          })
          .toList();

      if (result.isEmpty) {
        throw Exception('No videos found');
      }

      if (!mounted || currentRequest != requestVersion) return;

      setState(() {
        videos = result;
        nextPageToken = data['nextPageToken']?.toString();
        hasMoreVideos = nextPageToken != null;
        currentIndex = 0;
        isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || currentRequest != requestVersion) return;

        if (pageController.hasClients) {
          pageController.jumpToPage(0);
        }

        if (videos.isNotEmpty) {
          createPlayer(videos[0]['videoId'].toString());

          if (videos.length <= 5) {
            loadMoreVideos();
          }
        }
      });
    } catch (e) {
      debugPrint('FETCH VIDEO ERROR: $e');

      if (!mounted || currentRequest != requestVersion) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> loadMoreVideos() async {
    if (!mounted ||
        isLoadingMore ||
        !hasMoreVideos ||
        nextPageToken == null) {
      return;
    }

    final currentRequest = requestVersion;
    final categoryAtRequest = selectedCategory;
    final pageTokenAtRequest = nextPageToken!;

    setState(() => isLoadingMore = true);

    try {
      final uri = Uri.parse('$apiBaseUrl/videos').replace(
        queryParameters: {
          'category': categoryAtRequest,
          'language': languageCode,
          'pageToken': pageTokenAtRequest,
        },
      );

      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.statusCode}');
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> videoList = data['videos'] ?? [];

      final newVideos = videoList
          .map((video) => Map<String, dynamic>.from(video))
          .where((video) {
            final id = video['videoId']?.toString() ?? '';
            return id.isNotEmpty && loadedVideoIds.add(id);
          })
          .toList();

      if (!mounted ||
          currentRequest != requestVersion ||
          categoryAtRequest != selectedCategory) {
        return;
      }

      setState(() {
        videos.addAll(newVideos);
        nextPageToken = data['nextPageToken']?.toString();
        hasMoreVideos = nextPageToken != null;
        isLoadingMore = false;
      });

      prepareNextVideo(currentIndex);
    } catch (e) {
      debugPrint('LOAD MORE ERROR: $e');

      if (!mounted || currentRequest != requestVersion) return;

      setState(() => isLoadingMore = false);
    }
  }

  void replayCurrentVideo() {
    final currentPlayer = player;

    if (currentPlayer == null || !mounted) return;

    isReplaying = true;

    currentPlayer.seekTo(seconds: 0);
    currentPlayer.playVideo();

    isPlaying = true;

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        isReplaying = false;
      }
    });
  }

  void _playVideoAfterSwipe(
    YoutubePlayerController targetPlayer,
    String expectedVideoId,
  ) {
    // The hidden preloaded YouTube iframe can need a short moment after it is
    // attached as the active widget. Retry playVideo so the swipe always
    // starts playback once the iframe is ready.
    const retryDelays = [
      Duration(milliseconds: 250),
      Duration(milliseconds: 700),
      Duration(milliseconds: 1300),
    ];

    targetPlayer.playVideo();

    for (final delay in retryDelays) {
      Future.delayed(delay, () {
        if (!mounted ||
            !identical(player, targetPlayer) ||
            currentIndex < 0 ||
            currentIndex >= videos.length ||
            videos[currentIndex]['videoId'].toString() != expectedVideoId ||
            _subscribedRoute?.isCurrent == false ||
            WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
          return;
        }
        targetPlayer.playVideo();
      });
    }
  }

  void changeVideo(int index) {
    if (!mounted || index < 0 || index >= videos.length) return;
    if (index == currentIndex) return;

    final videoId = videos[index]['videoId'].toString();

    cancelControlsTimer();

    setState(() {
      currentIndex = index;
      isReplaying = false;
      showPlaybackControls = false;
      isPlaying = true;
    });

    if (standbyPlayer != null && standbyVideoId == videoId) {
      final oldPlayer = player;
      final newPlayer = standbyPlayer!;

      playerSubscription?.cancel();
      playerSubscription = null;

      // Stop the previous iframe before promoting the prepared iframe.
      oldPlayer?.pauseVideo();

      player = newPlayer;
      standbyPlayer = null;
      standbyVideoId = null;

      listenToActivePlayer(newPlayer);
      oldPlayer?.close();

      setState(() {});

      // Explicitly start the promoted preloaded video (it was created with
      // autoPlay:false). Retry after the widget/iframe is attached.
      _playVideoAfterSwipe(newPlayer, videoId);
      prepareNextVideo(index);
    } else {
      // Fallback: load the requested video into the current player, then
      // explicitly play it after the iframe receives the new video ID.
      final currentPlayer = player;
      if (currentPlayer != null) {
        currentPlayer.loadVideoById(videoId: videoId);
        _playVideoAfterSwipe(currentPlayer, videoId);
      } else {
        createPlayer(videoId);
      }

      setState(() {});
      prepareNextVideo(index);
    }

    if (videos.length - index <= 5) {
      loadMoreVideos();
    }
  }

  Future<void> openParentControls() async {
    // RouteAware.didPushNext pauses active + preloaded players.
    // Do not resume here: ParentLoginScreen replaces itself with the
    // ParentDashboard, so this Future may complete before the dashboard closes.
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ParentLoginScreen(),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    kidzRouteObserver.unsubscribe(this);
    _subscribedRoute = null;
    requestVersion++;

    closePlayers();
    pageController.dispose();

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.black,
      bottomNavigationBar: _KidzBottomBar(
        selectedIndex: 1,
        onHome: () => Navigator.pop(context),
        onShorts: () {},
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 55,
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'Videos load झाले नाहीत',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => fetchVideos(selectedCategory),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : videos.isEmpty || player == null
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        // Active YouTube player.
                        Positioned.fill(
                          child: YoutubePlayer(
                            key: ValueKey(
                              'active_${videos[currentIndex]['videoId']}',
                            ),
                            controller: player!,
                            aspectRatio:
                                screenSize.width / screenSize.height,
                            autoPlayWhenVisible: false,
                          ),
                        ),

                        // Hidden standby player for the next video.
                        if (standbyPlayer != null)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: Opacity(
                                opacity: 0,
                                child: YoutubePlayer(
                                  key: ValueKey(
                                    'standby_$standbyVideoId',
                                  ),
                                  controller: standbyPlayer!,
                                  aspectRatio:
                                      screenSize.width / screenSize.height,
                                  autoPlayWhenVisible: false,
                                ),
                              ),
                            ),
                          ),

                        // Vertical swipe layer.
                        Positioned.fill(
                          child: PageView.builder(
                            controller: pageController,
                            scrollDirection: Axis.vertical,
                            physics: const PageScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            itemCount: videos.length,
                            onPageChanged: changeVideo,
                            itemBuilder: (context, index) {
                              return const SizedBox.expand();
                            },
                          ),
                        ),

                        // Tap screen to show temporary playback controls.
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: showControlsTemporarily,
                            child: const SizedBox.expand(),
                          ),
                        ),

                        // Temporary play/pause button.
                        if (showPlaybackControls)
                          Center(
                            child: GestureDetector(
                              onTap: togglePlayback,
                              child: Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white70,
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 42,
                                ),
                              ),
                            ),
                          ),

                        // Top category bar.
                        SafeArea(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: SizedBox(
                              height: 50,
                              child: Row(
                                children: [
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ListView(
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      children: availableCategories.map(
                                        (category) {
                                          final selected =
                                              category == selectedCategory;

                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              right: 8,
                                            ),
                                            child: AnimatedContainer(
                                              duration: const Duration(milliseconds: 200),
                                              decoration: BoxDecoration(
                                                gradient: selected ? const LinearGradient(colors: [Color(0xFF7651E8), Color(0xFFAA78F4)]) : null,
                                                color: selected ? null : Colors.black.withValues(alpha: 0.48),
                                                borderRadius: BorderRadius.circular(22),
                                                border: Border.all(color: selected ? Colors.white.withValues(alpha: 0.9) : Colors.white24, width: selected ? 1.5 : 1),
                                                boxShadow: selected ? [BoxShadow(color: primaryColor.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4))] : null,
                                              ),
                                              child: InkWell(
                                                borderRadius: BorderRadius.circular(22),
                                                onTap: () { if (category != selectedCategory) fetchVideos(category); },
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
                                                  child: Text(category, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: selected ? FontWeight.w900 : FontWeight.w600)),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Parent controls.
                        SafeArea(
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 55,
                                right: 12,
                              ),
                              child: IconButton(
                                tooltip: 'Parent Controls',
                                onPressed: openParentControls,
                                icon: const Icon(
                                  Icons.lock_outline,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
      ),
    );
  }
}


