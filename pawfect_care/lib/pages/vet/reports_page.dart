import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:pawfect_care/utils/context_extension.dart';

import 'package:pawfect_care/pages/vet/home_page.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _petNameController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  final List<PlatformFile> _selectedFiles = [];
  final List<String> _uploadedFileUrls = [];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isPressed = false;
  bool _isUploading = false;

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
    _petNameController.dispose();
    _ownerNameController.dispose();
    _fromDateController.dispose();
    _toDateController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: BrandColors.textWhite),
      filled: true,
      fillColor: BrandColors.cardBlue.withOpacity(0.9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: BrandColors.primaryBlue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf'],
    );

    if (result != null) {
      setState(() {
        _selectedFiles.addAll(result.files);
      });
    }
  }

  Future<String> _uploadFileToFirebase(PlatformFile file) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(
        'reports/${DateTime.now().millisecondsSinceEpoch}_${file.name}',
      );

      UploadTask uploadTask;

      if (kIsWeb) {
        uploadTask = storageRef.putData(file.bytes!);
      } else {
        uploadTask = storageRef.putFile(File(file.path!));
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception("Firebase upload failed: $e");
    }
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

      await FirebaseFirestore.instance.collection('reports').add({
        'petName': _petNameController.text,
        'ownerName': _ownerNameController.text,
        'fromDate': _fromDateController.text,
        'toDate': _toDateController.text,
        'fileUrls': _uploadedFileUrls,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        context.showSnackBar("Report generated and uploaded successfully!");
      }

      _formKey.currentState!.reset();
      _petNameController.clear();
      _ownerNameController.clear();
      _fromDateController.clear();
      _toDateController.clear();
      setState(() {
        _selectedFiles.clear();
        _uploadedFileUrls.clear();
      });
    } catch (e) {
      if (mounted) {
        context.showSnackBar("Error uploading files: $e");
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _generateReport() {
    if (_formKey.currentState!.validate()) {
      _uploadFilesAndSaveData();
    }
  }

  Widget _animatedField(
    TextEditingController controller,
    String label, {
    bool readOnly = false,
    VoidCallback? onTap,
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
        readOnly: readOnly,
        onTap: onTap,
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
          _generateReport();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withAlpha(200),
                ],
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
                  ? const CircularProgressIndicator(
                      color: BrandColors.textWhite,
                    )
                  : const Text(
                      'Generate Report',
                      style: TextStyle(
                        fontSize: 18,
                        color: BrandColors.textWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate(TextEditingController controller) async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: BrandColors.accentGreen,
              onPrimary: Colors.white,
              surface: BrandColors.cardBlue,
              onSurface: Colors.white,
            ),
            dialogTheme: DialogThemeData(backgroundColor: BrandColors.cardBlue),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      controller.text = "${date.day}/${date.month}/${date.year}";
    }
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
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(
                              context,
                            ).colorScheme.primary.withAlpha(200),
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
                          "Reports",
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
                        icon: const Icon(
                          Icons.arrow_back,
                          color: BrandColors.textWhite,
                          size: 28,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
                _animatedField(_petNameController, "Pet Name"),
                const SizedBox(height: 16),
                _animatedField(_ownerNameController, "Owner Name"),
                const SizedBox(height: 16),
                _animatedField(
                  _fromDateController,
                  "From Date",
                  readOnly: true,
                  onTap: () => _pickDate(_fromDateController),
                ),
                const SizedBox(height: 16),
                _animatedField(
                  _toDateController,
                  "To Date",
                  readOnly: true,
                  onTap: () => _pickDate(_toDateController),
                ),
                const SizedBox(height: 16),
                Text(
                  "Upload X-rays / Reports",
                  style: TextStyle(
                    color: BrandColors.primaryBlue,
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
                              border: Border.all(
                                color: BrandColors.accentGreen,
                              ),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: BrandColors.textWhite,
                              size: 36,
                            ),
                          ),
                        );
                      } else {
                        final file = _selectedFiles[index];
                        bool isPdf = file.extension == "pdf";

                        return Stack(
                          children: [
                            Container(
                              width: 100,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: BrandColors.cardBlue,
                                image: isPdf
                                    ? null
                                    : DecorationImage(
                                        image: kIsWeb
                                            ? MemoryImage(file.bytes!)
                                            : FileImage(File(file.path!))
                                                  as ImageProvider,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              child: isPdf
                                  ? const Center(
                                      child: Icon(
                                        Icons.picture_as_pdf,
                                        color: Colors.red,
                                        size: 40,
                                      ),
                                    )
                                  : null,
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
                                  decoration: BoxDecoration(
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
                _animatedButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
