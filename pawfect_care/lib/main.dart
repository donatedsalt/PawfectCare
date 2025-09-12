import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pawfect_care/utils/firebase_options.dart';

import 'package:pawfect_care/controllers/admin_page_controller.dart';
import 'package:pawfect_care/controllers/shelter_page_controller.dart';
import 'package:pawfect_care/controllers/store_page_controller.dart';
import 'package:pawfect_care/controllers/user_page_controller.dart';
import 'package:pawfect_care/controllers/vet_page_controller.dart';

import 'package:pawfect_care/pages/common/loading_screen.dart';
import 'package:pawfect_care/pages/common/signin_page.dart';
import 'package:pawfect_care/pages/common/signup_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

final customColorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF0D1C5A),
);

final theme = ThemeData(
  colorScheme: customColorScheme,
  useMaterial3: true,
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: customColorScheme.primary,
    indicatorColor: customColorScheme.onPrimary.withAlpha(40),
    iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
      if (states.contains(WidgetState.selected)) {
        return IconThemeData(color: customColorScheme.onPrimary, size: 28);
      }
      return IconThemeData(color: customColorScheme.onPrimary, size: 24);
    }),
    labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
      if (states.contains(WidgetState.selected)) {
        return TextStyle(
          color: customColorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        );
      }
      return TextStyle(color: customColorScheme.onPrimary);
    }),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: customColorScheme.primary,
    foregroundColor: customColorScheme.onPrimary,
  ),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/signin': (context) => const SigninPage(),
        '/signup': (context) => const SignupPage(),
      },
      debugShowCheckedModeBanner: false,
      title: 'PawfectCare',
      theme: theme,
      home: const AuthGate(),
    );
  }
}

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
        if (snapshot.data == null) {
          return const SigninPage();
        } else {
          final user = snapshot.data!;
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const LoadingScreen();
              }
              if (roleSnapshot.hasData) {
                final userRole = roleSnapshot.data!.get('role');
                switch (userRole) {
                  case 'user':
                    return const UserPageController();
                  case 'veterinarian':
                    return const VetPageController();
                  case 'pet store':
                    return const StorePageController();
                  case 'animal shelter':
                    return const ShelterPageController();
                  case 'admin':
                    return const AdminPageController();
                  default:
                    return const UserPageController();
                }
              }
              return const SigninPage();
            },
          );
        }
      },
    );
  }
}
