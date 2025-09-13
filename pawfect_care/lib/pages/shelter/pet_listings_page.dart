import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pawfect_care/pages/shelter/add_pet_page.dart';
import 'package:pawfect_care/widgets/custom_app_bar.dart';

class PetListingDetailPage extends StatelessWidget {
  const PetListingDetailPage({super.key});

  void deletePet(String docId) {
    FirebaseFirestore.instance.collection('pets').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    final petsRef = FirebaseFirestore.instance.collection('pets');

    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar("All Pets", showBack: true),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: petsRef.orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      "No pets found.",
                      style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    String? imageUrl;
                    if (data['images'] != null && (data['images'] as List).isNotEmpty) {
                      imageUrl = data['images'][0];
                    } else if (data['photoUrl'] != null && data['photoUrl'] != '') {
                      imageUrl = data['photoUrl'];
                    }

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
                            BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 6)),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          leading: imageUrl != null
                              ? Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover)
                              : const Icon(Icons.pets, size: 40, color: Colors.white),
                          title: Text(
                            data['name'] ?? "Unknown Pet",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            "Species: ${data['species'] ?? ''}, Type: ${data['type'] ?? ''}\n"
                            "Breed: ${data['breed'] ?? ''}, Age: ${data['age'] ?? ''}, Gender: ${data['gender'] ?? ''}\n"
                            "Status: ${data['status'] ?? ''}",
                            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary.withAlpha(150)),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.white),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AddPetPage(
                                        petId: doc.id,
                                        existingData: data,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text("Confirm Delete"),
                                      content: const Text("Are you sure you want to delete this pet?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            deletePet(doc.id);
                                            Navigator.pop(ctx);
                                          },
                                          child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
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
    );
  }
}
