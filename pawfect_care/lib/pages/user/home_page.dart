import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomePageAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('Home'));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// A reusable widget for the grid sections (Popular Products and Stories/Blogs).
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

// A reusable widget for a single product grid item.
class _ProductGridItem extends StatelessWidget {
  const _ProductGridItem();

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
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Container(
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
          const Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Product Name', style: TextStyle(fontSize: 16)),
                SizedBox(height: 4),
                Text('\$19.99', style: TextStyle(color: Colors.green)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// A reusable widget for a single blog/story grid item.
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
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Container(
                color: Colors.blue[50],
                child: const Center(
                  child: Icon(
                    Icons.article_outlined,
                    size: 40,
                    color: Colors.blue,
                  ),
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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'User';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text(
            "Welcome, $userName!",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24),
          ),
        ),
        const SizedBox(height: 24),

        // New Adoption section
        const Text('Pets for Adoption', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            padding: const EdgeInsets.all(8.0),
            itemBuilder: (context, index) {
              return _AdoptionListItem();
            },
          ),
        ),
        const SizedBox(height: 32),

        // Reusable section for Popular Products
        _GridSection(
          title: 'Popular Products',
          height: 480,
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(4, (index) => const _ProductGridItem()),
          ),
        ),

        const SizedBox(height: 32),

        // Reusable section for Stories/Blogs
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
      selectedIcon: Icon(
        Icons.home_rounded,
        color: Theme.of(context).colorScheme.primary,
      ),
      label: "Home",
    );
  }
}
