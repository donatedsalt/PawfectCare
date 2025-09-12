import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pawfect_care/utils/context_extension.dart';

import 'package:pawfect_care/pages/user/brand_colors.dart';
import 'package:pawfect_care/pages/user/product_detail_page.dart';
import 'package:pawfect_care/pages/user/cart_bottom_sheet.dart';

class StorePageFloatingActionButton extends StatelessWidget {
  final int itemCount;
  final VoidCallback onPressed;

  const StorePageFloatingActionButton({
    super.key,
    required this.itemCount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      onPressed: onPressed,
      label: Text("Cart ($itemCount)"),
      icon: const Icon(Icons.shopping_cart),
    );
  }
}

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  final List<Map<String, dynamic>> cart = [];
  String searchQuery = "";
  String selectedCategory = "All";
  double minPrice = 0;
  double maxPrice = 10000;

  List<String> categories = ["All"];

  void addToCart(Map<String, dynamic> product) {
    setState(() {
      final index = cart.indexWhere((item) => item['id'] == product['id']);
      if (index >= 0) {
        cart[index]['quantity'] += 1;
      } else {
        cart.add({...product, 'quantity': 1});
      }
    });

    context.showSnackBar("${product['name']} added to cart");
  }

  Future<void> checkout() async {
    if (cart.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? "Anonymous";
    final userId = user?.uid ?? "guest";

    final orderData = {
      "userId": userId,
      "userName": userName,
      "items": cart,
      "status": "Pending",
      "createdAt": FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection("orders").add(orderData);

    setState(() => cart.clear());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Order placed successfully!")),
      );
    }
  }

  int get cartItemCount {
    return cart.fold<int>(0, (acc, item) => acc + (item['quantity'] as int));
  }

  void openCart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) => CartBottomSheet(
        cart: cart,
        onCheckout: checkout,
        onCartUpdated: () => setState(() {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // appbar type thing
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withAlpha(200),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "🛍 Store",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Search products...",
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(14),
                    ),
                    onChanged: (value) {
                      setState(
                        () => searchQuery = value.toLowerCase(),
                      ); // live filter
                    },
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("products")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                        final cats = <String>{"All"};
                        for (var doc in snapshot.data!.docs) {
                          final data = doc.data() as Map<String, dynamic>;
                          final cat = data['category'] as String?;
                          if (cat != null && cat.isNotEmpty) cats.add(cat);
                        }
                        categories = cats.toList()..sort();
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedCategory,
                            isExpanded: true,
                            items: categories
                                .map(
                                  (cat) => DropdownMenuItem(
                                    value: cat,
                                    child: Text(cat),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(
                                  () => selectedCategory = value,
                                ); // live filter
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _showPriceFilterDialog(),
                  icon: const Icon(Icons.filter_alt),
                  label: const Text("Filter"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BrandColors.accentGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 📦 Products Grid
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("products")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No products available"));
                }

                final products = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? "").toString().toLowerCase();
                  final category = (data['category'] ?? "").toString();
                  final price = (data['price'] ?? 0).toDouble();

                  final matchesSearch = name.contains(searchQuery);
                  final matchesCategory =
                      selectedCategory == "All" || category == selectedCategory;
                  final matchesPrice = price >= minPrice && price <= maxPrice;

                  return matchesSearch && matchesCategory && matchesPrice;
                }).toList();

                if (products.isEmpty) {
                  return const Center(child: Text("No matching products"));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: products.length,
                  itemBuilder: (_, index) {
                    final productData =
                        products[index].data() as Map<String, dynamic>;
                    final product = {"id": products[index].id, ...productData};

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailPage(
                              product: product,
                              onAddToCart: addToCart,
                            ),
                          ),
                        );
                      },
                      child: _buildProductCard(product),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: StorePageFloatingActionButton(
        itemCount: cartItemCount,
        onPressed: openCart,
      ),
    );
  }

  /// 🔥 Price Filter Dialog (live sliders)
  void _showPriceFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text("Filter by Price"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Min: \$${minPrice.toStringAsFixed(0)}"),
                  Slider(
                    value: minPrice,
                    min: 0,
                    max: 5000,
                    divisions: 100,
                    label: minPrice.toStringAsFixed(0),
                    onChanged: (value) {
                      setDialogState(() => minPrice = value);
                      setState(() {}); // live update
                    },
                  ),
                  Text("Max: \$${maxPrice.toStringAsFixed(0)}"),
                  Slider(
                    value: maxPrice,
                    min: 100,
                    max: 10000,
                    divisions: 100,
                    label: maxPrice.toStringAsFixed(0),
                    onChanged: (value) {
                      setDialogState(() => maxPrice = value);
                      setState(() {}); // live update
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// 🔥 Product Card
  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: _buildProductImage(product),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? "Unnamed",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "\$${product['price'] ?? 0}",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),

                /// 👇 Full-width button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BrandColors.accentGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => addToCart(product),
                    icon: const Icon(
                      Icons.add_shopping_cart,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Add to Cart",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(Map<String, dynamic> product) {
    final List<dynamic>? images = product['images'];
    final String? imageUrl = (images != null && images.isNotEmpty)
        ? images.first.toString()
        : null;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity);
    } else {
      return const Center(
        child: Icon(Icons.shopping_bag, color: Colors.green, size: 70),
      );
    }
  }
}
