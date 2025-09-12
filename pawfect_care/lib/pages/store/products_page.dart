import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawfect_care/pages/vet/home_page.dart';

class ProductsDetailPage extends StatelessWidget {
  const ProductsDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final productsRef = FirebaseFirestore.instance.collection('products');

    return Scaffold(
      backgroundColor: BrandColors.darkBackground,
      body: Column(
        children: [
          // 🌈 Gradient Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [BrandColors.accentGreen, BrandColors.primaryBlue],
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
            child: const Text(
              "All Products",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: BrandColors.textWhite,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 📋 Products Grid
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: productsRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      "Error fetching products",
                      style: TextStyle(color: BrandColors.textWhite),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No products found.",
                      style: TextStyle(color: BrandColors.textWhite),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;

                    final String? name = data['name'];
                    final String? price = data['price']?.toString();
                    final String? imageUrl = data['images'];

                    return Card(
                      color: BrandColors.cardBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          // TODO: Navigate to Product Detail Page
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // 🖼️ Product Image
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(14),
                                ),
                                child: imageUrl != null && imageUrl.isNotEmpty
                                    ? Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        loadingBuilder:
                                            (context, child, progress) {
                                              if (progress == null)
                                                return child;
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            },
                                        errorBuilder: (context, error, stack) {
                                          return const Icon(
                                            Icons.broken_image,
                                            color: BrandColors.accentGreen,
                                            size: 60,
                                          );
                                        },
                                      )
                                    : const Icon(
                                        Icons.shopping_bag,
                                        color: BrandColors.accentGreen,
                                        size: 60,
                                      ),
                              ),
                            ),

                            // 📝 Product Info
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text(
                                    name ?? 'Unnamed',
                                    style: const TextStyle(
                                      color: BrandColors.textWhite,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    price != null ? "\$$price" : "No price",
                                    style: const TextStyle(
                                      color: BrandColors.textGrey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
