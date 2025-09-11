import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawfect_care/pages/vet/CalendarPage.dart';
import 'package:pawfect_care/pages/vet/PatientMedicalRecordsPage.dart';

/// 🎨 Brand Colors (HomePage theme)
class BrandColors {
  static const Color primaryBlue = Color(0xFF0D1C5A);
  static const Color accentGreen = Color(0xFF32C48D);
  static const Color darkBackground = Color.fromARGB(255, 196, 255, 232);
  static const Color cardBlue = Color(0xFF1B2A68);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFFC5C6C7);
  static const Color fabGreen = Color(0xFF32C48D);
}

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: BrandColors.darkBackground,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🌈 Gradient Header with Back Button
          Stack(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [BrandColors.accentGreen, BrandColors.primaryBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    "Profile & Settings",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: BrandColors.textWhite,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Profile Card
          Card(
            color: BrandColors.cardBlue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? const Icon(Icons.person, size: 40, color: BrandColors.textWhite)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? "No Name",
                          style: const TextStyle(
                            color: BrandColors.textWhite,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? "No Email",
                          style: const TextStyle(color: BrandColors.textGrey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          
          const SizedBox(height: 24),

          // Settings Section
          _buildSectionTitle(context, "Settings"),
          _buildOptionCard(
            context,
            icon: Icons.settings,
            title: "App Settings",
            onTap: () {},
          ),
          _buildOptionCard(
            context,
            icon: Icons.notifications,
            title: "Notifications",
            onTap: () {},
          ),
          _buildOptionCard(
            context,
            icon: Icons.info,
            title: "About",
            onTap: () {},
          ),
          _buildOptionCard(
            context,
            icon: Icons.logout,
            title: "Logout",
            iconColor: Colors.red,
            textColor: Colors.red,
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, "/login");
              }
            },
          ),
        ],
      ),
      floatingActionButton: const MorePageFloatingActionButton(),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
            color: BrandColors.accentGreen,
            fontSize: 16,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = BrandColors.accentGreen,
    Color textColor = BrandColors.textWhite,
  }) {
    return Card(
      color: BrandColors.cardBlue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: TextStyle(color: textColor)),
        trailing: const Icon(Icons.arrow_forward_ios, color: BrandColors.textGrey, size: 16),
        onTap: onTap,
      ),
    );
  }
}

// ✅ FAB for MorePage
class MorePageFloatingActionButton extends StatelessWidget {
  const MorePageFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: BrandColors.fabGreen,
      child: const Icon(Icons.edit),
      onPressed: () {
        // Show bottom sheet with quick actions
        showModalBottomSheet(
          context: context,
          backgroundColor: BrandColors.cardBlue,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.person, color: BrandColors.textWhite),
                    title: const Text("Edit Profile", style: TextStyle(color: BrandColors.textWhite)),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Edit Profile clicked")),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.pets, color: BrandColors.textWhite),
                    title: const Text("Add New Pet", style: TextStyle(color: BrandColors.textWhite)),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Add New Pet clicked")),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
