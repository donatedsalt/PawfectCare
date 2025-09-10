import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomePageAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('Home'));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
            "Welcome, $userName!",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24),
          ),
        ),

        Text('Popular Products', style: TextStyle(fontSize: 16)),
        Text('Stories', style: TextStyle(fontSize: 16)),
      ],
    );
  }
}

class HomePageFloatingActionButton extends StatelessWidget {
  const HomePageFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}

class HomePageNavigationDestination extends StatelessWidget {
  const HomePageNavigationDestination({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationDestination(
      icon: const Icon(Icons.home_outlined),
      selectedIcon: Icon(
        Icons.home_rounded,
        color: Theme.of(context).colorScheme.primary,
      ),
      label: "Home",
    );
  }
}
