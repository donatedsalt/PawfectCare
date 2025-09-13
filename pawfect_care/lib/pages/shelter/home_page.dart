import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawfect_care/pages/shelter/add_pet_page.dart';
import 'package:pawfect_care/pages/shelter/available_pets_page.dart';
import 'package:pawfect_care/pages/shelter/pet_listings_page.dart';
import 'package:pawfect_care/widgets/custom_app_bar.dart';
import 'package:pawfect_care/widgets/custom_card.dart';

class PetListingsPage extends StatelessWidget {
  const PetListingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("Please log in first."));
    }

    final userId = user.uid;
    final userName = user.displayName ?? 'User';

    return Scaffold(
      body: Column(
        children: [
          CustomAppBar("Welcome, $userName!"),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildTotalPetsCard(context),
                const SizedBox(height: 16),
                _buildAvailablePetsCard(context),
                const SizedBox(height: 16),
                CustomCard(
                  type: CustomCardType.quickAction,
                  title: "Add Pet",
                  icon: Icons.add,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddPetPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Total pets (all pets count)
  Widget _buildTotalPetsCard(BuildContext context) {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('pets').snapshots(),
    builder: (context, snapshot) {
      final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
      return CustomCard(
        type: CustomCardType.summary,
        title: "Total Pets",
        count: count,
        icon: Icons.pets,
        onTap: () {
          // Navigate to Pet Listings Page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PetListingDetailPage()),
          );
        },
      );
    },
  );
}


  Widget _buildAvailablePetsCard(BuildContext context) {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('pets')
        .where('status', isEqualTo: 'available')
        .snapshots(),
    builder: (context, snapshot) {
      final availableCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
      return CustomCard(
        type: CustomCardType.summary,
        title: "Available for Adoption",
        count: availableCount,
        icon: Icons.pets_outlined,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AvailablePetsPage()),
          );
        },
      );
    },
  );
  }
}
