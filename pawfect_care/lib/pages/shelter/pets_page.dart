import 'package:flutter/material.dart';

class PetsPageAppBar extends StatefulWidget implements PreferredSizeWidget {
  const PetsPageAppBar({super.key});

  @override
  State<PetsPageAppBar> createState() => _PetsPageAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _PetsPageAppBarState extends State<PetsPageAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('Pets'));
  }
}

class PetsPage extends StatelessWidget {
  const PetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Welcome user
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text(
            "Shelter Pets Page",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class PetsPageFloatingActionButton extends StatelessWidget {
  const PetsPageFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}

class PetsPageNavigationDestination extends StatelessWidget {
  const PetsPageNavigationDestination({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationDestination(
      icon: const Icon(Icons.pets_outlined),
      selectedIcon: Icon(Icons.pets),
      label: "Pets",
    );
  }
}
