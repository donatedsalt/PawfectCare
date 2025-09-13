import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pawfect_care/utils/context_extension.dart';

import 'package:pawfect_care/services/image_service.dart';
import 'package:pawfect_care/services/email_update_service.dart';
import 'package:pawfect_care/widgets/action_buttons.dart';

import 'package:pawfect_care/widgets/custom_app_bar.dart';

import 'package:pawfect_care/pages/common/loading_screen.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final _imageService = ImageService();
  final _emailUpdateService = EmailUpdateService();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _roleController;
  late String _role;

  Uint8List? _imageBytes;
  bool _isSubmitting = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _roleController = TextEditingController();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
    });

    final user = _auth.currentUser;
    if (user != null) {
      final userData = await _firestore.collection('users').doc(user.uid).get();
      if (userData.exists) {
        final data = userData.data();
        setState(() {
          _role = data?['role'] ?? 'N/A';
          _roleController.text = _role;
        });
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _reauthenticateUser() async {
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
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  final user = _auth.currentUser;
                  if (user == null || user.email == null) return;
                  final cred = EmailAuthProvider.credential(
                    email: user.email!,
                    password: passwordController.text.trim(),
                  );
                  await user.reauthenticateWithCredential(cred);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                  _updateProfile();
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

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        context.showSnackBar("Updating profile...");

        final user = _auth.currentUser;
        if (user != null) {
          String? photoUrl;
          if (_imageBytes != null) {
            photoUrl = await _imageService.uploadImageToFirebase(
              _imageBytes!,
              'profile_pictures/${user.uid}',
            );
            if (photoUrl != null) {
              await user.updatePhotoURL(photoUrl);
            }
          }

          if (_emailController.text.trim() != (user.email ?? '')) {
            await _emailUpdateService.updateEmail(
              newEmail: _emailController.text.trim(),
            );
          }

          await user.updateDisplayName(_nameController.text.trim());
          await user.reload();

          await _firestore.collection('users').doc(user.uid).update({
            'name': _nameController.text.trim(),
            if (photoUrl != null) 'profilePictureUrl': photoUrl,
          });
        }

        if (mounted) {
          context.showSnackBar(
            'Profile updated successfully!',
            theme: SnackBarTheme.success,
          );
          Navigator.of(context).pop();
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login' && mounted) {
          _reauthenticateUser();
        } else if (mounted) {
          context.showSnackBar(
            'Failed to update profile. Please try again.',
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

  Future<void> _pickImage() async {
    final bytes = await _imageService.pickImageFromGallery();
    if (bytes != null) {
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  ImageProvider? _getProfileImage() {
    if (_imageBytes != null) {
      return MemoryImage(_imageBytes!);
    }
    if (_auth.currentUser?.photoURL != null) {
      return NetworkImage(_auth.currentUser!.photoURL!);
    }
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SplashScreen();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120),
        child: CustomAppBar(
          "Edit Profile",
          showBack: _isSubmitting ? false : true,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundImage: _getProfileImage(),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!RegExp(
                    r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                  ).hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _roleController,
                decoration: InputDecoration(
                  labelText: 'Role',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[300],
                ),
                readOnly: true,
              ),
              const SizedBox(height: 16),
              const Text("Role can not be changed once set."),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomActionButtons(
        isSubmitting: _isSubmitting,
        onCancel: () => Navigator.pop(context),
        onSubmit: _updateProfile,
      ),
    );
  }
}
