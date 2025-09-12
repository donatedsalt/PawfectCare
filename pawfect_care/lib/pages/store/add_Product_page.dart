import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:pawfect_care/utils/context_extension.dart';
import 'package:pawfect_care/pages/vet/home_page.dart'; // For BrandColors

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
  bool _isPressed = false;

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
      labelStyle: const TextStyle(color: BrandColors.accentGreen),
      filled: true,
      fillColor: BrandColors.cardBlue.withOpacity(0.9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: BrandColors.accentGreen, width: 2),
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
        'products/${DateTime.now().millisecondsSinceEpoch}_${file.name}');
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

    setState(() => _isUploading = true);
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
      setState(() => _isUploading = false);
    }
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      _uploadFilesAndSaveData();
    }
  }

  Widget _animatedField(TextEditingController controller, String label,
      {TextInputType type = TextInputType.text}) {
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
        style: const TextStyle(color: BrandColors.textWhite),
        decoration: _inputDecoration(label),
        validator: (val) => val == null || val.isEmpty ? "Enter $label" : null,
      ),
    );
  }

  Widget _animatedButton() {
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
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _saveProduct();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [BrandColors.accentGreen, BrandColors.primaryBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: _isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Save Product",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.darkBackground,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Header
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            BrandColors.accentGreen,
                            BrandColors.primaryBlue,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "Add Product",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: BrandColors.textWhite,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      top: 12,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),

                _animatedField(_productNameController, "Product Name"),
                const SizedBox(height: 16),
                _animatedField(_categoryController, "Category"),
                const SizedBox(height: 16),
                _animatedField(_priceController, "Price",
                    type: TextInputType.number),
                const SizedBox(height: 16),
                _animatedField(_stockController, "Stock Quantity",
                    type: TextInputType.number),

                const SizedBox(height: 16),
                Text(
                  "Upload Product Images",
                  style: TextStyle(
                    color: BrandColors.accentGreen,
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
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: BrandColors.cardBlue,
                              borderRadius: BorderRadius.circular(16),
                              border:
                                  Border.all(color: BrandColors.accentGreen),
                            ),
                            child: const Icon(Icons.add,
                                color: BrandColors.accentGreen, size: 36),
                          ),
                        );
                      } else {
                        final file = _selectedFiles[index];
                        return Stack(
                          children: [
                            Container(
                              width: 100,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                image: DecorationImage(
                                  image: kIsWeb
                                      ? MemoryImage(file.bytes!)
                                      : FileImage(File(file.path!))
                                          as ImageProvider,
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
                                  child: const Icon(Icons.close,
                                      color: Colors.white, size: 20),
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
                _animatedButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
