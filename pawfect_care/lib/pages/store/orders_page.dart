import 'package:flutter/material.dart';
import 'package:pawfect_care/pages/vet/home_page.dart';

class OrdersPageStore extends StatelessWidget {
  const OrdersPageStore({super.key});

  final List<Map<String, dynamic>> orders = const [
    {'id': '#001', 'status': 'Pending'},
    {'id': '#002', 'status': 'Shipped'},
    {'id': '#003', 'status': 'Delivered'},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: orders.length,
      itemBuilder: (_, index) {
        final order = orders[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [BrandColors.primaryBlue, BrandColors.cardBlue]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order['id'],
                  style: const TextStyle(
                      color: BrandColors.textWhite,
                      fontWeight: FontWeight.bold)),
              Text(order['status'],
                  style: const TextStyle(
                      color: BrandColors.accentGreen,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        );
      },
    );
  }
}
