import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pawfect_care/pages/store/add_Product_page.dart';
import 'package:pawfect_care/pages/store/all_products_page.dart';

class BrandColors {
  static const Color primaryBlue = Color(0xFF0D1C5A);
  static const Color accentGreen = Color(0xFF32C48D);
  static const Color darkBackground = Color(0xFFD6E3FF);
  static const Color cardBlue = Color(0xFF1B2A68);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFFC5C6C7);
  static const Color fabGreen = Color(0xFF32C48D);
}

class HomePageStore extends StatelessWidget {
  const HomePageStore({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 👋 Welcome
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            "Welcome back, ${user?.displayName ?? "Store Owner"}!",
            style: const TextStyle(
              color: BrandColors.primaryBlue,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),

        // 🔹 Dynamic Summary Cards (3 cards in 2 rows)
        Row(
          children: [
            Expanded(child: _buildProductCountCard(context)),
            const SizedBox(width: 12),
            Expanded(child: _buildActiveOrderCountCard()),
          ],
        ),
        const SizedBox(height: 12),
        Row(children: [Expanded(child: _buildCompletedOrderCountCard())]),
        const SizedBox(height: 16),

        // 🔹 Only Add Product Quick Action (Full Width)
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddProductPage()),
            );
          },
          child: SizedBox(
            width: double.infinity,
            child: _quickActionCard("Add Product", Icons.add_box),
          ),
        ),
      ],
    );
  }

  /// 🔹 Product Count
  Widget _buildProductCountCard(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AllProductsPage(),
                ),
              );
            },
            child: _summaryCard("Products", 0, Icons.shopping_bag),
          );
        }
        final count = snapshot.data!.docs.length;
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AllProductsPage()),
            );
          },
          child: _summaryCard("Products", count, Icons.shopping_bag),
        );
      },
    );
  }

  /// 🔹 Active Orders (Pending + Shipped)
  Widget _buildActiveOrderCountCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _summaryCard("Active Orders", 0, Icons.receipt_long);
        }

        final activeOrders = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final status = data['status'] ?? 'Pending';
          return status != 'Delivered';
        }).toList();

        return _summaryCard(
          "Active Orders",
          activeOrders.length,
          Icons.receipt_long,
        );
      },
    );
  }

  /// 🔹 Completed Orders (Delivered only)
  Widget _buildCompletedOrderCountCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _summaryCard("Completed Orders", 0, Icons.check_circle);
        }

        final completedOrders = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final status = data['status'] ?? 'Pending';
          return status == 'Delivered';
        }).toList();

        return _summaryCard(
          "Completed Orders",
          completedOrders.length,
          Icons.check_circle,
        );
      },
    );
  }

  /// Summary Card UI
  Widget _summaryCard(String title, int count, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [BrandColors.primaryBlue, BrandColors.cardBlue],
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
      child: Column(
        children: [
          Icon(icon, size: 30, color: BrandColors.textWhite),
          const SizedBox(height: 12),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: BrandColors.textWhite,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: BrandColors.textGrey),
          ),
        ],
      ),
    );
  }

  /// Quick Action Card
  Widget _quickActionCard(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [BrandColors.primaryBlue, BrandColors.cardBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: BrandColors.accentGreen.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: BrandColors.accentGreen),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: BrandColors.textWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
