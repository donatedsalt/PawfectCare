import 'package:flutter/material.dart';

import 'package:pawfect_care/pages/shelter/home_page.dart';
import 'package:pawfect_care/pages/shelter/pets_page.dart';
import 'package:pawfect_care/pages/shelter/blogs_page.dart';
import 'package:pawfect_care/pages/shelter/contacts_page.dart';
import 'package:pawfect_care/pages/shelter/more_page.dart';

class ShelterPageController extends StatefulWidget {
  const ShelterPageController({super.key});

  @override
  State<ShelterPageController> createState() => _ShelterPageControllerState();
}

class _ShelterPageControllerState extends State<ShelterPageController>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<Widget> _pages = const [
    HomePage(),
    PetsPage(),
    BlogsPage(),
    ContactsPage(),
    MorePage(),
  ];

  final List<Widget> _floatingActionButtons = const [
    HomePageFloatingActionButton(),
    PetsPageFloatingActionButton(),
    BlogsPageFloatingActionButton(),
    ContactsPageFloatingActionButton(),
    MorePageFloatingActionButton(),
  ];

  final List<Widget> _navigationDestination = const [
    HomePageNavigationDestination(),
    PetsPageNavigationDestination(),
    BlogsPageNavigationDestination(),
    ContactsPageNavigationDestination(),
    MorePageNavigationDestination(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _pages.length, vsync: this);
    _tabController.addListener(() {
      setState(() {});
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
      body: SafeArea(
        child: TabBarView(controller: _tabController, children: _pages),
      ),
      bottomNavigationBar: customNavigationBar(context),
      floatingActionButton: _floatingActionButtons[_tabController.index],
    );
  }

  Widget customNavigationBar(BuildContext context) {
    return NavigationBar(
      selectedIndex: _tabController.index,
      onDestinationSelected: (int index) {
        _tabController.animateTo(index);
      },
      destinations: _navigationDestination,
    );
  }
}
