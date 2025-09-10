import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:pawfect_care/widgets/account_profile.dart';

import 'package:pawfect_care/pages/user/profile_page.dart';

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
    final user = FirebaseAuth.instance.currentUser;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // welcome user
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 64),
          child: Column(
            children: [
              AccountProfile(user: user?.displayName, imageURL: user?.photoURL),
              SizedBox(height: 16),
              Text(
                "Welcome, ${user?.displayName ?? 'User'}!",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24),
              ),
            ],
          ),
        ),

        // Settings header and list of settings
        Column(
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
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
              onTap: () {},
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
      selectedIcon: Icon(
        Icons.more,
        color: Theme.of(context).colorScheme.primary,
      ),
      label: 'More',
    );
  }
}
