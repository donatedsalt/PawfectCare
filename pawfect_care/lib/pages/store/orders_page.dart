import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawfect_care/pages/store/home_page.dart';

class OrdersPageStore extends StatelessWidget {
  const OrdersPageStore({super.key});

  // Possible statuses
  final List<String> statuses = const ['Pending', 'Shipped', 'Delivered'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🌈 Gradient Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28),
          margin: const EdgeInsets.only(bottom: 20),
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
            "Orders",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: BrandColors.textWhite,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 🔹 Orders List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('orders').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text("No Orders Found",
                      style: TextStyle(color: BrandColors.accentGreen)),
                );
              }

              // 🔥 Filter: only show orders that are NOT delivered
              final orders = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['status'] != 'Delivered';
              }).toList();

              if (orders.isEmpty) {
                return const Center(
                  child: Text("No Pending / Shipped Orders",
                      style: TextStyle(color: BrandColors.accentGreen)),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: orders.length,
                itemBuilder: (_, index) {
                  final order = orders[index];
                  final orderId = order.id;
                  final orderData = order.data() as Map<String, dynamic>;

                  // 🟢 Safe read values
                  final orderNumber =
                      orderData['orderNumber'] ?? orderId.substring(0, 6);
                  final customerName = orderData['userName'] ?? "Unknown";

                  // 🛒 Items count
                  final itemCount =
                      (orderData['items'] as List<dynamic>?)?.length ?? 0;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [BrandColors.primaryBlue, BrandColors.cardBlue],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 🟢 Show Order Info
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Order #$orderNumber",
                              style: const TextStyle(
                                color: BrandColors.textWhite,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              customerName,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Items: $itemCount",
                              style: const TextStyle(
                                color: BrandColors.accentGreen,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        // Dropdown for status update
                        DropdownButton<String>(
                          value: orderData['status'] ?? 'Pending',
                          dropdownColor: BrandColors.primaryBlue,
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Colors.white),
                          underline: const SizedBox(),
                          style: const TextStyle(
                            color: BrandColors.accentGreen,
                            fontWeight: FontWeight.w600,
                          ),
                          items: statuses.map((status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(status),
                            );
                          }).toList(),
                          onChanged: (newStatus) async {
                            if (newStatus != null) {
                              await FirebaseFirestore.instance
                                  .collection('orders')
                                  .doc(orderId)
                                  .update({'status': newStatus});
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
