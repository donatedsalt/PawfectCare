import 'package:flutter/material.dart';
import 'package:pawfect_care/pages/shelter/more_page.dart';
import 'package:pawfect_care/pages/shelter/add_pet_page.dart';
import 'package:pawfect_care/pages/shelter/add_story_page.dart';
import 'package:pawfect_care/pages/shelter/adoption_requests_page.dart';
import 'package:pawfect_care/pages/shelter/contacts_page.dart';
import 'package:pawfect_care/pages/shelter/home_page.dart';
import 'package:pawfect_care/pages/shelter/success_stories_page.dart';

class ShelterPageController extends StatefulWidget {
  const ShelterPageController({super.key});

  @override
  State<ShelterPageController> createState() => _ShelterPageControllerState();
}

class _ShelterPageControllerState extends State<ShelterPageController>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Pages
  final List<Widget> _pages = [
    const PetListingsPage(),
    const AdoptionRequestsPage(),
    const SuccessStoriesPage(),
    const ContactVolunteerPage(),
    const MorePage(), // More tab
  ];

  // FABs
  final List<Widget> _fabs = [
    const SizedBox(),
    const SizedBox(),
    const AddStoryFAB(),
    const SizedBox(),
    const MorePageFAB(), // FAB for More tab
  ];

  // Bottom Navigation Destinations
  final List<NavigationDestination> _navDestinations = const [
    NavigationDestination(
      icon: Icon(Icons.pets_outlined),
      selectedIcon: Icon(Icons.pets),
      label: 'Pets',
    ),
    NavigationDestination(
      icon: Icon(Icons.list_alt_outlined),
      selectedIcon: Icon(Icons.list_alt),
      label: 'Requests',
    ),
    NavigationDestination(
      icon: Icon(Icons.emoji_emotions_outlined),
      selectedIcon: Icon(Icons.emoji_emotions),
      label: 'Stories',
    ),
    NavigationDestination(
      icon: Icon(Icons.contact_mail_outlined),
      selectedIcon: Icon(Icons.contact_mail),
      label: 'Contact',
    ),
    NavigationDestination(
      icon: Icon(Icons.more_horiz_outlined),
      selectedIcon: Icon(Icons.more_horiz),
      label: 'More',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _pages.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tabController.index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabController.index,
        onDestinationSelected: (index) => _tabController.animateTo(index),
        destinations: _navDestinations,
      ),
      floatingActionButton: _fabs[_tabController.index],
    );
  }
}

/// FABs

class AddPetFAB extends StatelessWidget {
  const AddPetFAB({super.key});

  @override
  Widget build(BuildContext context) => FloatingActionButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddPetPage()),
      );
    },
    child: const Icon(Icons.add),
    tooltip: "Add Pet",
  );
}

class RespondRequestFAB extends StatelessWidget {
  const RespondRequestFAB({super.key});

  @override
  Widget build(BuildContext context) => FloatingActionButton(
    onPressed: () {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Manage Adoption Requests")));
    },
    child: const Icon(Icons.checklist_rounded),
    tooltip: "Manage Requests",
  );
}

class AddStoryFAB extends StatelessWidget {
  const AddStoryFAB({super.key});

  @override
  Widget build(BuildContext context) => FloatingActionButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddStoryPage()),
      );
    },
    child: const Icon(Icons.edit),
    tooltip: "Add Story",
  );
}

class ContactVolunteerFAB extends StatelessWidget {
  const ContactVolunteerFAB({super.key});

  @override
  Widget build(BuildContext context) => FloatingActionButton(
    onPressed: () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Contact / Volunteer options")),
      );
    },
    child: const Icon(Icons.contact_mail),
    tooltip: "Contact / Volunteer",
  );
}

class MorePageFAB extends StatelessWidget {
  const MorePageFAB({super.key});

  @override
  Widget build(BuildContext context) => FloatingActionButton(
    onPressed: () {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("More Options")));
    },
    child: const Icon(Icons.more_horiz),
    tooltip: "More Options",
  );
}
