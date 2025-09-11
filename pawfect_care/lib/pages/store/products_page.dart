import 'package:flutter/material.dart';

class ProductsPageAppBar extends StatefulWidget implements PreferredSizeWidget {
  const ProductsPageAppBar({super.key});

  @override
  State<ProductsPageAppBar> createState() => _ProductsPageAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ProductsPageAppBarState extends State<ProductsPageAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('Products'));
  }
}

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Welcome user
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text(
            "Store Products Page",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class ProductsPageFloatingActionButton extends StatelessWidget {
  const ProductsPageFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}

class ProductsPageNavigationDestination extends StatelessWidget {
  const ProductsPageNavigationDestination({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationDestination(
      icon: const Icon(Icons.shopping_bag_outlined),
      selectedIcon: Icon(
        Icons.shopping_bag,
        color: Theme.of(context).colorScheme.primary,
      ),
      label: "Products",
    );
  }
}
