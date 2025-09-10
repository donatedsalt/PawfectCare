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

final theme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  useMaterial3: true,
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
      title: 'Trip Budgeter',
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
                  case 'vet':
                    return const VetPageController();
                  case 'store':
                    return const StorePageController();
                  case 'shelter':
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
