import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:pawfect_care/utils/context_extension.dart';

import 'package:pawfect_care/services/password_update_service.dart';

import 'package:pawfect_care/widgets/custom_app_bar.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final _passwordUpdateService = PasswordUpdateService();

  late final TextEditingController _passwordController;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
  }

  Future<void> _reauthenticateUser() async {
    final email = _auth.currentUser?.email;
    if (email == null) return;

    final passwordController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Re-authenticate'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'This is a sensitive operation. Please re-enter your password to continue.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  final cred = EmailAuthProvider.credential(
                    email: email,
                    password: passwordController.text.trim(),
                  );
                  await _auth.currentUser!.reauthenticateWithCredential(cred);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                  _changePassword();
                } on FirebaseAuthException catch (e) {
                  if (context.mounted) {
                    context.showSnackBar(
                      'Authentication failed: ${e.message}',
                      theme: SnackBarTheme.error,
                    );
                  }
                  if (kDebugMode) {
                    print(e);
                  }
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        context.showSnackBar("Updating password...");
        await _passwordUpdateService.updatePassword(
          newPassword: _passwordController.text.trim(),
        );

        if (mounted) {
          context.showSnackBar(
            'Password updated successfully!',
            theme: SnackBarTheme.success,
          );
          Navigator.of(context).pop();
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login' && mounted) {
          _reauthenticateUser();
        } else if (mounted) {
          context.showSnackBar(
            'Failed to update password. Please try again.',
            theme: SnackBarTheme.error,
          );
        }
        if (kDebugMode) {
          print(e);
        }
      } on PlatformException catch (e) {
        if (mounted) {
          if (e.code == 'network-request-failed') {
            context.showSnackBar(
              'A network error occurred. Please check your connection.',
              theme: SnackBarTheme.error,
            );
          } else {
            context.showSnackBar(
              'An error occurred: ${e.message}',
              theme: SnackBarTheme.error,
            );
          }
        }
        if (kDebugMode) {
          print(e);
        }
      } catch (e) {
        if (mounted) {
          context.showSnackBar(
            'An unexpected error occurred.',
            theme: SnackBarTheme.error,
          );
        }
        if (kDebugMode) {
          print(e);
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120),
        child: CustomAppBar(
          "Change Password",
          showBack: _isSubmitting ? false : true,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Password must contain:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text('- At least 6 characters long'),
                  const Text('- A uppercase letter (A-Z)'),
                  const Text('- A lowercase letter (a-z)'),
                  const Text('- A number (0-9)'),
                  const Text('- A symbol (!@#\$%&*)'),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  if (!value.contains(RegExp(r'[A-Z]'))) {
                    return 'Password must contain an uppercase letter';
                  }
                  if (!value.contains(RegExp(r'[a-z]'))) {
                    return 'Password must contain a lowercase letter';
                  }
                  if (!value.contains(RegExp(r'[0-9]'))) {
                    return 'Password must contain a number';
                  }
                  if (!value.contains(RegExp(r'[\W_]'))) {
                    return 'Password must contain a symbol';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  _isSubmitting
                      ? context.showSnackBar("please wait...")
                      : _changePassword();
                },
                icon: _isSubmitting
                    ? SizedBox(
                        height: 16.0,
                        width: 16.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.check),
                label: const Text('Change Password'),
                style: const ButtonStyle(
                  padding: WidgetStatePropertyAll(EdgeInsets.all(16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
