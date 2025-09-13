import 'package:flutter/material.dart';

import 'package:pawfect_care/widgets/custom_app_bar.dart';

class PetsPage extends StatelessWidget {
  const PetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAppBar("Shelter Pets Page"),

        Expanded(
          child: ListView(padding: const EdgeInsets.all(16), children: [
              ],
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
