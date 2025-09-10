import 'package:flutter/material.dart';

class AccountProfile extends StatelessWidget {
  const AccountProfile({super.key, required this.user, this.imageURL});

  final String? user;
  final String? imageURL;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 48,
      foregroundImage: imageURL != null ? NetworkImage(imageURL!) : null,
      child: Text(
        user != null && user!.isNotEmpty ? user![0].toUpperCase() : 'U',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 32,
        ),
      ),
    );
  }
}
