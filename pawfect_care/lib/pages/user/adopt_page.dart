import 'package:flutter/material.dart';

import 'package:pawfect_care/widgets/custom_app_bar.dart';

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
    return Column(
      children: [
        CustomAppBar("Start Adopting"),

        Expanded(
          child: ListView(padding: const EdgeInsets.all(16), children: [
              ],
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
      selectedIcon: Icon(Icons.favorite),
      label: "Adopt",
    );
  }
}
