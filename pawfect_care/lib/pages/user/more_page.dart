import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawfect_care/pages/user/request_volunteer_page.dart';

import 'package:pawfect_care/widgets/custom_app_bar.dart';
import 'package:pawfect_care/widgets/account_profile.dart';

import 'package:pawfect_care/pages/common/bug_report_page.dart';
import 'package:pawfect_care/pages/common/profile_page.dart';

import 'package:pawfect_care/pages/user/pets_page.dart';

class MorePageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MorePageAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('More'));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class MorePage extends StatelessWidget {
  const MorePage({super.key});
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Column(
      children: [
        CustomAppBar("More Options"),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // welcome user
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 64),
                child: Column(
                  children: [
                    AccountProfile(
                      user: user?.displayName,
                      imageURL: user?.photoURL,
                    ),
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
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.pets),
                    title: const Text("Pets"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PetsPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.contact_mail),
                    title: const Text("Volunteer"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RequestVolunteerPage(),
                        ),
                      );
                    },
                  ),
                  // ListTile(
                  //   leading: const Icon(Icons.notifications),
                  //   title: const Text("Notifications"),
                  //   onTap: () {},
                  // ),
                  // ListTile(
                  //   leading: const Icon(Icons.help),
                  //   title: const Text("Help & Support"),
                  //   onTap: () {},
                  // ),
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
          ),
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
