import 'package:firebase_auth/firebase_auth.dart';

class PasswordUpdateService {
  final _auth = FirebaseAuth.instance;

  Future<void> updatePassword({required String newPassword}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No authenticated user found.',
      );
    }
    await user.updatePassword(newPassword);
  }
}
