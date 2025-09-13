import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pawfect_care/utils/context_extension.dart';
import 'package:pawfect_care/widgets/custom_app_bar.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _isLoading = false;
  bool _obscurePassword = true;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  String? _selectedRole;
  final List<String> _roles = [
    'user',
    'veterinarian',
    'animal shelter',
    'pet store',
  ];
  late List<bool> _isSelected;

  @override
  void initState() {
    super.initState();
    _isSelected = List.filled(_roles.length, false);
  }

  Future<void> _signUpWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    int selectedIndex = _isSelected.indexOf(true);
    if (selectedIndex != -1) {
      _selectedRole = _roles[selectedIndex];
    } else {
      context.showSnackBar('Please select a role.', theme: SnackBarTheme.error);
      return;
    }

    try {
      setState(() => _isLoading = true);

      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      await userCredential.user!.updateDisplayName(
        _usernameController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'name': _usernameController.text.trim(),
            'email': _emailController.text.trim(),
            'role': _selectedRole,
            'createdAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        context.showSnackBar(
          'Sign up successful!',
          theme: SnackBarTheme.success,
        );
        _emailController.clear();
        _usernameController.clear();
        _passwordController.clear();
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists for that email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        default:
          errorMessage = 'An error occurred. Please try again.';
      }
      if (mounted) {
        context.showSnackBar(errorMessage, theme: SnackBarTheme.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Google Sign-In
  Future<void> _signUpWithGoogle() async {
    try {
      setState(() => _isLoading = true);

      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        clientId:
            "937488511257-7i38ca1nb845skefudu9ohdnk4t98pu1.apps.googleusercontent.com",
      ).signIn();

      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        // Default role "user" for Google signup
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
              'name': userCredential.user!.displayName ?? 'User',
              'email': userCredential.user!.email,
              'role': 'user',
              'createdAt': FieldValue.serverTimestamp(),
            });
      }

      if (mounted) {
        context.showSnackBar(
          'Signed in with Google!',
          theme: SnackBarTheme.success,
        );

        Navigator.pushReplacementNamed(context, "/completeProfile");
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar(
          "Google sign-in failed: $e",
          theme: SnackBarTheme.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: CustomAppBar("Sign Up", showBack: true),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Center(
            child: ListView(
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              children: [
                Image.asset('assets/images/logo.png', height: 160),
                const SizedBox(height: 24),
                const Text(
                  'Sign up to Pawfect Care',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your username' : null,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  autofillHints: const [AutofillHints.email],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your email';
                    }
                    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    if (!emailRegex.hasMatch(value)) return 'Invalid email';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() {
                        _obscurePassword = !_obscurePassword;
                      }),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  autofillHints: const [AutofillHints.password],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long.';
                    }
                    if (!value.contains(RegExp(r'[A-Z]'))) {
                      return 'Password must contain at least one uppercase letter.';
                    }
                    if (!value.contains(RegExp(r'[a-z]'))) {
                      return 'Password must contain at least one lowercase letter.';
                    }
                    if (!value.contains(RegExp(r'[0-9]'))) {
                      return 'Password must contain at least one number.';
                    }
                    if (!value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
                      return 'Password must contain at least one special character.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Select Your Role',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ToggleButtons(
                    isSelected: _isSelected,
                    onPressed: (int newIndex) {
                      setState(() {
                        for (int i = 0; i < _isSelected.length; i++) {
                          _isSelected[i] = i == newIndex;
                        }
                      });
                    },
                    borderColor: Theme.of(context).colorScheme.inverseSurface,
                    borderRadius: BorderRadius.circular(8),
                    selectedColor: Theme.of(context).colorScheme.onPrimary,
                    fillColor: Theme.of(context).colorScheme.primary,
                    children: _roles.map((role) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(role, style: const TextStyle(fontSize: 16)),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 50,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _signUpWithEmail,
                    child: Text(_isLoading ? 'Loading...' : 'Sign Up'),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _signUpWithGoogle,
                  icon: Image.asset(
                    'assets/images/google_logo.png', // your Google logo path
                    height: 24,
                    width: 24,
                  ),
                  label: const Text("Sign up with Google"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // white like Google
                    foregroundColor: Colors.black, // black text
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Already have an account? Sign In"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
