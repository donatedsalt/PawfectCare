import 'package:flutter/material.dart';

import 'package:pawfect_care/widgets/custom_app_bar.dart';

class BlogsPage extends StatelessWidget {
  const BlogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAppBar("Shelter Blogs Page"),

        Expanded(
          child: ListView(padding: const EdgeInsets.all(16), children: [
              ],
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
