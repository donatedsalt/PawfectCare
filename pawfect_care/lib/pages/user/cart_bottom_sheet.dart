import 'package:flutter/material.dart';
import 'brand_colors.dart';

class CartBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final VoidCallback onCheckout;
  final VoidCallback onCartUpdated;

  const CartBottomSheet({
    super.key,
    required this.cart,
    required this.onCheckout,
    required this.onCartUpdated,
  });

  @override
  State<CartBottomSheet> createState() => _CartBottomSheetState();
}

class _CartBottomSheetState extends State<CartBottomSheet> {
  void increaseQuantity(int index) {
    setState(() {
      widget.cart[index]['quantity'] += 1;
    });
    widget.onCartUpdated();
  }

  void decreaseQuantity(int index) {
    setState(() {
      if (widget.cart[index]['quantity'] > 1) {
        widget.cart[index]['quantity'] -= 1;
      } else {
        widget.cart.removeAt(index);
      }
    });
    widget.onCartUpdated();
  }

  void removeItem(int index) {
    setState(() {
      widget.cart.removeAt(index);
    });
    widget.onCartUpdated();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.cart.fold<double>(
      0,
      (sum, item) =>
          sum + (item['price'] as num).toDouble() * (item['quantity'] as int),
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("🛒 Your Cart",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Divider(),

          if (widget.cart.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text("Your cart is empty 🛒",
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
            )
          else
            ...List.generate(widget.cart.length, (index) {
              final item = widget.cart[index];
              return ListTile(
                leading: const Icon(Icons.pets, color: BrandColors.primaryBlue),
                title: Text(item['name']),
                subtitle: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => decreaseQuantity(index),
                    ),
                    Text("x${item['quantity']}"),
                    IconButton(
                      icon: const Icon(Icons.add_circle,
                          color: BrandColors.accentGreen),
                      onPressed: () => increaseQuantity(index),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "\$${(item['price'] * item['quantity']).toString()}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.delete, color: Colors.black54),
                      onPressed: () => removeItem(index),
                    ),
                  ],
                ),
              );
            }),

          if (widget.cart.isNotEmpty) ...[
            const Divider(),
            Text("Total: \$${total.toStringAsFixed(2)}",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                widget.onCheckout();
              },
              icon: const Icon(Icons.check_circle, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: BrandColors.accentGreen,
              ),
              label: const Text("Checkout"),
            ),
          ],
        ],
      ),
    );
  }
}
