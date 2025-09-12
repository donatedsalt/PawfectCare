import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pawfect_care/services/image_service.dart';

import 'package:pawfect_care/widgets/custom_app_bar.dart';
import 'package:pawfect_care/widgets/action_buttons.dart';

class BugReportPage extends StatefulWidget {
  const BugReportPage({super.key});

  @override
  State<BugReportPage> createState() => _BugReportPageState();
}

class _BugReportPageState extends State<BugReportPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _imageService = ImageService();

  bool _isSubmitting = false;
  final List<Uint8List> _images = [];

  String? _selectedSeverity;
  String? _selectedCategory;

  final List<String> _severities = ["Low", "Medium", "High"];
  final List<String> _categories = ["UI", "Crash", "Performance", "Other"];

  Future<void> _pickImage() async {
    if (_images.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only upload up to 3 images.')),
      );
      return;
    }

    final bytes = await _imageService.pickImageFromGallery();
    if (bytes != null) {
      setState(() {
        _images.add(bytes);
      });
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final user = _auth.currentUser;

      // Upload images
      List<String> imageUrls = [];
      for (int i = 0; i < _images.length; i++) {
        final url = await _imageService.uploadImageToFirebase(
          _images[i],
          'bug_reports/${user?.uid}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
        );
        if (url != null) imageUrls.add(url);
      }

      await _firestore.collection('bug_reports').add({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'severity': _selectedSeverity,
        'category': _selectedCategory,
        'images': imageUrls,
        'userId': user?.uid,
        'userEmail': user?.email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bug report submitted successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit bug report: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Widget _buildToggleGroup({
    required String label,
    required List<String> options,
    required String? selectedValue,
    required Function(String) onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final buttonWidth = (constraints.maxWidth / options.length) - 2;
            return ToggleButtons(
              isSelected: options.map((opt) => opt == selectedValue).toList(),
              onPressed: (index) => onSelected(options[index]),
              borderRadius: BorderRadius.circular(8),
              fillColor: Theme.of(context).colorScheme.primary,
              selectedColor: Theme.of(context).colorScheme.onPrimary,
              constraints: BoxConstraints.expand(
                width: buttonWidth,
                height: 48,
              ),
              children: options
                  .map((opt) => Text(opt, textAlign: TextAlign.center))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: CustomAppBar(
          "Report a Bug",
          showBack: _isSubmitting ? false : true,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Bug Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a bug title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Bug Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 6,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please describe the bug';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _buildToggleGroup(
                label: 'Severity',
                options: _severities,
                selectedValue: _selectedSeverity,
                onSelected: (val) => setState(() => _selectedSeverity = val),
              ),
              const SizedBox(height: 24),
              _buildToggleGroup(
                label: 'Category',
                options: _categories,
                selectedValue: _selectedCategory,
                onSelected: (val) => setState(() => _selectedCategory = val),
              ),
              const SizedBox(height: 24),
              Text(
                'Attachments (max 3 images):',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  ..._images.asMap().entries.map(
                    (entry) => Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            entry.value,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _images.removeAt(entry.key)),
                            child: Container(
                              color: Colors.black54,
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_images.length < 3)
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: const Icon(
                          Icons.add_a_photo,
                          size: 32,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomActionButtons(
        isSubmitting: _isSubmitting,
        onCancel: () => Navigator.pop(context),
        onSubmit: _submitReport,
      ),
    );
  }
}
