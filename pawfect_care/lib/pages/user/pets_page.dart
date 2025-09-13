import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pawfect_care/widgets/custom_app_bar.dart';

import 'package:pawfect_care/pages/user/add_pet_page.dart';
import 'package:pawfect_care/pages/user/edit_pet_page.dart';

class PetsPage extends StatefulWidget {
  const PetsPage({super.key});

  @override
  State<PetsPage> createState() => _PetsPageState();
}

class _PetsPageState extends State<PetsPage> {
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  Future<void> _deletePet(String petId) async {
    if (userId == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('pets')
        .doc(petId)
        .delete();
  }

  Future<bool?> _confirmDelete(BuildContext context, String petName) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Pet"),
        content: Text("Are you sure you want to delete $petName?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          FilledButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                Theme.of(context).colorScheme.error,
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120),
        child: CustomAppBar("My Pet", showBack: true),
      ),
      body: userId == null
          ? const Center(child: Text('Please sign in to view your pets.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('pets')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'You have no pets added yet.\nTap the + button to add one!',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final pets = snapshot.data!.docs;
                return SafeArea(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: pets.length,
                    itemBuilder: (context, index) {
                      final pet = pets[index].data() as Map<String, dynamic>;
                      final petId = pets[index].id;
                      final petName = pet['name'] ?? 'this pet';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Dismissible(
                          key: Key(petId),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            final confirm = await _confirmDelete(
                              context,
                              petName,
                            );
                            if (confirm == true) {
                              await _deletePet(petId);
                              return true;
                            }
                            return false;
                          },
                          child: _PetCard(pet: pet, petId: petId),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPetPage()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Pet"),
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  const _PetCard({required this.pet, required this.petId});

  final Map<String, dynamic> pet;
  final String petId;

  @override
  Widget build(BuildContext context) {
    final petName = pet['name'] ?? 'Unknown';
    final petSpecies = pet['species'] ?? 'Unknown';
    final petBreed = pet['breed'] ?? 'Unknown';
    final petPhotoUrl = pet['photoUrl'] as String?;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditPetPage(petId: petId, pet: pet),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pet image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Container(
                width: 120,
                height: 120,
                color: Colors.grey[200],
                child: petPhotoUrl != null
                    ? Image.network(
                        petPhotoUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.pets,
                              size: 50,
                              color: Colors.grey,
                            ),
                      )
                    : const Icon(Icons.pets, size: 50, color: Colors.grey),
              ),
            ),

            // Pet details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          petName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditPetPage(petId: petId, pet: pet),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text("Edit"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.category,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(petSpecies, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.pets, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(petBreed, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
