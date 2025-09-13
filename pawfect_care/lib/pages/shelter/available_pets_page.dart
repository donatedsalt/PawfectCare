import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawfect_care/widgets/custom_app_bar.dart';

class AvailablePetsPage extends StatelessWidget {
  const AvailablePetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final petsRef = FirebaseFirestore.instance.collection('pets');

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar("Availible Pets", showBack: true),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: petsRef.where('status', isEqualTo: 'available').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return Center(
                      child: Text(
                        "No available pets.",
                        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.primary.withAlpha(200),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black45,
                                blurRadius: 10,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            leading: data['images'] != null && (data['images'] as List).isNotEmpty
                                ? Image.network(
                                    data['images'][0],
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.pets, size: 40, color: Colors.white),
                            title: Text(
                              data['name'] ?? "Unknown Pet",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              "${data['type'] ?? ''}, Age: ${data['age'] ?? ''}",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary.withAlpha(150),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
