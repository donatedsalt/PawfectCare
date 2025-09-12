import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawfect_care/pages/store/add_product_page.dart';
import 'package:pawfect_care/pages/vet/home_page.dart';

class HomePageStore extends StatelessWidget {
  const HomePageStore({super.key});

  static final List<Map<String, dynamic>> quickActions = [
    {'title': 'Add Product', 'icon': Icons.add_box},
    {'title': 'New Order', 'icon': Icons.shopping_cart},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 🔹 Dynamic Summary Cards
        Row(
          children: [
            Expanded(child: _buildProductCountCard()),
            const SizedBox(width: 12),
            Expanded(child: _buildOrderCountCard()),
          ],
        ),
        const SizedBox(height: 16),

        // 🔹 Quick Actions
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: quickActions.map((action) {
            return GestureDetector(
              onTap: () {
                if (action['title'] == 'Add Product') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddProductPage()),
                  );
                }
                // Future: New Order page
              },
              child: _quickActionCard(action['title'], action['icon']),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 🔹 Product Count
  Widget _buildProductCountCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _summaryCard("Products", 0, Icons.shopping_bag);
        }
        final count = snapshot.data!.docs.length;
        return _summaryCard("Products", count, Icons.shopping_bag);
      },
    );
  }

  /// 🔹 Order Count
  Widget _buildOrderCountCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _summaryCard("Orders", 0, Icons.receipt_long);
        }
        final count = snapshot.data!.docs.length;
        return _summaryCard("Orders", count, Icons.receipt_long);
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
          BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 6))
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: BrandColors.textWhite),
          const SizedBox(height: 12),
          Text('$count',
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: BrandColors.textWhite)),
          const SizedBox(height: 6),
          Text(title,
              style:
                  const TextStyle(fontSize: 14, color: BrandColors.textGrey)),
        ],
      ),
    );
  }

  /// Quick Action Card
  Widget _quickActionCard(String title, IconData icon) {
    return Container(
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
              spreadRadius: 1)
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: BrandColors.accentGreen),
          const SizedBox(height: 10),
          Text(title,
              style: const TextStyle(
                  color: BrandColors.textWhite, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
