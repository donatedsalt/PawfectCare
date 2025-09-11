import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pawfect_care/utils/context_extension.dart';

import 'package:pawfect_care/services/image_service.dart';

class AddPetPage extends StatefulWidget {
  const AddPetPage({super.key});

  @override
  State<AddPetPage> createState() => _AddPetPageState();
}

class _AddPetPageState extends State<AddPetPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final _imageService = ImageService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _speciesController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();

  Uint8List? _imageBytes;
  bool _isSubmitting = false;

  Future<void> _addPet() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final user = _auth.currentUser;
        if (user == null) {
          if (mounted) {
            context.showSnackBar(
              'User not signed in.',
              theme: SnackBarTheme.error,
            );
          }
          return;
        }

        String? photoUrl;
        if (_imageBytes != null) {
          photoUrl = await _imageService.uploadImageToFirebase(
            _imageBytes!,
            'pets/${user.uid}/${_nameController.text.trim()}',
          );
        }

        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('pets')
            .add({
              'name': _nameController.text.trim(),
              'species': _speciesController.text.trim(),
              'breed': _breedController.text.trim(),
              'photoUrl': photoUrl,
              'createdAt': FieldValue.serverTimestamp(),
            });

        if (mounted) {
          context.showSnackBar(
            'Pet added successfully!',
            theme: SnackBarTheme.success,
          );
          Navigator.pop(context);
        }
      } on FirebaseException catch (e) {
        if (mounted) {
          context.showSnackBar(
            'Failed to add pet: ${e.message}',
            theme: SnackBarTheme.error,
          );
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

  ImageProvider? _getPetImage() {
    if (_imageBytes != null) {
      return MemoryImage(_imageBytes!);
    }
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _breedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a Pet'),
        leading: IconButton(
          onPressed: () {
            _isSubmitting
                ? context.showSnackBar("please wait...")
                : Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundImage: _getPetImage(),
                        child: _imageBytes == null
                            ? const Icon(Icons.pets, size: 32)
                            : null,
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
                  labelText: 'Pet Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your pet\'s name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _speciesController,
                decoration: const InputDecoration(
                  labelText: 'Species (e.g., Dog, Cat)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your pet\'s species';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(
                  labelText: 'Breed',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _addPet,
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Add Pet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
