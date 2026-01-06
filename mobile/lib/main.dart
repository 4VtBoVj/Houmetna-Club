import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode, defaultTargetPlatform, TargetPlatform;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'firebase_options.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');

    // Point to local emulators in debug builds
    if (kDebugMode) {
      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;
      final functions = FirebaseFunctions.instance;

      // Host per platform
      final host = kIsWeb
          ? '127.0.0.1' // Chrome hitting local emulators
          : (defaultTargetPlatform == TargetPlatform.android
              ? '10.0.2.2' // Android emulator to host machine
              : 'localhost');

      auth.useAuthEmulator(host, 9099);
      firestore.useFirestoreEmulator(host, 8080);
      functions.useFunctionsEmulator(host, 5001);
      print('🔗 Using emulators at $host (auth 9099, firestore 8080, functions 5001)');
    }
  } catch (e) {
    print('❌ Firebase init error: $e');
    print('⚠️ Running without Firebase - check your google-services.json');
  }
  runApp(const HoumetnaClubApp());
}

class HoumetnaClubApp extends StatelessWidget {
  const HoumetnaClubApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Houmetna Club',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: StreamBuilder(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Reload
                        (context as Element).reassemble();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          
          if (snapshot.hasData && snapshot.data != null) {
            return const HomePage();
          }
          
          return const LoginPage();
        },
      ),
    );
  }
}
