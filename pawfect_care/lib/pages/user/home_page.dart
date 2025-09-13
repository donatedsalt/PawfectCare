import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawfect_care/pages/store/home_page.dart';
import 'package:pawfect_care/pages/user/product_detail_page.dart';
import 'package:pawfect_care/pages/user/store_page.dart';
import 'package:pawfect_care/widgets/custom_app_bar.dart';

class HomePageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomePageAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('Home'));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _GridSection extends StatelessWidget {
  final String title;
  final Widget child;
  final double height;

  const _GridSection({
    required this.title,
    required this.child,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 16),
        SizedBox(height: height, child: child),
      ],
    );
  }
}

// Product Grid Item (Dynamic & Tappable)
class _ProductGridItem extends StatelessWidget {
  final String productId;
  final String name;
  final String imageUrl;
  final double price;
  final Map<String, dynamic> fullData;

  const _ProductGridItem({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.fullData,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(
              product: fullData,
              onAddToCart: (product) {
                // Handle adding to cart here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${product['name']} added to cart")),
                );
              },
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: imageUrl.isNotEmpty
                    ? Image.network(imageUrl, fit: BoxFit.cover)
                    : Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('\$${price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Blog Grid Item (Static)
class _BlogGridItem extends StatelessWidget {
  const _BlogGridItem();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                color: Colors.blue[50],
                child: const Center(
                  child: Icon(Icons.article_outlined, size: 40, color: Colors.blue),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Blog Title', style: TextStyle(fontSize: 16)),
                SizedBox(height: 4),
                Text(
                  'A short snippet of the blog...',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Adoption List Item (Static)
class _AdoptionListItem extends StatelessWidget {
  const _AdoptionListItem();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.pink,
              child: Icon(Icons.favorite_outline, color: Colors.white),
            ),
            SizedBox(height: 8),
            Text('Pet Name'),
          ],
        ),
      ),
    );
  }
}

// Main HomePage
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'User';

    return Column(
      children: [
        CustomAppBar("Welcome, $userName!"),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Adoption Section
              const Text('Pets for Adoption', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  padding: const EdgeInsets.all(8.0),
                  itemBuilder: (context, index) => const _AdoptionListItem(),
                ),
              ),
              const SizedBox(height: 32),

              // Popular Products Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Popular Products', style: TextStyle(fontSize: 18)),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const StorePage()),
                      );
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              SizedBox(
                height: 480,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('products').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final products = snapshot.data!.docs;
                    if (products.isEmpty) {
                      return const Center(child: Text('No products available.'));
                    }

                    return GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      physics: const NeverScrollableScrollPhysics(),
                      children: products.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final List<dynamic>? images = data['images'];
                        final String imageUrl = (images != null && images.isNotEmpty)
                            ? images.first.toString()
                            : '';

                        return _ProductGridItem(
                          productId: doc.id,
                          name: data['name'] ?? 'No Name',
                          imageUrl: imageUrl,
                          price: (data['price'] ?? 0).toDouble(),
                          fullData: data,
                        );
                      }).toList(),
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Blogs Section
              _GridSection(
                title: 'Stories & Blogs',
                height: 480,
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(4, (index) => const _BlogGridItem()),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }
}

class HomePageFloatingActionButton extends StatelessWidget {
  const HomePageFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

class HomePageNavigationDestination extends StatelessWidget {
  const HomePageNavigationDestination({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationDestination(
      icon: const Icon(Icons.home_outlined),
      selectedIcon: const Icon(Icons.home_rounded),
      label: "Home",
    );
  }
}
