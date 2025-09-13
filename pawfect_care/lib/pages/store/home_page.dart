import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pawfect_care/widgets/custom_app_bar.dart';
import 'package:pawfect_care/widgets/custom_card.dart';

import 'package:pawfect_care/pages/store/add_product_page.dart';

class HomePageStore extends StatelessWidget {
  const HomePageStore({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Column(
      children: [
        CustomAppBar("Welcome, ${user?.displayName ?? "Store Owner"}."),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(child: _buildProductCountCard(context)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildActiveOrderCountCard()),
                ],
              ),
              const SizedBox(height: 16),
              Row(children: [Expanded(child: _buildCompletedOrderCountCard())]),
              const SizedBox(height: 16),

              CustomCard(
                type: CustomCardType.quickAction,
                title: "Add Product",
                icon: Icons.add_box,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddProductPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Product Count Card
  Widget _buildProductCountCard(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return CustomCard(
          type: CustomCardType.summary,
          title: "Products",
          count: count,
          icon: Icons.shopping_bag,
        );
      },
    );
  }

  /// Active Orders Card
  Widget _buildActiveOrderCountCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (context, snapshot) {
        final activeOrders = snapshot.hasData
            ? snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return (data['status'] ?? 'Pending') != 'Delivered';
              }).toList()
            : [];

        return CustomCard(
          type: CustomCardType.summary,
          title: "Active Orders",
          count: activeOrders.length,
          icon: Icons.receipt_long,
        );
      },
    );
  }

  /// Completed Orders Card
  Widget _buildCompletedOrderCountCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (context, snapshot) {
        final completedOrders = snapshot.hasData
            ? snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return (data['status'] ?? 'Pending') == 'Delivered';
              }).toList()
            : [];

        return CustomCard(
          type: CustomCardType.summary,
          title: "Completed Orders",
          count: completedOrders.length,
          icon: Icons.check_circle,
        );
      },
    );
  }
}
