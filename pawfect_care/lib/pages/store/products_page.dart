import 'package:flutter/material.dart';
import 'package:pawfect_care/pages/vet/home_page.dart';

class ProductsPageStore extends StatelessWidget {
  const ProductsPageStore({super.key});

  final List<Map<String, dynamic>> products = const [
    {'name': 'Dog Bone', 'price': 12.99},
    {'name': 'Cat Food', 'price': 29.50},
    {'name': 'Bird Cage', 'price': 85.00},
    {'name': 'Fish Tank', 'price': 120.00},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: products.length,
      itemBuilder: (_, index) {
        final product = products[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [BrandColors.primaryBlue, BrandColors.cardBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_bag,
                  size: 36, color: BrandColors.accentGreen),
              const SizedBox(height: 8),
              Text(product['name'],
                  style: const TextStyle(
                      color: BrandColors.textWhite,
                      fontWeight: FontWeight.bold)),
              Text("\$${product['price']}",
                  style: const TextStyle(color: BrandColors.textGrey)),
            ],
          ),
        );
      },
    );
  }
}
