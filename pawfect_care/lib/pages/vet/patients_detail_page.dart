import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pawfect_care/pages/vet/home_page.dart';

class PatientsDetailPage extends StatelessWidget {
  const PatientsDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final patientsRef = FirebaseFirestore.instance.collection('patients');

    return Scaffold(
      backgroundColor: BrandColors.darkBackground,
      body: Column(
        children: [
          // 🌈 Gradient Header with Back Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withAlpha(200),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back,
                    color: BrandColors.textWhite,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  "All Patients",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: BrandColors.textWhite,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 📋 Patients List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: patientsRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No patients found.",
                      style: TextStyle(color: BrandColors.textWhite),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;

                    return Card(
                      color: BrandColors.cardBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 4,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: BrandColors.accentGreen.withOpacity(
                            0.3,
                          ),
                          child: const Icon(
                            Icons.pets,
                            color: BrandColors.textWhite,
                          ),
                        ),
                        title: Text(
                          data['petName'],
                          style: const TextStyle(
                            color: BrandColors.textWhite,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          "Owner: ${data['ownerName']}",
                          style: const TextStyle(color: BrandColors.textGrey),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: BrandColors.textGrey,
                          size: 16,
                        ),
                        onTap: () {
                          // Optional: Navigate to patient detail page
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
