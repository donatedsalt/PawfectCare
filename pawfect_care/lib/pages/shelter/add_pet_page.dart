import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pawfect_care/widgets/custom_app_bar.dart';
import 'package:pawfect_care/widgets/scale_fade_in.dart';
import 'package:pawfect_care/widgets/slide_fade_in.dart';

class AddPetPage extends StatefulWidget {
  final String? petId;
  final Map<String, dynamic>? existingData;

  const AddPetPage({super.key, this.petId, this.existingData});

  @override
  State<AddPetPage> createState() => _AddPetPageState();
}

class _AddPetPageState extends State<AddPetPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _speciesController;
  late TextEditingController _typeController;
  late TextEditingController _breedController;
  late TextEditingController _ageController;
  late TextEditingController _genderController;
  late TextEditingController _statusController;

  String _statusValue = 'available';

  final List<PlatformFile> _selectedFiles = [];
  final List<String> _uploadedUrls = [];

  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingData?['name'] ?? '',
    );
    _speciesController = TextEditingController(
      text: widget.existingData?['species'] ?? '',
    );
    _typeController = TextEditingController(
      text: widget.existingData?['type'] ?? '',
    );
    _breedController = TextEditingController(
      text: widget.existingData?['breed'] ?? '',
    );
    _ageController = TextEditingController(
      text: widget.existingData?['age'] ?? '',
    );
    _genderController = TextEditingController(
      text: widget.existingData?['gender'] ?? '',
    );
    _statusController = TextEditingController(
      text: widget.existingData?['status'] ?? 'available',
    );

    _statusValue = widget.existingData?['status'] ?? 'available';

    if (widget.existingData?['images'] != null) {
      _uploadedUrls.addAll(List<String>.from(widget.existingData!['images']));
    } else if (widget.existingData?['photoUrl'] != null &&
        widget.existingData!['photoUrl'] != '') {
      _uploadedUrls.add(widget.existingData!['photoUrl']);
    }
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );
    if (result != null) setState(() => _selectedFiles.addAll(result.files));
  }

  Future<String> _uploadFile(PlatformFile file) async {
    final ref = FirebaseStorage.instance.ref().child(
      'pets/${DateTime.now().millisecondsSinceEpoch}_${file.name}',
    );
    final task = kIsWeb
        ? ref.putData(file.bytes!)
        : ref.putFile(File(file.path!));
    final snapshot = await task;
    return snapshot.ref.getDownloadURL();
  }

  Future<void> _savePet() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isUploading = true);

    try {
      for (var file in _selectedFiles) {
        final url = await _uploadFile(file);
        _uploadedUrls.add(url);
      }

      final data = {
        'name': _nameController.text,
        'species': _speciesController.text,
        'type': _typeController.text,
        'breed': _breedController.text,
        'age': _ageController.text,
        'gender': _genderController.text,
        'status': _statusController.text,
        'images': _uploadedUrls,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final petsRef = FirebaseFirestore.instance.collection('pets');
      if (widget.petId != null) {
        await petsRef.doc(widget.petId).update(data);
      } else {
        await petsRef.add(data);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ScaleFadeIn(
        child: TextFormField(
          controller: controller,
          validator: required
              ? (val) => val!.isEmpty ? 'Required' : null
              : null,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.primary.withAlpha(240),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.greenAccent, width: 2),
            ),
          ),
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    final statusOptions = ['available', 'unavailable'];

    // Agar current status list me nahi hai to default available set karo
    if (!statusOptions.contains(_statusValue)) {
      _statusValue = 'available';
      _statusController.text = 'available';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ScaleFadeIn(
        child: DropdownButtonFormField<String>(
          value: _statusValue,
          decoration: InputDecoration(
            labelText: 'Status',
            labelStyle: const TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.primary.withAlpha(240),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.greenAccent, width: 2),
            ),
          ),
          dropdownColor: Theme.of(context).primaryColor,
          style: const TextStyle(color: Colors.white),
          items: statusOptions
              .map(
                (status) =>
                    DropdownMenuItem(value: status, child: Text(status)),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _statusValue = val;
                _statusController.text = val;
              });
            }
          },
          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
        ),
      ),
    );
  }

  Widget _buildImagePreview(String url, int index) {
    return Stack(
      children: [
        Container(
          width: 100,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: () => setState(() => _uploadedUrls.removeAt(index)),
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

  Widget _buildFilePreview(PlatformFile file, int index) {
    final imageProvider = file.bytes != null
        ? MemoryImage(file.bytes!)
        : FileImage(File(file.path!)) as ImageProvider;
    return Stack(
      children: [
        Container(
          width: 100,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(
            widget.petId != null ? "Edit Pet" : "Add New Pet",
            showBack: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      _nameController,
                      "Pet Name",
                      required: true,
                    ),
                    _buildTextField(_speciesController, "Species"),
                    _buildTextField(_typeController, "Type"),
                    _buildTextField(_breedController, "Breed"),
                    _buildTextField(_ageController, "Age"),
                    _buildTextField(_genderController, "Gender"),
                    _buildStatusDropdown(),
                    const SizedBox(height: 10),
                    Text(
                      "Pet Images",
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
                        itemCount:
                            _uploadedUrls.length + _selectedFiles.length + 1,
                        itemBuilder: (context, index) {
                          if (index ==
                              _uploadedUrls.length + _selectedFiles.length)
                            return _buildAddFileButton();
                          if (index < _uploadedUrls.length)
                            return _buildImagePreview(
                              _uploadedUrls[index],
                              index,
                            );
                          return _buildFilePreview(
                            _selectedFiles[index - _uploadedUrls.length],
                            index - _uploadedUrls.length,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    SlideFadeIn(
                      child: SizedBox(
                        height: 50,
                        child: FilledButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(
                              Theme.of(context).colorScheme.secondary,
                            ),
                            foregroundColor: MaterialStatePropertyAll(
                              Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          onPressed: _isUploading ? null : _savePet,
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
                              : Text(
                                  widget.petId != null
                                      ? "Update Pet"
                                      : "Add Pet",
                                  style: const TextStyle(
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
            ),
          ),
        ],
      ),
    );
  }
}
