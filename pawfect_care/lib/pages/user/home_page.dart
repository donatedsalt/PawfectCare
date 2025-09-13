import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pawfect_care/widgets/custom_app_bar.dart';

import 'package:pawfect_care/pages/user/product_detail_page.dart';
import 'package:pawfect_care/pages/user/store_page.dart';

// Product Grid Item (Dynamic & Tappable)
class _ProductGridItem extends StatelessWidget {
  final String productId;
  final String name;
  final String imageUrl;
  final double price;
  final Map<String, dynamic> fullData;

  const _ProductGridItem({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.fullData,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(
              product: fullData,
              onAddToCart: (product) {
                // Handle adding to cart here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${product['name']} added to cart")),
                );
              },
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: imageUrl.isNotEmpty
                    ? Image.network(imageUrl, fit: BoxFit.cover)
                    : Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.green),
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

// Main HomePage
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'User';

    return Column(
      children: [
        CustomAppBar("Welcome, $userName!"),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Popular Products Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Popular Products',
                    style: TextStyle(fontSize: 18),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const StorePage()),
                      );
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 480,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('products')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final products = snapshot.data!.docs;
                    if (products.isEmpty) {
                      return const Center(
                        child: Text('No products available.'),
                      );
                    }

                    return GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      physics: const NeverScrollableScrollPhysics(),
                      children: products.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final List<dynamic>? images = data['images'];
                        final String imageUrl =
                            (images != null && images.isNotEmpty)
                            ? images.first.toString()
                            : '';

                        return _ProductGridItem(
                          productId: doc.id,
                          name: data['name'] ?? 'No Name',
                          imageUrl: imageUrl,
                          price: (data['price'] ?? 0).toDouble(),
                          fullData: data,
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class HomePageNavigationDestination extends StatelessWidget {
  const HomePageNavigationDestination({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationDestination(
      icon: const Icon(Icons.home_outlined),
      selectedIcon: const Icon(Icons.home_rounded),
      label: "Home",
    );
  }
}
