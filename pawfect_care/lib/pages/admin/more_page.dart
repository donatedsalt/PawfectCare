import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:pawfect_care/pages/common/bug_report_page.dart';

class MorePageAppBar extends StatefulWidget implements PreferredSizeWidget {
  const MorePageAppBar({super.key});

  @override
  State<MorePageAppBar> createState() => _MorePageAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MorePageAppBarState extends State<MorePageAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('More'));
  }
}

class MorePage extends StatelessWidget {
  const MorePage({super.key});
  @override
  Widget build(BuildContext context) {
    // Get the current user from Firebase Auth
    final user = FirebaseAuth.instance.currentUser;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // welcome user and more icon
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 64),
          child: Text(
            "Welcome, ${user?.displayName ?? 'User'}!",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),

        // Settings header and list of settings
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Settings",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text("Notifications"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text("Help & Support"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text("Report a Bug"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BugReportPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Sign Out"),
              onTap: () {
                FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
      ],
    );
  }
}

class MorePageFloatingActionButton extends StatelessWidget {
  const MorePageFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

class MorePageNavigationDestination extends StatelessWidget {
  const MorePageNavigationDestination({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationDestination(
      icon: const Icon(Icons.more_horiz),
      selectedIcon: Icon(Icons.more),
      label: 'More',
    );
  }
}
