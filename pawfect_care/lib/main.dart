import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pawfect_care/utils/theme.dart';
import 'package:pawfect_care/utils/firebase_options.dart';

import 'package:pawfect_care/controllers/admin_page_controller.dart';
import 'package:pawfect_care/controllers/shelter_page_controller.dart';
import 'package:pawfect_care/controllers/store_page_controller.dart';
import 'package:pawfect_care/controllers/user_page_controller.dart';
import 'package:pawfect_care/controllers/vet_page_controller.dart';

import 'package:pawfect_care/pages/common/complete_profile_page.dart';
import 'package:pawfect_care/pages/common/splash_screen.dart';
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
        '/completeProfile': (context) => const CompleteProfilePage(),
      },
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}

class Roles {
  static const user = "user";
  static const vet = "veterinarian";
  static const store = "pet store";
  static const shelter = "animal shelter";
  static const admin = "admin";
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
        }

        final user = snapshot.data!;
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const LoadingWidget();
            }
            if (roleSnapshot.hasError) {
              return const Scaffold(
                body: Center(child: Text("Error fetching user role")),
              );
            }

            if (!roleSnapshot.hasData || !roleSnapshot.data!.exists) {
              FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                "uid": user.uid,
                "email": user.email,
                "name": user.displayName ?? "",
                "role": Roles.user,
                "createdAt": FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));

              return const UserPageController();
            }

            final userRole = roleSnapshot.data!.get('role');

            switch (userRole) {
              case Roles.user:
                return const UserPageController();
              case Roles.vet:
                return const VetPageController();
              case Roles.store:
                return const StorePageController();
              case Roles.shelter:
                return const ShelterPageController();
              case Roles.admin:
                return const AdminPageController();
              default:
                return const UserPageController();
            }
          },
        );
      },
    );
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        "937488511257-7i38ca1nb845skefudu9ohdnk4t98pu1.apps.googleusercontent.com",
  );

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      if (kDebugMode) {
        print("Google Sign-In Error: $e");
      }
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
