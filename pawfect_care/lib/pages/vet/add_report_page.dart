import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:pawfect_care/utils/context_extension.dart';
import 'package:pawfect_care/widgets/custom_app_bar.dart';
import 'package:pawfect_care/widgets/scale_fade_in.dart';
import 'package:pawfect_care/widgets/slide_fade_in.dart';

class AddReportsPage extends StatefulWidget {
  const AddReportsPage({super.key});

  @override
  State<AddReportsPage> createState() => _AddReportsPageState();
}

class _AddReportsPageState extends State<AddReportsPage> {
  final _formKey = GlobalKey<FormState>();
  final _petNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _fromDateController = TextEditingController();
  final _toDateController = TextEditingController();

  final List<PlatformFile> _selectedFiles = [];
  final List<String> _uploadedFileUrls = [];

  bool _isUploading = false;

  @override
  void dispose() {
    _petNameController.dispose();
    _ownerNameController.dispose();
    _fromDateController.dispose();
    _toDateController.dispose();
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

  Widget _buildAnimatedField(
    TextEditingController controller,
    String label, {
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return ScaleFadeIn(
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        decoration: _inputDecoration(label),
        validator: (val) => val == null || val.isEmpty ? "Enter $label" : null,
      ),
    );
  }

  Widget _buildAddFileButton() {
    return GestureDetector(
      onTap: _pickFiles,
      child: Container(
        width: 100,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.secondary),
        ),
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.secondary,
          size: 36,
        ),
      ),
    );
  }

  Widget _buildFilePreview(PlatformFile file, int index) {
    final isPdf = file.extension?.toLowerCase() == "pdf";
    ImageProvider? imageProvider;

    if (!isPdf) {
      if (file.bytes != null) {
        imageProvider = MemoryImage(file.bytes!);
      } else if (file.path != null) {
        imageProvider = FileImage(File(file.path!));
      }
    }

    return Stack(
      children: [
        Container(
          width: 100,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).colorScheme.primary,
            image: imageProvider != null
                ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
                : null,
          ),
          child: isPdf
              ? Center(
                  child: Icon(
                    Icons.picture_as_pdf,
                    color: Theme.of(context).colorScheme.error,
                    size: 40,
                  ),
                )
              : null,
        ),
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: () => setState(() => _selectedFiles.removeAt(index)),
            child: const CircleAvatar(
              radius: 12,
              backgroundColor: Colors.black54,
              child: Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf'],
    );

    if (result != null) {
      setState(() => _selectedFiles.addAll(result.files));
    }
  }

  Future<String> _uploadFileToFirebase(PlatformFile file) async {
    final storageRef = FirebaseStorage.instance.ref().child(
      'reports/${DateTime.now().millisecondsSinceEpoch}_${file.name}',
    );

    final uploadTask = kIsWeb
        ? storageRef.putData(file.bytes!)
        : storageRef.putFile(File(file.path!));

    final snapshot = await uploadTask;
    return snapshot.ref.getDownloadURL();
  }

  Future<void> _uploadFilesAndSaveData() async {
    if (_selectedFiles.isEmpty) return;

    setState(() => _isUploading = true);
    _uploadedFileUrls.clear();

    try {
      for (var file in _selectedFiles) {
        final url = await _uploadFileToFirebase(file);
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
        context.showSnackBar("Report uploaded successfully!");
      }

      _formKey.currentState?.reset();
      _petNameController.clear();
      _ownerNameController.clear();
      _fromDateController.clear();
      _toDateController.clear();
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

  void _generateReport() {
    if (_formKey.currentState!.validate()) {
      _uploadFilesAndSaveData();
    }
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: Theme.of(context).colorScheme.secondary,
            onPrimary: Colors.white,
            surface: Theme.of(context).colorScheme.primary,
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (date != null) {
      controller.text = "${date.day}/${date.month}/${date.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const CustomAppBar("Reports", showBack: true),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildAnimatedField(_petNameController, "Pet Name"),
                    const SizedBox(height: 16),
                    _buildAnimatedField(_ownerNameController, "Owner Name"),
                    const SizedBox(height: 16),
                    _buildAnimatedField(
                      _fromDateController,
                      "From Date",
                      readOnly: true,
                      onTap: () => _pickDate(_fromDateController),
                    ),
                    const SizedBox(height: 16),
                    _buildAnimatedField(
                      _toDateController,
                      "To Date",
                      readOnly: true,
                      onTap: () => _pickDate(_toDateController),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Upload X-rays / Reports",
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
                            return _buildAddFileButton();
                          }
                          return _buildFilePreview(
                            _selectedFiles[index],
                            index,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    SlideFadeIn(
                      child: SizedBox(
                        height: 50,
                        child: FilledButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                              Theme.of(context).colorScheme.secondary,
                            ),
                            foregroundColor: WidgetStatePropertyAll(
                              Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          onPressed: _isUploading ? null : _generateReport,
                          child: _isUploading
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Generate Report",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
