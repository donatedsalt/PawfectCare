import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:pawfect_care/utils/context_extension.dart';
import 'package:pawfect_care/widgets/custom_app_bar.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  final List<PlatformFile> _selectedFiles = [];
  final List<String> _uploadedFileUrls = [];

  bool _isUploading = false;
  bool _isSubmitting = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
      filled: true,
      fillColor: Theme.of(context).colorScheme.primary.withAlpha(240),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png'],
    );

    if (result != null) {
      setState(() {
        _selectedFiles.addAll(result.files);
      });
    }
  }

  Future<String> _uploadFileToFirebase(PlatformFile file) async {
    final storageRef = FirebaseStorage.instance.ref().child(
      'products/${DateTime.now().millisecondsSinceEpoch}_${file.name}',
    );
    UploadTask uploadTask;

    if (kIsWeb) {
      uploadTask = storageRef.putData(file.bytes!);
    } else {
      uploadTask = storageRef.putFile(File(file.path!));
    }

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _uploadFilesAndSaveData() async {
    if (_selectedFiles.isEmpty) return;

    setState(() {
      _isUploading = true;
      _isSubmitting = true;
    });
    _uploadedFileUrls.clear();

    try {
      for (var file in _selectedFiles) {
        String url = await _uploadFileToFirebase(file);
        _uploadedFileUrls.add(url);
      }

      await FirebaseFirestore.instance.collection('products').add({
        'name': _productNameController.text,
        'category': _categoryController.text,
        'price': double.tryParse(_priceController.text) ?? 0,
        'stock': int.tryParse(_stockController.text) ?? 0,
        'images': _uploadedFileUrls,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) context.showSnackBar("Product added successfully!");

      _formKey.currentState!.reset();
      _productNameController.clear();
      _categoryController.clear();
      _priceController.clear();
      _stockController.clear();
      setState(() {
        _selectedFiles.clear();
        _uploadedFileUrls.clear();
      });
    } catch (e) {
      if (mounted) context.showSnackBar("Error: $e");
    } finally {
      setState(() {
        _isUploading = false;
        _isSubmitting = false;
      });
    }
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      _uploadFilesAndSaveData();
    }
  }

  Widget _animatedField(
    TextEditingController controller,
    String label, {
    TextInputType type = TextInputType.text,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        decoration: _inputDecoration(label),
        validator: (val) => val == null || val.isEmpty ? "Enter $label" : null,
      ),
    );
  }

  Widget _submitButton() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: FilledButton(
          onPressed: _isSubmitting ? null : _saveProduct,
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
          child: _isUploading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  "Save Product",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomAppBar("Add Product", showBack: !_isSubmitting),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _animatedField(_productNameController, "Product Name"),
                      const SizedBox(height: 16),
                      _animatedField(_categoryController, "Category"),
                      const SizedBox(height: 16),
                      _animatedField(
                        _priceController,
                        "Price",
                        type: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      _animatedField(
                        _stockController,
                        "Stock Quantity",
                        type: TextInputType.number,
                      ),

                      const SizedBox(height: 16),
                      Text(
                        "Upload Product Images",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedFiles.length + 1,
                          itemBuilder: (context, index) {
                            if (index == _selectedFiles.length) {
                              return GestureDetector(
                                onTap: _pickFiles,
                                child: Container(
                                  width: 100,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                    size: 36,
                                  ),
                                ),
                              );
                            } else {
                              final file = _selectedFiles[index];
                              return Stack(
                                children: [
                                  Container(
                                    width: 100,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      image: DecorationImage(
                                        image: kIsWeb
                                            ? MemoryImage(file.bytes!)
                                            : FileImage(File(file.path!)),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 2,
                                    right: 2,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedFiles.removeAt(index);
                                        });
                                      },
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ),

                      const SizedBox(height: 30),
                      _submitButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
