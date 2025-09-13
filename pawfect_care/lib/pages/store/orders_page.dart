import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawfect_care/widgets/custom_app_bar.dart';

class OrdersPageStore extends StatelessWidget {
  const OrdersPageStore({super.key});

  final List<String> statuses = const ['Pending', 'Shipped', 'Delivered'];

  @override

  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAppBar("Orders"),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('orders').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    "No Orders Found",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                );
              }

              final orders = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['status'] != 'Delivered';
              }).toList();

              if (orders.isEmpty) {
                return Center(
                  child: Text(
                    "No Pending / Shipped Orders",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: orders.length,
                itemBuilder: (_, index) {
                  final order = orders[index];
                  final orderId = order.id;
                  final orderData = order.data() as Map<String, dynamic>;

                  final orderNumber =
                      orderData['orderNumber'] ?? orderId.substring(0, 6);
                  final customerName = orderData['userName'] ?? "Unknown";

                  final itemCount =
                      (orderData['items'] as List<dynamic>?)?.length ?? 0;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primary.withAlpha(200),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Order #$orderNumber",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
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
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        DropdownButton<String>(
                          value: orderData['status'] ?? 'Pending',
                          dropdownColor: Theme.of(context).colorScheme.primary,
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white,
                          ),
                          underline: const SizedBox(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
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
