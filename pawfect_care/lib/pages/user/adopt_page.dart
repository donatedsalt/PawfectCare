import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdoptPageAppBar extends StatefulWidget implements PreferredSizeWidget {
  const AdoptPageAppBar({super.key});

  @override
  State<AdoptPageAppBar> createState() => _AdoptPageAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AdoptPageAppBarState extends State<AdoptPageAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('Adopt'));
  }
}

class AdoptPage extends StatelessWidget {
  const AdoptPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'User';

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Welcome user
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0),
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
      icon: const Icon(CupertinoIcons.heart),
      selectedIcon: Icon(
        CupertinoIcons.heart_fill,
        color: Theme.of(context).colorScheme.primary,
      ),
      label: "Adopt",
    );
  }
}
