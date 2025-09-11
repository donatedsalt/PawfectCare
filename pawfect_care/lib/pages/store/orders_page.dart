import 'package:flutter/material.dart';

class OrdersPageAppBar extends StatefulWidget implements PreferredSizeWidget {
  const OrdersPageAppBar({super.key});

  @override
  State<OrdersPageAppBar> createState() => _OrdersPageAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _OrdersPageAppBarState extends State<OrdersPageAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('Orders'));
  }
}

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Welcome user
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text(
            "Store Orders Page",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class OrdersPageFloatingActionButton extends StatelessWidget {
  const OrdersPageFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}

class OrdersPageNavigationDestination extends StatelessWidget {
  const OrdersPageNavigationDestination({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationDestination(
      icon: const Icon(Icons.check_box_outlined),
      selectedIcon: Icon(
        Icons.check_box,
        color: Theme.of(context).colorScheme.primary,
      ),
      label: "Orders",
    );
  }
}
