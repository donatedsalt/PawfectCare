import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdoptDetailPage extends StatefulWidget {
  final Map<String, dynamic> pet;

  const AdoptDetailPage({super.key, required this.pet});

  @override
  State<AdoptDetailPage> createState() => _AdoptDetailPageState();
}

class _AdoptDetailPageState extends State<AdoptDetailPage> {
  String? currentStatus;
  bool _isRequestedByMe = false;
  bool _isLoadingStatus = true; // Tracks the initial loading state

  @override
  void initState() {
    super.initState();
    _listenToPetStatus();
    _checkIfRequested();
  }

  // Listens to the pet's status in real-time.
  void _listenToPetStatus() {
    FirebaseFirestore.instance
        .collection("pets")
        .doc(widget.pet['id'])
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            final data = snapshot.data() as Map<String, dynamic>;
            if (mounted) {
              setState(() {
                currentStatus = data['status'] ?? "available";
              });
            }
          }
        });
  }

  // Checks on page load if the user has already requested this pet.
  Future<void> _checkIfRequested() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _isLoadingStatus = false;
        });
      }
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("adoptionRequests")
          .where("userId", isEqualTo: user.uid)
          .where("petId", isEqualTo: widget.pet['id'])
          .get();

      if (mounted) {
        setState(() {
          _isRequestedByMe = snapshot.docs.isNotEmpty;
        });
      }
    } catch (e) {
      // Log the error for debugging, but don't stop the app.
      print("Error checking if pet was requested: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingStatus = false;
        });
      }
    }
  }

  Future<void> _requestAdoption() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final petId = widget.pet['id'];

    try {
      // First, check the pet's current status one more time to avoid race conditions.
      final petDoc = await FirebaseFirestore.instance
          .collection("pets")
          .doc(petId)
          .get();
      if (!petDoc.exists || petDoc.data()?['status'] != 'available') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("This pet is no longer available for adoption."),
          ),
        );
        return;
      }

      await FirebaseFirestore.instance.collection("adoptionRequests").add({
        "petId": petId,
        "userId": user.uid,
        "status": "pending",
        "timestamp": FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection("pets").doc(petId).update({
        "status": "pending",
      });

      if (mounted) {
        setState(() {
          _isRequestedByMe = true;
          currentStatus = "pending";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Adoption request sent for ${widget.pet['name']}"),
          ),
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
    final pet = widget.pet;
    final List<dynamic> images = pet['images'] ?? [];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PetImageCarousel(images: images),
                  const SizedBox(height: 24),
                  PetDetailsCard(
                    pet: pet,
                    status: currentStatus,
                    isRequestedByMe: _isRequestedByMe,
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed:
                            (_isLoadingStatus ||
                                currentStatus != "available" ||
                                _isRequestedByMe)
                            ? null
                            : _requestAdoption,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: Text(
                          _isLoadingStatus
                              ? "Loading..."
                              : _isRequestedByMe
                              ? "Already Requested"
                              : currentStatus != "available"
                              ? "Status: ${currentStatus!.capitalize()}"
                              : "Request Adoption",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const BackButtonOverlay(),
          ],
        ),
      ),
    );
  }
}

/// ------------------- REUSABLE WIDGETS -------------------

class PetImageCarousel extends StatelessWidget {
  final List<dynamic> images;

  const PetImageCarousel({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Container(
        height: 280,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.pets, size: 100, color: Colors.grey),
        ),
      );
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: 320,
        enlargeCenterPage: true,
        enableInfiniteScroll: true,
        autoPlay: true,
        viewportFraction: 0.9,
      ),
      items: images.map((url) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(url, fit: BoxFit.cover, width: double.infinity),
        );
      }).toList(),
    );
  }
}

class PetDetailsCard extends StatelessWidget {
  final Map<String, dynamic> pet;
  final String? status;
  final bool isRequestedByMe;

  const PetDetailsCard({
    super.key,
    required this.pet,
    required this.status,
    required this.isRequestedByMe,
  });

  @override
  Widget build(BuildContext context) {
    String displayStatus = "loading";
    if (isRequestedByMe) {
      displayStatus = "Requested";
    } else if (status != null) {
      displayStatus = status!.capitalize();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pet['name'] ?? "Unnamed Pet",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          PetInfoRow(icon: Icons.pets, text: pet['breed'] ?? "Unknown Breed"),
          const SizedBox(height: 8),
          PetInfoRow(
            icon: Icons.cake,
            text: "${pet['age'] ?? 'N/A'} years old",
          ),
          const SizedBox(height: 16),
          const Text(
            "About",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            pet['description'] ?? "No description available for this pet.",
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Current Status: $displayStatus",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class PetInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const PetInfoRow({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 18),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}

class BackButtonOverlay extends StatelessWidget {
  const BackButtonOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      left: 16,
      child: CircleAvatar(
        backgroundColor: Colors.black12,
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}

extension StringCasing on String {
  String capitalize() =>
      isNotEmpty ? "${this[0].toUpperCase()}${substring(1)}" : this;
}
