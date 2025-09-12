import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// A service class to handle image picking and uploading to Firebase Storage.
class ImageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  /// Picks an image from the device's gallery.
  Future<Uint8List?> pickImageFromGallery() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        return await pickedFile.readAsBytes();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image from gallery: $e');
      }
    }
    return null;
  }

  /// Picks an image using the camera.
  Future<Uint8List?> pickImageFromCamera() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        return await pickedFile.readAsBytes();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image from camera: $e');
      }
    }
    return null;
  }

  /// Picks multiple images from the gallery.
  Future<List<Uint8List>> pickMultipleImages() async {
    final List<Uint8List> images = [];
    try {
      final pickedFiles = await _picker.pickMultiImage();
      for (var file in pickedFiles) {
        final bytes = await file.readAsBytes();
        images.add(bytes);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking multiple images: $e');
      }
    }
    return images;
  }

  /// Uploads image bytes to Firebase Storage and returns the download URL.
  Future<String?> uploadImageToFirebase(
    Uint8List imageBytes,
    String path,
  ) async {
    try {
      final storageRef = _storage.ref().child(path);
      final uploadTask = storageRef.putData(imageBytes);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading image to Firebase: $e');
      }
      return null;
    }
  }

  /// Deletes an image from Firebase Storage by its path.
  Future<bool> deleteImageFromFirebase(String path) async {
    try {
      final storageRef = _storage.ref().child(path);
      await storageRef.delete();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting image from Firebase: $e');
      }
      return false;
    }
  }
}
