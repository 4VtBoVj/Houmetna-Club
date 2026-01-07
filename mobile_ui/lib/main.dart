import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'firebase_options.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/report_creation_screen.dart';
import 'screens/map_view_screen.dart';
import 'screens/report_details_screen.dart';
import 'screens/my_reports_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/municipality_dashboard_screen.dart';
import 'services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/notifications_screen.dart';

Future<void> _initFirebase() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final useEmulators =
      const String.fromEnvironment('USE_EMULATORS', defaultValue: 'true') ==
          'true';
  if (useEmulators) {
    final host = kIsWeb
        ? '127.0.0.1'
        : (defaultTargetPlatform == TargetPlatform.android
            ? '10.0.2.2'
            : 'localhost');
    try {
      await FirebaseAuth.instance.useAuthEmulator(host, 9099);
      FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
      FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
      FirebaseStorage.instance.useStorageEmulator(host, 9199);
      // Optional: Set region explicitly if needed
      // FirebaseFunctions.instanceFor(region: 'us-central1').useFunctionsEmulator(host, 5001);
      // print to console for clarity
      // ignore: avoid_print
      print('Firebase emulators enabled @ $host');
    } catch (_) {}
  } else {
    // ignore: avoid_print
    print('Firebase running in PRODUCTION');
  }
}

void main() async {
  await _initFirebase();
  runApp(const HoumetnaApp());
}

enum AppScreen {
  onboarding,
  login,
  signup,
  home,
  reportCreation,
  map,
  reportDetails,
  notifications,
  myReports,
  profile,
  municipality,
}

class HoumetnaApp extends StatefulWidget {
  const HoumetnaApp({super.key});

  @override
  State<HoumetnaApp> createState() => _HoumetnaAppState();
}

class _HoumetnaAppState extends State<HoumetnaApp> {
  AppScreen current = AppScreen.onboarding;
  String? selectedReportId;
  String userRole = 'user'; // Track user role
  final _authService = AuthService();

  void go(AppScreen screen) {
    setState(() => current = screen);
  }

  void openReport(String id) {
    setState(() {
      selectedReportId = id;
      current = AppScreen.reportDetails;
    });
  }

  Future<void> _updateUserRole() async {
    final role = await _authService.getUserRole();
    setState(() => userRole = role);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1F75FF),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F7FB),
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      useMaterial3: true,
    );

    Widget body;
    switch (current) {
      case AppScreen.onboarding:
        body = OnboardingScreen(onComplete: () => go(AppScreen.login));
        break;
      case AppScreen.login:
        body = LoginScreen(
          onLogin: () {
            _updateUserRole();
            go(AppScreen.home);
          },
          onSignup: () => go(AppScreen.signup),
          onForgot: () {},
        );
        break;
      case AppScreen.signup:
        body = SignupScreen(
          onBack: () => go(AppScreen.login),
          onSignedUp: () async {
            // After creating an account the SDK signs the user in automatically.
            // Sign them out and return to the login screen so they must explicitly
            // sign in with the credentials they just created.
            await _authService.signOut();
            go(AppScreen.login);
          },
        );
        break;
      case AppScreen.home:
        body = HomeScreen(
          onNavigate: (s) => go(s),
          onReportDetails: (id) => openReport(id),
          userRole: userRole,
        );
        break;
      case AppScreen.reportCreation:
        body = ReportCreationScreen(
          onBack: () => go(AppScreen.home),
          onSubmit: () => go(AppScreen.myReports),
        );
        break;
      case AppScreen.map:
        body = MapViewScreen(
          onBack: () => go(AppScreen.home),
          onReportTap: (id) => openReport(id),
        );
        break;
      case AppScreen.reportDetails:
        body = ReportDetailsScreen(
          onBack: () => go(AppScreen.myReports),
          reportId: selectedReportId,
        );
        break;
      case AppScreen.notifications:
        body = NotificationsScreen(onBack: () => go(AppScreen.home));
        break;
      case AppScreen.myReports:
        body = MyReportsScreen(
          onBack: () => go(AppScreen.home),
          onReportTap: (id) => openReport(id),
        );
        break;
      case AppScreen.profile:
        body = ProfileScreen(
          onBack: () => go(AppScreen.home),
          onLogout: () => go(AppScreen.login),
        );
        break;
      case AppScreen.municipality:
        body = MunicipalityDashboardScreen(
          onBack: () => go(AppScreen.home),
          onReportTap: () => go(AppScreen.reportDetails),
        );
        break;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: body,
          ),
        ),
      ),
    );
  }
}
