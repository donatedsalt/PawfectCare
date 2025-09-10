import 'package:flutter/material.dart';

class AppointmentPageAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const AppointmentPageAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('Appointment'));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class AppointmentPage extends StatelessWidget {
  const AppointmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Welcome user
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text(
            "User Appointment Page",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ],
    );
  }
}

class AppointmentPageFloatingActionButton extends StatelessWidget {
  const AppointmentPageFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}

class AppointmentPageNavigationDestination extends StatelessWidget {
  const AppointmentPageNavigationDestination({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationDestination(
      icon: const Icon(Icons.local_hospital_outlined),
      selectedIcon: Icon(
        Icons.local_hospital,
        color: Theme.of(context).colorScheme.primary,
      ),
      label: "Appointment",
    );
  }
}
