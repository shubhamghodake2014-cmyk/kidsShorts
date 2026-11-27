
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'firebase_options.dart';

// KidzShorts Child Profile artwork (embedded so no extra asset setup is required).
final Uint8List _childProfilePlaceholderBytes = base64Decode('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');



const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://192.168.31.92:3000',
);

const MethodChannel kidsModeChannel = MethodChannel(
  'com.example.kidz_shorts/kids_mode',
);

final RouteObserver<ModalRoute<dynamic>> kidzRouteObserver =
    RouteObserver<ModalRoute<dynamic>>();

final GlobalKey<NavigatorState> kidzNavigatorKey =
    GlobalKey<NavigatorState>();

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
      navigatorKey: kidzNavigatorKey,
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
      home: const StartupAccessibilityGate(child: AuthGate()),
    );
  }
}

// ============================================================
// STARTUP ACCESSIBILITY PERMISSION GATE
// ============================================================

class StartupAccessibilityGate extends StatefulWidget {
  final Widget child;

  const StartupAccessibilityGate({super.key, required this.child});

  @override
  State<StartupAccessibilityGate> createState() =>
      _StartupAccessibilityGateState();
}

class _StartupAccessibilityGateState extends State<StartupAccessibilityGate>
    with WidgetsBindingObserver {
  bool _promptShown = false;
  bool _checkingPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAccessibilityPermission(showPrompt: true);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // When the user returns from Android Settings, activate protection
      // automatically if the Accessibility Service was enabled.
      _checkAccessibilityPermission(showPrompt: false);
    }
  }

  Future<void> _checkAccessibilityPermission({
    required bool showPrompt,
  }) async {
    if (_checkingPermission) return;
    _checkingPermission = true;

    try {
      final serviceEnabled =
          await kidsModeChannel.invokeMethod<bool>('isAccessibilityEnabled') ??
              false;

      await kidsModeChannel.invokeMethod<void>(
        'setProtectionEnabled',
        {'enabled': serviceEnabled},
      );

      if (serviceEnabled ||
          !showPrompt ||
          !mounted ||
          _promptShown) {
        return;
      }

      _promptShown = true;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Enable Kids Mode Protection'),
            content: const Text(
              'For better Kids Mode protection, enable the KidzShorts '
              'Accessibility Service in Android Settings. This helps bring '
              'KidzShorts back if Home or another app is opened. '
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
                    debugPrint(
                      'OPEN ACCESSIBILITY SETTINGS ERROR: $e',
                    );
                  }
                },
                child: const Text('Enable Now'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      debugPrint('STARTUP ACCESSIBILITY CHECK ERROR: $e');
    } finally {
      _checkingPermission = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
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

        final childName = (data?['childName'] ?? '').toString().trim();
        final hasChildProfile =
            childName.isNotEmpty && data?['birthDate'] != null;
        final hasParentPin =
            (data?['parentPinHash'] ?? '').toString().isNotEmpty;
        final setupComplete =
            data?['setupCompleted'] == true &&
            hasChildProfile &&
            hasParentPin;

        if (!setupComplete) {
          return ParentDashboard(
            isInitialSetup: true,
            initialSettings: data,
          );
        }

        return KidsHomeScreen(
          language: data?['language'] ?? 'Marathi',
          categories: List<String>.from(
            data?['categories'] ?? ['Rhymes', 'Education'],
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

class _ParentDashboardState extends State<ParentDashboard> with WidgetsBindingObserver {
  String ageGroup = '2–4 Years';
  String language = 'Marathi';
  double screenTime = 30;
  bool noScreenTimeLimit = false;
  bool _accessibilityEnabled = false;
  bool _securityExpanded = false;
  bool _appSettingsExpanded = false;

  String childName = '';
  DateTime? birthDate;
  int avatarIndex = 0;
  String? childPhotoPath;

  final pinController = TextEditingController();
  final confirmPinController = TextEditingController();
  final currentPinController = TextEditingController();
  final newPinController = TextEditingController();
  final reenterPinController = TextEditingController();

  bool isSaving = false;
  StateSetter? _activeSubPageSetState;

  void _refreshSubPage(VoidCallback action) {
    final pageSetState = _activeSubPageSetState;
    if (pageSetState != null) {
      pageSetState(action);
    } else if (mounted) {
      setState(action);
    }
  }

  final GlobalKey _securitySectionKey = GlobalKey();
  final GlobalKey _screenTimeSectionKey = GlobalKey();
  final GlobalKey _appSettingsSectionKey = GlobalKey();

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
    WidgetsBinding.instance.addObserver(this);
    _refreshAccessibilityState();

    final data = widget.initialSettings;

    if (data != null) {
      ageGroup = data['ageGroup'] ?? ageGroup;
      language = data['language'] ?? language;
      final savedMinutes = (data['screenTimeMinutes'] ?? 30) as num;
      noScreenTimeLimit = savedMinutes == 0;
      screenTime = noScreenTimeLimit ? 30 : savedMinutes.toDouble();
      childName = data['childName'] ?? '';

      final savedDate = data['birthDate'];
      if (savedDate is Timestamp) {
        birthDate = savedDate.toDate();
      }

      avatarIndex = data['avatarIndex'] ?? 0;
      childPhotoPath = data['childPhotoPath'] as String?;

      selectedCategories
        ..clear()
        ..addAll(
          List<String>.from(
            data?['categories'] ?? ['Rhymes', 'Education'],
          ),
        );
    }

    // First-time users render App Settings as the root dashboard content.
    // Do not push a second route from initState; that can leave the welcome
    // dashboard visible behind an empty-looking page on fresh accounts.
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshAccessibilityState();
  }

  Future<void> _refreshAccessibilityState() async {
    try {
      final enabled = await kidsModeChannel.invokeMethod<bool>('isAccessibilityEnabled') ?? false;
      if (!mounted) return;
      _refreshSubPage(() => _accessibilityEnabled = enabled);
      await kidsModeChannel.invokeMethod<void>('setProtectionEnabled', {'enabled': enabled});
    } catch (e) { debugPrint('PARENT ACCESSIBILITY STATUS ERROR: $e'); }
  }

  Future<void> _enableKidsModeFromSettings() async {
    await _refreshAccessibilityState();
    if (_accessibilityEnabled) {
      showAppMessage(context, 'Kids Mode protection is enabled.');
      return;
    }
    final openSettings = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Enable Kids Mode Protection'),
        content: const Text('KidzShorts needs its Accessibility Service enabled to activate Kids Mode protection. Open Android Accessibility Settings and enable KidzShorts.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Open Settings')),
        ],
      ),
    );
    if (openSettings == true) {
      try { await kidsModeChannel.invokeMethod<void>('openAccessibilitySettings'); }
      catch (e) { debugPrint('OPEN ACCESSIBILITY SETTINGS ERROR: $e'); }
    }
  }

  Future<void> _openSecuritySettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StatefulBuilder(
          builder: (pageContext, setPageState) {
            _activeSubPageSetState = setPageState;
            return _ParentSubPage(
              title: 'Security Settings',
              subtitle: 'Manage your 4-digit Parent PIN',
              icon: Icons.shield_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sectionHeading('Change Parent PIN', 'Keep your parent account secure', Icons.lock_rounded),
                  _pinField(currentPinController, 'Current PIN', Icons.lock_outline),
                  const SizedBox(height: 12),
                  _pinField(newPinController, 'New PIN', Icons.password_rounded),
                  const SizedBox(height: 12),
                  _pinField(reenterPinController, 'Re-enter New PIN', Icons.verified_user_outlined),
                  const SizedBox(height: 18),
                  primaryButton(
                    label: 'Save Security Settings',
                    icon: Icons.save_rounded,
                    loading: isSaving,
                    onPressed: isSaving ? null : updateParentPin,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
    _activeSubPageSetState = null;
  }

  Future<void> _openAppSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StatefulBuilder(
          builder: (pageContext, setPageState) {
            _activeSubPageSetState = setPageState;
            return _ParentSubPage(
              title: 'App Settings',
              subtitle: 'Personalize your child’s experience',
              icon: Icons.settings_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KeyedSubtree(key: _screenTimeSectionKey, child: buildScreenTime()),
                  const SizedBox(height: 16),
                  buildAgeGroup(),
                  const SizedBox(height: 16),
                  buildLanguage(),
                  const SizedBox(height: 16),
                  buildCategories(),
                  const SizedBox(height: 16),
                  _buildKidsModeSwitch(),
                  if (widget.isInitialSetup) ...[
                    const SizedBox(height: 18),
                    sectionHeading('Child Profile', 'Add your child details before starting', Icons.child_friendly_rounded),
                    buildChildCard(),
                    const SizedBox(height: 18),
                    buildPinSetup(),
                  ],
                  const SizedBox(height: 20),
                  primaryButton(
                    label: widget.isInitialSetup ? 'Save & Start KidzShorts' : 'Save App Settings',
                    icon: Icons.save_rounded,
                    loading: isSaving,
                    onPressed: isSaving ? null : saveSettings,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
    _activeSubPageSetState = null;
  }

  Future<void> _openUsageReport() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const _ParentSubPage(
          title: 'Usage Report',
          subtitle: 'Your child’s screen-time overview',
          icon: Icons.bar_chart_rounded,
          child: _UsageReportContent(),
        ),
      ),
    );
  }

  Future<void> _saveChildProfileToCloud() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await parentSettingsRef(user.uid).set({
        'childName': childName.trim(),
        'birthDate': birthDate == null ? null : Timestamp.fromDate(birthDate!),
        'avatarIndex': avatarIndex,
        'childPhotoPath': childPhotoPath,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('SAVE CHILD PROFILE ERROR: $e');
      if (mounted) showAppMessage(context, 'Profile updated on this screen, but cloud save failed.');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    pinController.dispose();
    confirmPinController.dispose();
    currentPinController.dispose();
    newPinController.dispose();
    reenterPinController.dispose();
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
          initialPhotoPath: childPhotoPath,
        ),
      ),
    );

    if (result != null && mounted) {
      _refreshSubPage(() {
        childName = result['childName'];
        birthDate = result['birthDate'];
        avatarIndex = result['avatarIndex'];
        childPhotoPath = result['childPhotoPath'] as String?;
      });
      await _saveChildProfileToCloud();
      if (mounted) showAppMessage(context, 'Child Profile saved successfully.');
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

  Future<void> updateParentPin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final current = currentPinController.text.trim();
    final next = newPinController.text.trim();
    final confirm = reenterPinController.text.trim();
    if (current.length != 4 || next.length != 4 || confirm.length != 4) {
      showAppMessage(context, 'Enter all three 4-digit PIN values.');
      return;
    }
    if (next != confirm) {
      showAppMessage(context, 'New PIN and Re-enter PIN do not match.');
      return;
    }
    if (current == next) {
      showAppMessage(context, 'New PIN must be different from current PIN.');
      return;
    }
    _refreshSubPage(() => isSaving = true);
    try {
      final ref = parentSettingsRef(user.uid);
      final snapshot = await ref.get();
      final storedHash = snapshot.data()?['parentPinHash'];
      if (storedHash == null || storedHash != createPinHash(user.uid, current)) {
        showAppMessage(context, 'Current PIN is incorrect.');
        return;
      }
      await ref.set({
        'parentPinHash': createPinHash(user.uid, next),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      currentPinController.clear();
      newPinController.clear();
      reenterPinController.clear();
      if (mounted) showAppMessage(context, 'Parent PIN updated successfully.');
    } catch (e) {
      debugPrint('UPDATE PIN ERROR: $e');
      if (mounted) showAppMessage(context, 'Unable to update PIN. Please try again.');
    } finally {
      if (mounted) _refreshSubPage(() => isSaving = false);
    }
  }

  Future<void> saveSettings() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    if (widget.isInitialSetup && (childName.trim().isEmpty || birthDate == null)) {
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

    _refreshSubPage(() => isSaving = true);

    try {
      final ref = parentSettingsRef(user.uid);
      final existing = await ref.get();

      final Map<String, dynamic> settings = {
        'childName': childName.trim(),
        if (birthDate != null) 'birthDate': Timestamp.fromDate(birthDate!),
        'avatarIndex': avatarIndex,
        'childPhotoPath': childPhotoPath,
        'ageGroup': ageGroup,
        'language': language,
        'screenTimeMinutes': noScreenTimeLimit ? 0 : screenTime.toInt(),
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

      if (widget.isInitialSetup) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => KidsHomeScreen(
              language: language,
              categories: selectedCategories.toList(),
            ),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('SAVE SETTINGS ERROR: $e');
      if (mounted) {
        showAppMessage(context, 'Unable to save settings. Please try again.');
      }
    } finally {
      if (mounted) _refreshSubPage(() => isSaving = false);
    }
  }

  Future<void> _scrollToSection(GlobalKey key) async {
    final target = key.currentContext;
    if (target == null) return;
    await Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeInOutCubic,
      alignment: 0.08,
    );
  }

  Widget _animatedIcon(IconData icon, Color color, Color tint, {double size = 28}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -0.08, end: 0),
      duration: const Duration(milliseconds: 650),
      curve: Curves.elasticOut,
      builder: (context, value, child) => Transform.rotate(
        angle: value,
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, color: color, size: size),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    try {
      // Disable the Android foreground protection before leaving the account.
      try {
        await kidsModeChannel
            .invokeMethod<void>(
              'setProtectionEnabled',
              {'enabled': false},
            )
            .timeout(const Duration(seconds: 2));
      } catch (e) {
        debugPrint('DISABLE PROTECTION BEFORE LOGOUT ERROR: $e');
      }

      // Sign out first, then replace the ENTIRE app navigation stack with a
      // fresh AuthGate. This prevents the underlying Home/Shorts route or a
      // pushed Parent Dashboard route from remaining visible after logout.
      await FirebaseAuth.instance.signOut();

      final rootNavigator = kidzNavigatorKey.currentState;
      if (rootNavigator != null && rootNavigator.mounted) {
        rootNavigator.pushAndRemoveUntil<void>(
          MaterialPageRoute<void>(
            builder: (_) => const AuthGate(),
            settings: const RouteSettings(name: '/auth'),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('LOGOUT ERROR: $e');
      if (mounted) {
        showAppMessage(context, 'Logout failed. Please try again.');
      }
    }
  }

  Widget buildDashboardHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 14, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4D20D5), Color(0xFF713BEA), Color(0xFFAB78F5)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(34)),
        boxShadow: [BoxShadow(color: Color(0x444D20D5), blurRadius: 24, offset: Offset(0, 10))],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(right: 4, top: 5, child: Icon(Icons.auto_awesome_rounded, color: Colors.white.withValues(alpha: .22), size: 30)),
          Positioned(right: 105, top: 45, child: Icon(Icons.star_rounded, color: Colors.white.withValues(alpha: .18), size: 22)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17)), child: const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 36)),
                const SizedBox(width: 10),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('KidzShorts', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900, letterSpacing: -.7)),
                  Text('Happy Kids • Safe Content', style: TextStyle(color: Color(0xEFFFFFFF), fontSize: 11, fontWeight: FontWeight.w600)),
                ])),
                IconButton(onPressed: _logout, icon: const Icon(Icons.logout_rounded, color: Colors.white), tooltip: 'Logout'),
              ]),
              const SizedBox(height: 18),
              Container(
                height: 148,
                padding: const EdgeInsets.fromLTRB(17, 17, 118, 16),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: .15), borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white.withValues(alpha: .22))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('Welcome Back!', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 5),
                  const Row(children: [Text('Parent', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)), SizedBox(width: 7), Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFD34F), size: 23)]),
                  const SizedBox(height: 7),
                  Text("Your child's safe entertainment is our priority ❤️", maxLines: 2, style: TextStyle(color: Colors.white.withValues(alpha: .9), fontSize: 11, height: 1.3, fontWeight: FontWeight.w600)),
                ]),
              ),
            ],
          ),
          Positioned(right: -1, bottom: -16, child: SizedBox(width: 145, height: 172, child: Image.asset('assets/images/kidz_mascot.png', fit: BoxFit.contain))),
        ],
      ),
    );
  }

  Widget buildKidsModeStatus() {
    return Container(
      margin: const EdgeInsets.only(bottom: 17),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(color: const Color(0xFFE9FFF1), borderRadius: BorderRadius.circular(21), border: Border.all(color: const Color(0xFFBCEBCB)), boxShadow: const [BoxShadow(color: Color(0x1200A85A), blurRadius: 12, offset: Offset(0, 5))]),
      child: Row(children: [
        Container(width: 49, height: 49, decoration: const BoxDecoration(color: Color(0xFFBFF4D2), shape: BoxShape.circle), child: const Icon(Icons.verified_user_rounded, color: Color(0xFF00A95C), size: 30)),
        const SizedBox(width: 12),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Kids Mode', style: TextStyle(color: Color(0xFF164B31), fontSize: 16, fontWeight: FontWeight.w900)), SizedBox(height: 3), Text('Parent-controlled safe space', style: TextStyle(color: Color(0xFF159653), fontSize: 11, fontWeight: FontWeight.w700))])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7), decoration: BoxDecoration(color: const Color(0xFF13C875), borderRadius: BorderRadius.circular(20)), child: const Text('READY', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: .5))),
      ]),
    );
  }

  Widget _dashboardAction({required String title, required String subtitle, required IconData icon, required Color color, required Color tint, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(23),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.fromLTRB(13, 15, 10, 14),
          decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [tint, Colors.white]), borderRadius: BorderRadius.circular(23), border: Border.all(color: color.withValues(alpha: .15)), boxShadow: [BoxShadow(color: color.withValues(alpha: .08), blurRadius: 12, offset: const Offset(0, 5))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _animatedIcon(icon, color, Colors.white.withValues(alpha: .82), size: 29),
            const Spacer(),
            Text(title, style: const TextStyle(color: Color(0xFF302052), fontSize: 14, fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF6E6480), fontSize: 10, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }

  Widget buildDashboardActions() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.98,
      children: [
        _dashboardAction(title: 'Child Profile', subtitle: 'Manage your child', icon: Icons.child_friendly_rounded, color: const Color(0xFFE94D9A), tint: const Color(0xFFFFE3F0), onTap: openChildProfile),
        _dashboardAction(title: 'Security', subtitle: 'PIN settings', icon: Icons.shield_rounded, color: const Color(0xFF356DEB), tint: const Color(0xFFE1ECFF), onTap: _openSecuritySettings),
        _dashboardAction(title: 'Usage Report', subtitle: 'View screen time', icon: Icons.bar_chart_rounded, color: const Color(0xFF08A978), tint: const Color(0xFFDDF8E9), onTap: _openUsageReport),
        _dashboardAction(title: 'App Settings', subtitle: 'Customize app', icon: Icons.settings_rounded, color: const Color(0xFFEA8B13), tint: const Color(0xFFFFEBCB), onTap: _openAppSettings),
      ],
    );
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
              child: childPhotoPath != null && File(childPhotoPath!).existsSync()
                  ? ClipOval(child: Image.file(File(childPhotoPath!), fit: BoxFit.cover, width: 76, height: 76))
                  : Icon(_avatarIcon(avatarIndex), color: primaryColor, size: 48),
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
          if (!noScreenTimeLimit) Container(
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
          if (!noScreenTimeLimit) const SizedBox(height: 18),
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
                  _refreshSubPage(() { screenTime = minutes.toDouble(); noScreenTimeLimit = false; });
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
          ChoiceChip(
            label: const Text('No limit'),
            selected: noScreenTimeLimit,
            onSelected: (_) => _refreshSubPage(() => noScreenTimeLimit = true),
            selectedColor: primaryColor,
            backgroundColor: const Color(0xFFF5F2FC),
            labelStyle: TextStyle(color: noScreenTimeLimit ? Colors.white : darkColor, fontWeight: FontWeight.w800, fontSize: 12),
          ),
          if (!noScreenTimeLimit) const SizedBox(height: 14),
          if (!noScreenTimeLimit) Slider(
            value: screenTime,
            min: 15,
            max: 120,
            divisions: 21,
            activeColor: primaryColor,
            inactiveColor: const Color(0xFFEAE4F8),
            onChanged: (value) {
              _refreshSubPage(() { screenTime = value; noScreenTimeLimit = false; });
            },
          ),
          if (!noScreenTimeLimit) const Row(
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
                onTap: () => _refreshSubPage(() => ageGroup = age),
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
                  onTap: () => _refreshSubPage(() => language = name),
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
                  _refreshSubPage(() {
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

  Widget _buildKidsModeSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: _accessibilityEnabled ? const Color(0xFFE9FFF1) : const Color(0xFFFFF3E7),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _accessibilityEnabled ? const Color(0xFFBCEBCB) : const Color(0xFFFFD8B5)),
      ),
      child: Row(children: [
        Icon(Icons.shield_rounded, color: _accessibilityEnabled ? const Color(0xFF159653) : const Color(0xFFE28A28), size: 28),
        const SizedBox(width: 11),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Kids Mode Protection', style: TextStyle(fontWeight: FontWeight.w900, color: darkColor)),
          const SizedBox(height: 3),
          Text(_accessibilityEnabled ? 'Accessibility enabled • Protected' : 'Accessibility disabled • Tap to enable', style: TextStyle(fontSize: 11, color: _accessibilityEnabled ? const Color(0xFF159653) : const Color(0xFFB86A19), fontWeight: FontWeight.w700)),
        ])),
        Switch.adaptive(
          value: _accessibilityEnabled,
          onChanged: (_) async {
            if (!_accessibilityEnabled) {
              await _enableKidsModeFromSettings();
            } else {
              final openSettings = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Manage Kids Mode Protection'),
                  content: const Text('To disable Kids Mode protection, turn off the KidzShorts Accessibility Service in Android Settings.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
                    ElevatedButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Open Settings')),
                  ],
                ),
              );
              if (openSettings == true) {
                try { await kidsModeChannel.invokeMethod<void>('openAccessibilitySettings'); }
                catch (e) { debugPrint('OPEN ACCESSIBILITY SETTINGS ERROR: $e'); }
              }
            }
          },
        ),
      ]),
    );
  }

  Widget buildPinSetup() {
    if (!widget.isInitialSetup) {
      return premiumCard(
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            key: ValueKey('security-$_securityExpanded'),
            initiallyExpanded: _securityExpanded,
            onExpansionChanged: (value) => _refreshSubPage(() => _securityExpanded = value),
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(top: 8, bottom: 8),
            leading: Container(
              height: 44, width: 44,
              decoration: BoxDecoration(color: const Color(0xFFECE6FF), borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.shield_rounded, color: primaryColor),
            ),
            title: const Text('Security Settings', style: TextStyle(fontWeight: FontWeight.w900, color: darkColor)),
            subtitle: const Text('Change your 4-digit Parent PIN', style: TextStyle(fontSize: 12)),
            children: [
              _pinField(currentPinController, 'Current PIN', Icons.lock_outline),
              const SizedBox(height: 12),
              _pinField(newPinController, 'New PIN', Icons.password_rounded),
              const SizedBox(height: 12),
              _pinField(reenterPinController, 'Re-enter New PIN', Icons.verified_user_outlined),
              const SizedBox(height: 14),
              SizedBox(width: double.infinity, child: ElevatedButton.icon(
                onPressed: isSaving ? null : updateParentPin,
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: const Text('Update PIN', style: TextStyle(fontWeight: FontWeight.w800)),
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              )),
            ],
          ),
        ),
      );
    }
    return premiumCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        sectionHeading('Create Parent PIN', 'Protect parent settings with a 4-digit PIN', Icons.shield_rounded),
        _pinField(pinController, 'Create 4-digit PIN', Icons.lock_outline),
        const SizedBox(height: 12),
        _pinField(confirmPinController, 'Confirm 4-digit PIN', Icons.verified_user_outlined),
      ]),
    );
  }

  Widget _pinField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      obscureText: true,
      maxLength: 4,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        counterText: '',
        filled: true,
        fillColor: const Color(0xFFFAF9FD),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isInitialSetup) {
      return _ParentSubPage(
        title: 'App Settings',
        subtitle: 'Complete your child’s profile to get started',
        icon: Icons.settings_rounded,
        actions: [
          IconButton(
            onPressed: _logout,
            tooltip: 'Logout',
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildScreenTime(),
            const SizedBox(height: 16),
            buildAgeGroup(),
            const SizedBox(height: 16),
            buildLanguage(),
            const SizedBox(height: 16),
            buildCategories(),
            const SizedBox(height: 16),
            _buildKidsModeSwitch(),
            const SizedBox(height: 18),
            sectionHeading(
              'Child Profile',
              'Add your child details before starting',
              Icons.child_friendly_rounded,
            ),
            buildChildCard(),
            const SizedBox(height: 18),
            buildPinSetup(),
            const SizedBox(height: 20),
            primaryButton(
              label: 'Save & Start KidzShorts',
              icon: Icons.save_rounded,
              loading: isSaving,
              onPressed: isSaving ? null : saveSettings,
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            buildDashboardHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(17, 19, 17, 25),
                children: [
                  if (widget.isInitialSetup) ...[
                    Container(
                      padding: const EdgeInsets.all(15),
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE5FF),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Text(
                        'Welcome! Start with App Settings to personalize KidzShorts for your child.',
                        style: TextStyle(color: Color(0xFF4B2B9A), fontWeight: FontWeight.w800),
                      ),
                    ),
                    _dashboardAction(
                      title: 'App Settings',
                      subtitle: 'Complete your first setup',
                      icon: Icons.settings_rounded,
                      color: const Color(0xFFEA8B13),
                      tint: const Color(0xFFFFEBCB),
                      onTap: _openAppSettings,
                    ),
                  ] else ...[
                    buildKidsModeStatus(),
                    buildDashboardActions(),
                    const SizedBox(height: 20),
                  ],
                  if (!widget.isInitialSetup) ...[
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
                        label: const Text('Preview Kids Feed', style: TextStyle(fontWeight: FontWeight.w800)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          side: const BorderSide(color: primaryColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                        label: const Text('Exit Kids Mode', style: TextStyle(fontWeight: FontWeight.w800)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Made with ❤️ for little explorers',
                      style: TextStyle(color: Colors.black38, fontSize: 11),
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
// PARENT SETTINGS SUB-PAGES
// ============================================================

class _ParentSubPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  final List<Widget>? actions;

  const _ParentSubPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        actions: actions,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF6842D8), Color(0xFFAD85F4)]),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: .2), borderRadius: BorderRadius.circular(17)),
                      child: Icon(icon, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 4),
                          Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _UsageReportContent extends StatelessWidget {
  const _UsageReportContent();

  @override
  Widget build(BuildContext context) {
    return premiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionHeading('Usage Report', 'Screen-time report will appear here', Icons.bar_chart_rounded),
          const Text(
            'Usage tracking is currently unchanged. Your existing screen-time settings remain available under App Settings.',
            style: TextStyle(color: Colors.black54, height: 1.5),
          ),
        ],
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
  final String? initialPhotoPath;

  const ChildProfileScreen({
    super.key,
    this.initialName = '',
    this.initialBirthDate,
    this.initialAvatar = 0,
    this.initialPhotoPath,
  });

  @override
  State<ChildProfileScreen> createState() => _ChildProfileScreenState();
}

class _ChildProfileScreenState extends State<ChildProfileScreen> {
  final nameController = TextEditingController();
  final ImagePicker imagePicker = ImagePicker();

  DateTime? birthDate;
  int selectedAvatar = 5;
  String? photoPath;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.initialName;
    birthDate = widget.initialBirthDate;
    selectedAvatar = widget.initialAvatar;
    photoPath = widget.initialPhotoPath;
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
      initialDate: birthDate ?? DateTime(now.year - 3, now.month, now.day),
      firstDate: DateTime(2010),
      lastDate: now,
      helpText: 'Select Child Date of Birth',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF7615E8),
            primary: const Color(0xFF7615E8),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => birthDate = picked);
  }

  Future<void> choosePhoto(ImageSource source) async {
    try {
      final picked = await imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (picked == null) return;
      final appDir = await getApplicationDocumentsDirectory();
      final extension =
          picked.path.contains('.') ? picked.path.split('.').last : 'jpg';
      final destination =
          '${appDir.path}/child_profile_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final saved = await File(picked.path).copy(destination);
      if (!mounted) return;
      setState(() => photoPath = saved.path);
    } catch (e) {
      debugPrint('CHILD PHOTO PICK ERROR: $e');
      if (mounted) {
        showAppMessage(context, 'Unable to select photo. Please try again.');
      }
    }
  }

  Future<void> showPhotoOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add Child Photo',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF321078),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded,
                    color: Color(0xFF7615E8)),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  choosePhoto(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded,
                    color: Color(0xFF7615E8)),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  choosePhoto(ImageSource.camera);
                },
              ),
              if (photoPath != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded,
                      color: Colors.redAccent),
                  title: const Text('Remove Photo'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    setState(() => photoPath = null);
                  },
                ),
            ],
          ),
        ),
      ),
    );
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
      'childPhotoPath': photoPath,
    });
  }

  Widget _cloudBubble({required Widget child}) {
    const cloudWhite = Color(0xFFFFFCFF);
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 138),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
          decoration: BoxDecoration(
            color: cloudWhite,
            borderRadius: BorderRadius.circular(48),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3D087F).withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Center(child: child),
        ),
        Positioned(
          top: -8,
          left: 27,
          child: IgnorePointer(
            child: Container(
              width: 54,
              height: 48,
              decoration: const BoxDecoration(
                color: cloudWhite,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        Positioned(
          top: -13,
          right: 25,
          child: IgnorePointer(
            child: Container(
              width: 62,
              height: 55,
              decoration: const BoxDecoration(
                color: cloudWhite,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        Positioned(
          right: -7,
          top: 33,
          child: IgnorePointer(
            child: Container(
              width: 38,
              height: 52,
              decoration: const BoxDecoration(
                color: cloudWhite,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(
    IconData icon,
    String label,
    double scale,
) {
    return Row(
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: label == 'Date of Birth'
                  ? const [Color(0xFFFFA63D), Color(0xFFFF5C9A)]
                  : const [Color(0xFF46C8F5), Color(0xFF8060F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: (label == 'Date of Birth'
                        ? const Color(0xFFFF7B86)
                        : const Color(0xFF8060F5))
                    .withValues(alpha: 0.22),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 25,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF321078),
            fontSize: 17 * scale,
fontWeight: FontWeight.w800,
letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoPath != null && File(photoPath!).existsSync();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;

    final uiScale = (screenWidth / 400)
    .clamp(0.86, 1.08)
    .toDouble();

final isShortScreen = screenHeight < 760;

    return Scaffold(
      backgroundColor: const Color(0xFFF7E8FF),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF7130F4),
              Color(0xFF9D55F5),
              Color(0xFFF9DDFB),
              Color(0xFFFFF4FF),
            ],
            stops: [0.0, 0.34, 0.73, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 185,
                left: -38,
                child: _decorativeCloud(110, const Color(0xFFCE9BFF)),
              ),
              Positioned(
                top: 235,
                right: -48,
                child: _decorativeCloud(145, const Color(0xFFFFC6F0)),
              ),
              Positioned(
                top: 150,
                right: -34,
                child: IgnorePointer(
                  child: CustomPaint(
                    size: const Size(205, 170),
                    painter: _ProfileRainbowPainter(),
                  ),
                ),
              ),
              Positioned(
                bottom: -38,
                left: -42,
                child: _decorativeCloud(130, const Color(0xFFD7B5FF)),
              ),
              Positioned(
                bottom: -35,
                right: -48,
                child: _decorativeCloud(150, const Color(0xFFE2C0FF)),
              ),
              Column(
                children: [
                  // Brand header recreated with Flutter widgets (not the reference screenshot).
                  SizedBox(
                    width: double.infinity,
                    height: screenWidth < 390 ? 104 : 116,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          left: 9,
                          top: 8,
                          child: Material(
                            color: Colors.white.withValues(alpha: 0.94),
                            shape: const CircleBorder(),
                            elevation: 3,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => Navigator.pop(context),
                              child: const SizedBox(
                                width: 42,
                                height: 42,
                                child: Icon(
                                  Icons.arrow_back_rounded,
                                  color: Color(0xFF5D12D8),
                                  size: 25,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: screenWidth < 390 ? 43 : 48,
                            right: 8,
                            top: 5,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: screenWidth < 390 ? 35 : 40,
                                      height: screenWidth < 390 ? 35 : 40,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF3F8E),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x553C087D),
                                            blurRadius: 7,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.play_arrow_rounded,
                                        color: Colors.white,
                                        size: 31,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Kidz',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: screenWidth < 390 ? 30 : 35,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: -1.1,
                                              shadows: const [
                                                Shadow(color: Color(0x66300075), blurRadius: 5, offset: Offset(0, 2)),
                                              ],
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Shorts',
                                            style: TextStyle(
                                              color: const Color(0xFFFFD52E),
                                              fontSize: screenWidth < 390 ? 30 : 35,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: -1.1,
                                              shadows: const [
                                                Shadow(color: Color(0x66300075), blurRadius: 5, offset: Offset(0, 2)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 3),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Little Smiles, Safe Entertainment!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth < 390 ? 13 : 15,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.05,
                                    shadows: const [
                                      Shadow(color: Color(0x55300075), blurRadius: 4, offset: Offset(0, 1)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: screenWidth < 390 ? 174 : 190,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Image.asset(
                              'assets/images/child_girl.png',
                              fit: BoxFit.contain,
                              height: screenWidth < 390 ? 166 : 188,
                              alignment: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 7, 13, 10),
                            child: Center(
                              child: _cloudBubble(
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final compact = constraints.maxWidth < 175;
                                    final titleSize = (constraints.maxWidth * 0.125)
                                        .clamp(16.0, 21.0)
                                        .toDouble();
                                    final subtitleSize = (constraints.maxWidth * 0.067)
                                        .clamp(9.5, 11.5)
                                        .toDouble();
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            'Create Your\nChild Profile',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: const Color(0xFF4D10C7),
                                              fontSize: titleSize,
                                              height: 1.02,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: -0.45,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: compact ? 4 : 6),
                                        Text(
                                          'Let’s personalize your child’s experience! 💗',
                                          textAlign: TextAlign.center,
                                          softWrap: true,
                                          style: TextStyle(
                                            color: const Color(0xFF5C3A9D),
                                            fontSize: subtitleSize,
                                            height: 1.15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFCFF).withValues(alpha: 0.97),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(48),
                        ),
                        border: Border.all(
                            color: const Color(0xFFE6BFFF), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5B19B2)
                                .withValues(alpha: 0.12),
                            blurRadius: 18,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 2),
                            hasPhoto
                                ? Stack(
                                    clipBehavior: Clip.none,
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 154,
                                        height: 154,
                                        padding: const EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: const Color(0xFFB56AFF),
                                            width: 2,
                                          ),
                                          color: const Color(0xFFF0DFFF),
                                        ),
                                        child: ClipOval(
                                          child: Image.file(
                                            File(photoPath!),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: -10,
                                        bottom: 3,
                                        child: Material(
                                          color: const Color(0xFF7615E8),
                                          shape: const CircleBorder(),
                                          elevation: 5,
                                          child: InkWell(
                                            customBorder: const CircleBorder(),
                                            onTap: showPhotoOptions,
                                            child: const Padding(
                                              padding: EdgeInsets.all(13),
                                              child: Icon(
                                                Icons.camera_alt_rounded,
                                                color: Colors.white,
                                                size: 27,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                 : InkWell(
    onTap: showPhotoOptions,
    child: Container(
      width: 154,
      height: 154,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFD7EE),
            Color(0xFFE5D8FF),
            Color(0xFFD7F2FF),
          ],
        ),
        border: Border.all(
          color: Colors.white,
          width: 5,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF8B5CF6).withOpacity(0.18),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 19,
            right: 25,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFFFFB43B),
              size: 21,
            ),
          ),
          Positioned(
            bottom: 23,
            left: 22,
            child: Icon(
              Icons.favorite_rounded,
              color: Color(0xFFFF8FC4),
              size: 17,
            ),
          ),
          Icon(
            Icons.face_3_rounded,
            color: Color(0xFF8554C7),
            size: 91,
          ),
        ],
      ),
    ),
  ),
                            const SizedBox(height: 15),
                            TextButton(
                              onPressed: showPhotoOptions,
                              child: Text(
                                'Add Profile Photo',
                                style: TextStyle(
                                  color: const Color(0xFF4B0DB5),
                                  fontSize: 15 * uiScale,
fontWeight: FontWeight.w800,
letterSpacing: 0.05,
                                ),
                              ),
                            ),
                            const SizedBox(height: 13),
                            _fieldLabel(
  Icons.child_care_rounded,
  'Child Name',
  uiScale,
),
                            const SizedBox(height: 8),
                            TextField(
                              controller: nameController,
                              textCapitalization: TextCapitalization.words,
                              style: TextStyle(
                                color: const Color(0xFF321078),
                                fontSize: 15.5 * uiScale,
                                fontWeight: FontWeight.w700,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter child name',
                                hintStyle: TextStyle(
                                  color: const Color(0xFF9182B4),
                                  fontSize: 15.5 * uiScale,
                                  fontWeight: FontWeight.w600,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 22, vertical: 19),
                                filled: true,
                                fillColor: const Color(0xFFFFFCFF),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFDCC2FF), width: 2),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF9A43F4), width: 2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 21),
                            _fieldLabel(
  Icons.calendar_month_rounded,
  'Date of Birth',
  uiScale,
),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: selectBirthDate,
                              borderRadius: BorderRadius.circular(40),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 22, vertical: 19),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFCFF),
                                  borderRadius: BorderRadius.circular(40),
                                  border: Border.all(
                                      color: const Color(0xFFDCC2FF),
                                      width: 2),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        birthDate == null
                                            ? 'Select Date of Birth'
                                            : '${birthDate!.day.toString().padLeft(2, '0')}/${birthDate!.month.toString().padLeft(2, '0')}/${birthDate!.year}',
                                        style: TextStyle(
                                          color: birthDate == null
                                              ? const Color(0xFF9182B4)
                                              : const Color(0xFF321078),
                                          fontSize: 15 * uiScale,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.keyboard_arrow_down_rounded,
                                        color: Color(0xFF4B0DB5), size: 30),
                                  ],
                                ),
                              ),
                            ),
                            if (birthDate != null) ...[
                              const SizedBox(height: 9),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Age: ${calculateAge(birthDate!)} years',
                                  style: const TextStyle(
                                    color: Color(0xFF7040B4),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: isShortScreen ? 52 : 56,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFD526E8),
                                      Color(0xFF6E12E9),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(40),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6E12E9)
                                          .withValues(alpha: 0.27),
                                      blurRadius: 13,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: saveProfile,
                                  icon: Icon(
                                    Icons.check_rounded,
                                    size: 23 * uiScale,
                                  ),
                                  label: Text(
                                    'Save Profile',
                                    style: TextStyle(
                                      fontSize: 17.5 * uiScale,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.15,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: const StadiumBorder(),
                                  ),
                                )
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _decorativeCloud(double size, Color color) {
    return Container(
      width: size,
      height: size * 0.62,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(size),
      ),
    );
  }
}


class _ProfileRainbowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      -size.width * 0.08,
      size.height * 0.16,
      size.width * 1.18,
      size.height * 1.55,
    );
    final colors = [
      const Color(0xFFFF6D9F),
      const Color(0xFFFFC84A),
      const Color(0xFF75D66B),
      const Color(0xFF55C9F5),
      const Color(0xFF9C72F4),
    ];
    for (var i = 0; i < colors.length; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..isAntiAlias = true;
      final inset = i * 16.0;
      canvas.drawArc(
        Rect.fromLTWH(
          rect.left + inset,
          rect.top + inset,
          rect.width - inset * 2,
          rect.height - inset * 2,
        ),
        3.42,
        2.05,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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



class _ShortActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ShortActionButton({required this.icon, required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.42),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.22), blurRadius: 10)],
          ),
          child: Icon(icon, color: color, size: 25),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, shadows: [Shadow(color: Colors.black, blurRadius: 5)])),
      ],
    ),
  );
}

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
  bool _isLiked = false;
  bool _isSaved = false;

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
      _activateKidsModeProtection(showPermissionPrompt: false);
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
      _isLiked = false;
      _isSaved = false;
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
        backgroundColor: const Color(0xFF09090D),
        bottomNavigationBar: _KidzBottomBar(
          selectedIndex: 1,
          onHome: () => Navigator.pop(context),
          onShorts: () {},
        ),
        body: Column(
          children: [
            // Header is kept OUTSIDE the video viewport so it never covers
            // YouTube's own title overlay or the video content.
            Container(
              color: const Color(0xFF111116),
              padding: const EdgeInsets.fromLTRB(14, 7, 12, 7),
              child: SafeArea(
                bottom: false,
                child: SizedBox(
                  height: 43,
                  child: Row(
                    children: [
                      Container(
                        width: 37,
                        height: 37,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF4F91), Color(0xFF7651E8)],
                          ),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 9),
                      const Text(
                        'KidzShorts',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD45E),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Text(
                          'SHORTS',
                          style: TextStyle(
                            color: Color(0xFF39264F),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Material(
                        color: const Color(0xFF292936),
                        shape: const CircleBorder(),
                        child: IconButton(
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Parent Controls',
                          onPressed: openParentControls,
                          icon: const Icon(
                            Icons.lock_rounded,
                            color: Colors.white,
                            size: 19,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Category chips have their own row, not layered over the player.
            Container(
              height: 54,
              color: const Color(0xFF111116),
              alignment: Alignment.centerLeft,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                children: availableCategories.map((category) {
                  final selected = category == selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 9),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        gradient: selected
                            ? const LinearGradient(
                                colors: [
                                  Color(0xFFFFD45E),
                                  Color(0xFFFFA94D),
                                ],
                              )
                            : null,
                        color: selected ? null : const Color(0xFF30303A),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: selected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.14),
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: () {
                          if (!selected) fetchVideos(category);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: selected
                                  ? const Color(0xFF39264F)
                                  : Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // The player and all overlays are constrained to this area only.
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFFD45E),
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
                                  size: 48,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Videos load झाले नाहीत',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () =>
                                      fetchVideos(selectedCategory),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : videos.isEmpty || player == null
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFFFD45E),
                              ),
                            )
                          : Stack(
                              fit: StackFit.expand,
                              children: [
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

                                Positioned.fill(
                                  child: PageView.builder(
                                    controller: pageController,
                                    scrollDirection: Axis.vertical,
                                    physics: const PageScrollPhysics(
                                      parent: BouncingScrollPhysics(),
                                    ),
                                    itemCount: videos.length,
                                    onPageChanged: changeVideo,
                                    itemBuilder: (_, __) =>
                                        const SizedBox.expand(),
                                  ),
                                ),

                                Positioned.fill(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: showControlsTemporarily,
                                    child: const SizedBox.expand(),
                                  ),
                                ),

                                // Bottom fade is limited to the video viewport.
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  height: 205,
                                  child: IgnorePointer(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withValues(alpha: 0.38),
                                            Colors.black.withValues(alpha: 0.86),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                if (showPlaybackControls)
                                  Center(
                                    child: GestureDetector(
                                      onTap: togglePlayback,
                                      child: Container(
                                        width: 66,
                                        height: 66,
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
                                              ? Icons.pause_rounded
                                              : Icons.play_arrow_rounded,
                                          color: Colors.white,
                                          size: 42,
                                        ),
                                      ),
                                    ),
                                  ),

                                // Action rail sits above the details and bottom bar.
                                Positioned(
                                  right: 10,
                                  bottom: 150,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _ShortActionButton(
                                        icon: _isLiked
                                            ? Icons.favorite_rounded
                                            : Icons.favorite_border_rounded,
                                        label: _isLiked ? 'Liked' : 'Like',
                                        color: _isLiked
                                            ? const Color(0xFFFF5B8A)
                                            : Colors.white,
                                        onTap: () => setState(
                                          () => _isLiked = !_isLiked,
                                        ),
                                      ),
                                      const SizedBox(height: 13),
                                      _ShortActionButton(
                                        icon: _isSaved
                                            ? Icons.bookmark_rounded
                                            : Icons.bookmark_border_rounded,
                                        label: _isSaved ? 'Saved' : 'Save',
                                        color: _isSaved
                                            ? const Color(0xFFFFD45E)
                                            : Colors.white,
                                        onTap: () => setState(
                                          () => _isSaved = !_isSaved,
                                        ),
                                      ),
                                      const SizedBox(height: 13),
                                      const _ShortActionButton(
                                        icon: Icons.swipe_up_rounded,
                                        label: 'Next',
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),

                                // Details are kept compact and clear of the action rail.
                                Positioned(
                                  left: 14,
                                  right: 82,
                                  bottom: 20,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF7651E8),
                                              Color(0xFFFF4F91),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(18),
                                        ),
                                        child: Text(
                                          '✨ ${videos[currentIndex]['category'] ?? selectedCategory}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 7),
                                      Text(
                                        videos[currentIndex]['title']
                                                ?.toString() ??
                                            'Fun video for little explorers!',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          height: 1.15,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black87,
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.verified_rounded,
                                            color: Color(0xFFFFD45E),
                                            size: 13,
                                          ),
                                          const SizedBox(width: 5),
                                          Expanded(
                                            child: Text(
                                              videos[currentIndex]['channelTitle']
                                                      ?.toString() ??
                                                  'KidzShorts',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
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
