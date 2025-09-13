import 'package:flutter/material.dart';
import 'package:pawfect_care/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pawfect_care/utils/context_extension.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  String? _selectedRole;
  final List<String> _roles = [
    'user',
    'veterinarian',
    'animal shelter',
    'pet store',
    'admin',
  ];
  late List<bool> _isSelected;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isSelected = List.filled(_roles.length, false);
  }

  Future<void> _completeProfile() async {
    if (!_formKey.currentState!.validate()) return;

    int selectedIndex = _isSelected.indexOf(true);
    if (selectedIndex != -1) {
      _selectedRole = _roles[selectedIndex];
    } else {
      context.showSnackBar('Please select a role.', theme: SnackBarTheme.error);
      return;
    }

    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      "name": _usernameController.text.trim(),
      "role": _selectedRole,
      "completedProfile": true,
    }, SetOptions(merge: true));

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthGate()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complete Your Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your username' : null,
              ),
              const SizedBox(height: 16),
              const Text("Select Your Role"),
              const SizedBox(height: 8),
              ToggleButtons(
                isSelected: _isSelected,
                onPressed: (index) {
                  setState(() {
                    for (int i = 0; i < _isSelected.length; i++) {
                      _isSelected[i] = i == index;
                    }
                  });
                },
                children: _roles
                    .map(
                      (role) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(role),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed: _isLoading ? null : _completeProfile,
                  child: Text(_isLoading ? "Loading..." : "Complete Profile"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
