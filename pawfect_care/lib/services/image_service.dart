import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// A service class to handle image picking and uploading to Firebase Storage.
class ImageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  /// Picks an image from the device's gallery.
  ///
  /// Returns a [Uint8List] containing the image bytes if an image is selected,
  /// otherwise returns `null`.
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

  /// Uploads image bytes to a specified path in Firebase Storage.
  ///
  /// Takes the image bytes as a [Uint8List] and the desired file path as a [String].
  /// The path should include the desired filename (e.g., 'profile_pictures/user123.jpg').
  /// Returns a [Future] that completes with the download URL of the uploaded image
  /// on success, or `null` on failure.
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
}
