import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawfect_care/pages/common/splash_screen.dart';

import 'package:pawfect_care/utils/theme.dart';
import 'package:pawfect_care/utils/firebase_options.dart';

import 'package:pawfect_care/controllers/admin_page_controller.dart';
import 'package:pawfect_care/controllers/shelter_page_controller.dart';
import 'package:pawfect_care/controllers/store_page_controller.dart';
import 'package:pawfect_care/controllers/user_page_controller.dart';
import 'package:pawfect_care/controllers/vet_page_controller.dart';

import 'package:pawfect_care/pages/common/signin_page.dart';
import 'package:pawfect_care/pages/common/signup_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PawfectCare',
      initialRoute: '/',
      routes: {
        '/signin': (context) => const SigninPage(),
        '/signup': (context) => const SignupPage(),
      },
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
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
          return const SplashScreen();
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
                return const SplashScreen();
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
