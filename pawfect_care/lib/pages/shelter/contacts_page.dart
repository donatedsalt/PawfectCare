import 'package:flutter/material.dart';

class ContactsPageAppBar extends StatefulWidget implements PreferredSizeWidget {
  const ContactsPageAppBar({super.key});

  @override
  State<ContactsPageAppBar> createState() => ContactsPageAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ContactsPageAppBarState extends State<ContactsPageAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('Contacts'));
  }
}

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Welcome user
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text(
            "Shelter Contacts Page",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class ContactsPageFloatingActionButton extends StatelessWidget {
  const ContactsPageFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}

class ContactsPageNavigationDestination extends StatelessWidget {
  const ContactsPageNavigationDestination({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationDestination(
      icon: const Icon(Icons.contact_support_outlined),
      selectedIcon: Icon(Icons.contact_support),
      label: "Contacts",
    );
  }
}
