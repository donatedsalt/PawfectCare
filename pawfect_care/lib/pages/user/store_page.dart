import 'package:flutter/material.dart';

class StorePageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const StorePageAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('Store'));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class StorePage extends StatelessWidget {
  const StorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text(
            "User Store Page",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ],
    );
  }
}

class StorePageFloatingActionButton extends StatelessWidget {
  const StorePageFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}

class StorePageNavigationDestination extends StatelessWidget {
  const StorePageNavigationDestination({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationDestination(
      icon: const Icon(Icons.shopping_bag_outlined),
      selectedIcon: Icon(
        Icons.shopping_bag,
        color: Theme.of(context).colorScheme.primary,
      ),
      label: "Store",
    );
  }
}
