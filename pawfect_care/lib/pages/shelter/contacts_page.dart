import 'package:flutter/material.dart';

import 'package:pawfect_care/widgets/custom_app_bar.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAppBar("Shelter Contacts Page"),

        Expanded(
          child: ListView(padding: const EdgeInsets.all(16), children: [
              ],
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
