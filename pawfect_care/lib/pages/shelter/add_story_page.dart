import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pawfect_care/widgets/custom_app_bar.dart';
import 'package:pawfect_care/widgets/scale_fade_in.dart';
import 'package:pawfect_care/widgets/slide_fade_in.dart';

class AddStoryPage extends StatefulWidget {
  final String? storyId;
  final Map<String, dynamic>? existingData;

  const AddStoryPage({super.key, this.storyId, this.existingData});

  @override
  State<AddStoryPage> createState() => _AddStoryPageState();
}

class _AddStoryPageState extends State<AddStoryPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _petController;
  late TextEditingController _adopterController;
  late TextEditingController _storyController;

  final List<PlatformFile> _selectedFiles = [];
  final List<String> _uploadedUrls = [];

  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _petController = TextEditingController(text: widget.existingData?['petName'] ?? '');
    _adopterController = TextEditingController(text: widget.existingData?['adopterName'] ?? '');
    _storyController = TextEditingController(text: widget.existingData?['story'] ?? '');

    if (widget.existingData?['images'] != null) {
      _uploadedUrls.addAll(List<String>.from(widget.existingData!['images']));
    } else if (widget.existingData?['imagePath'] != null &&
        widget.existingData!['imagePath'] != '') {
      _uploadedUrls.add(widget.existingData!['imagePath']);
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
      'successStories/${DateTime.now().millisecondsSinceEpoch}_${file.name}',
    );
    final task = kIsWeb ? ref.putData(file.bytes!) : ref.putFile(File(file.path!));
    final snapshot = await task;
    return snapshot.ref.getDownloadURL();
  }

  Future<void> _saveStory() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isUploading = true);

    try {
      // Upload all selected files
      for (var file in _selectedFiles) {
        final url = await _uploadFile(file); // Firebase Storage URL
        _uploadedUrls.add(url);
      }

      final data = {
        'petName': _petController.text,
        'adopterName': _adopterController.text,
        'story': _storyController.text,
        'images': _uploadedUrls,            // Only Firebase URLs
        'createdAt': FieldValue.serverTimestamp(),
      };

      final collection = FirebaseFirestore.instance.collection('successStories');
      if (widget.storyId != null) {
        await collection.doc(widget.storyId).update(data);
      } else {
        await collection.add(data);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool required = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ScaleFadeIn(
        child: TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: required ? (val) => val!.isEmpty ? 'Required' : null : null,
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
          CustomAppBar(widget.storyId != null ? "Edit Story" : "Add Story",
              showBack: true),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(_petController, "Pet Name", required: true),
                    _buildTextField(_adopterController, "Adopter Name", required: true),
                    _buildTextField(_storyController, "Story", required: true, maxLines: 5),
                    const SizedBox(height: 10),
                    Text(
                      "Story Images",
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
                        itemCount: _uploadedUrls.length + _selectedFiles.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _uploadedUrls.length + _selectedFiles.length)
                            return _buildAddFileButton();
                          if (index < _uploadedUrls.length)
                            return _buildImagePreview(_uploadedUrls[index], index);
                          return _buildFilePreview(
                              _selectedFiles[index - _uploadedUrls.length],
                              index - _uploadedUrls.length);
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
                          onPressed: _isUploading ? null : _saveStory,
                          child: _isUploading
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  widget.storyId != null ? "Update Story" : "Add Story",
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
