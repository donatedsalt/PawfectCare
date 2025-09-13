import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pawfect_care/utils/context_extension.dart';

import 'package:pawfect_care/services/image_service.dart';

import 'package:pawfect_care/widgets/custom_app_bar.dart';
import 'package:pawfect_care/widgets/action_buttons.dart';

import 'package:pawfect_care/pages/common/loading_screen.dart';

// This page allows the user to edit a pet's details.
class EditPetPage extends StatefulWidget {
  final String petId;
  final Map<String, dynamic> pet;

  const EditPetPage({super.key, required this.petId, required this.pet});

  @override
  State<EditPetPage> createState() => _EditPetPageState();
}

class _EditPetPageState extends State<EditPetPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final _imageService = ImageService();

  late final TextEditingController _nameController;
  late final TextEditingController _speciesController;
  late final TextEditingController _breedController;

  Uint8List? _imageBytes;
  bool _isSubmitting = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pet['name'] ?? '');
    _speciesController = TextEditingController(
      text: widget.pet['species'] ?? '',
    );
    _breedController = TextEditingController(text: widget.pet['breed'] ?? '');
  }

  Future<void> _updatePet() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        context.showSnackBar("Updating pet profile...");

        final user = _auth.currentUser;
        if (user != null) {
          String? photoUrl = widget.pet['photoUrl'] as String?;
          if (_imageBytes != null) {
            // Upload the new image to Firebase Storage
            photoUrl = await _imageService.uploadImageToFirebase(
              _imageBytes!,
              'pet_pictures/${user.uid}/${widget.petId}',
            );
          }

          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('pets')
              .doc(widget.petId)
              .update({
                'name': _nameController.text.trim(),
                'species': _speciesController.text.trim(),
                'breed': _breedController.text.trim(),
                'photoUrl': photoUrl,
              });
        }

        if (mounted) {
          context.showSnackBar(
            'Pet profile updated successfully!',
            theme: SnackBarTheme.success,
          );
          Navigator.of(context).pop();
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

  ImageProvider? get _petImage {
    if (_imageBytes != null) {
      return MemoryImage(_imageBytes!);
    }
    if (widget.pet['photoUrl'] != null) {
      return NetworkImage(widget.pet['photoUrl']);
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
    if (_isLoading) return const SplashScreen();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120),
        child: CustomAppBar("Edit Pet", showBack: !_isSubmitting),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 64,
                        backgroundColor: Colors.grey[200],
                        foregroundImage: _petImage,
                        child: const Icon(
                          Icons.pets,
                          size: 64,
                          color: Colors.grey,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                          ),
                          onPressed: _pickImage,
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: const CircleBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Pet Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name for your pet';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                TextFormField(
                  controller: _speciesController,
                  decoration: const InputDecoration(
                    labelText: 'Species',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the pet\'s species';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                TextFormField(
                  controller: _breedController,
                  decoration: const InputDecoration(
                    labelText: 'Breed',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the pet\'s breed';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomActionButtons(
        isSubmitting: _isSubmitting,
        onCancel: () => Navigator.pop(context),
        onSubmit: _updatePet,
      ),
    );
  }
}
