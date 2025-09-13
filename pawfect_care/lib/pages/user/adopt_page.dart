import 'adopt_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawfect_care/widgets/custom_app_bar.dart';

class AdoptPage extends StatefulWidget {
  const AdoptPage({super.key});

  @override
  State<AdoptPage> createState() => _AdoptPageState();
}

class _AdoptPageState extends State<AdoptPage> {
  String searchQuery = "";
  String selectedCategory = "All";
  List<String> categories = ["All"];
  Set<String> requestedPets = {};

  @override
  void initState() {
    super.initState();
    _loadUserRequests();
  }

  Future<void> _loadUserRequests() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection("adoptionRequests")
        .where("userId", isEqualTo: user.uid)
        .get();

    if (mounted) {
      setState(() {
        requestedPets = snapshot.docs
            .map((doc) => doc['petId'] as String)
            .toSet();
      });
    }
  }

  Future<void> _requestAdoption(String petId, String petName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection("adoptionRequests").add({
        "petId": petId,
        "userId": user.uid,
        "status": "requested",
        "timestamp": FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection("pets").doc(petId).update({
        "status": "requested",
      });

      // We also add a `mounted` check here for safety.
      if (mounted) {
        setState(() => requestedPets.add(petId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Adoption request sent for $petName")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error sending request: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CustomAppBar("Start Adopting"),
        const SizedBox(height: 8),
        _buildSearchAndFilter(),
        Expanded(child: _buildPetGrid()),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(child: _buildSearchField()),
          const SizedBox(width: 12),
          Expanded(child: _buildCategoryDropdown()),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3)),
        ],
      ),
      child: TextField(
        decoration: const InputDecoration(
          hintText: "Search pets...",
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(14),
        ),
        onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3)),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCategory,
          isExpanded: true,
          items: categories
              .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
              .toList(),
          onChanged: (value) {
            if (value != null) setState(() => selectedCategory = value);
          },
        ),
      ),
    );
  }

  Widget _buildPetGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('pets').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No pets available for adoption"));
        }

        final docs = snapshot.data!.docs;

        // Extract categories dynamically
        final catSet = <String>{"All"};
        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final type = data['type'] as String?;
          if (type != null && type.isNotEmpty) catSet.add(type);
        }
        categories = catSet.toList()..sort();

        // Filter pets by search, category, and availability
        final pets = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['name'] ?? "").toString().toLowerCase();
          final type = (data['type'] ?? "").toString();
          final status = (data['status'] ?? "available").toString();

          final matchesSearch = name.contains(searchQuery);
          final matchesCategory =
              selectedCategory == "All" || type == selectedCategory;
          final isAvailable = status != "adopted";

          return matchesSearch && matchesCategory && isAvailable;
        }).toList();

        if (pets.isEmpty) return const Center(child: Text("No matching pets"));

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.7,
          ),
          itemCount: pets.length,
          itemBuilder: (context, index) {
            final petData = pets[index].data() as Map<String, dynamic>;
            final pet = {'id': pets[index].id, ...petData};
            return _PetCard(
              pet: pet,
              alreadyRequested: requestedPets.contains(pet['id']),
              onAdoptPressed: () => _requestAdoption(pet['id'], pet['name']),
            );
          },
        );
      },
    );
  }
}

class _PetCard extends StatelessWidget {
  final Map<String, dynamic> pet;
  final bool alreadyRequested;
  final VoidCallback onAdoptPressed;

  const _PetCard({
    required this.pet,
    required this.alreadyRequested,
    required this.onAdoptPressed,
  });

  @override
  Widget build(BuildContext context) {
    final List<dynamic>? images = pet['images'];
    final String? imageUrl = (images != null && images.isNotEmpty)
        ? images.first.toString()
        : null;
    final status = pet['status'] ?? 'available';
    final bool isAdopted = status == 'adopted';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AdoptDetailPage(pet: pet)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : const Center(
                        child: Icon(Icons.pets, color: Colors.green, size: 60),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet['name'] ?? 'Unnamed',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${pet['breed'] ?? 'Unknown breed'} • ${pet['age'] ?? '?'} yrs",
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isAdopted || alreadyRequested
                          ? null
                          : onAdoptPressed,
                      icon: const Icon(Icons.pets, size: 18),
                      label: Text(
                        isAdopted
                            ? 'Adopted'
                            : alreadyRequested
                            ? 'Requested'
                            : 'Adopt',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAdopted
                            ? Colors.red
                            : alreadyRequested
                            ? Colors.grey
                            : Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdoptPageNavigationDestination extends StatelessWidget {
  const AdoptPageNavigationDestination({super.key});

  @override
  Widget build(BuildContext context) => const NavigationDestination(
    icon: Icon(Icons.favorite_outline),
    selectedIcon: Icon(Icons.favorite),
    label: "Adopt",
  );
}
