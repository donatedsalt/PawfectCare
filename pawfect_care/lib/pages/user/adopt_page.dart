import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdoptPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AdoptPageAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('Adopt'));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class AdoptPage extends StatelessWidget {
  const AdoptPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'User';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Welcome user
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text(
            "Welcome, $userName! User Adopt Page",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ],
    );
  }
}

class AdoptPageFloatingActionButton extends StatelessWidget {
  const AdoptPageFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}

class AdoptPageNavigationDestination extends StatelessWidget {
  const AdoptPageNavigationDestination({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationDestination(
      icon: const Icon(Icons.favorite_outline),
      selectedIcon: Icon(
        Icons.favorite,
        color: Theme.of(context).colorScheme.primary,
      ),
      label: "Adopt",
    );
  }
}
