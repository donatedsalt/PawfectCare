import 'package:flutter/material.dart';

class BlogsPageAppBar extends StatefulWidget implements PreferredSizeWidget {
  const BlogsPageAppBar({super.key});

  @override
  State<BlogsPageAppBar> createState() => _BlogsPageAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _BlogsPageAppBarState extends State<BlogsPageAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('Blogs'));
  }
}

class BlogsPage extends StatelessWidget {
  const BlogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Welcome user
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text(
            "Shelter Blogs Page",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class BlogsPageFloatingActionButton extends StatelessWidget {
  const BlogsPageFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}

class BlogsPageNavigationDestination extends StatelessWidget {
  const BlogsPageNavigationDestination({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationDestination(
      icon: const Icon(Icons.web_asset),
      selectedIcon: Icon(Icons.web),
      label: "Blogs",
    );
  }
}
