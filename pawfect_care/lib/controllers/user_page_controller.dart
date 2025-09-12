import 'package:flutter/material.dart';

import 'package:pawfect_care/pages/user/home_page.dart';
import 'package:pawfect_care/pages/user/appointment_page.dart';
import 'package:pawfect_care/pages/user/store_page.dart';
import 'package:pawfect_care/pages/user/adopt_page.dart';
import 'package:pawfect_care/pages/user/more_page.dart';

class UserPageController extends StatefulWidget {
  const UserPageController({super.key});

  @override
  State<UserPageController> createState() => _UserPageControllerState();
}

class _UserPageControllerState extends State<UserPageController>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<Widget> _pages = const [
    HomePage(),
    AppointmentPage(),
    StorePage(), // StorePage apna FAB khud rakhega
    AdoptPage(),
    MorePage(),
  ];

  // ✅ FABs (StorePage ke liye empty)
  final List<Widget> _floatingActionButtons = const [
    HomePageFloatingActionButton(),
    AppointmentPageFloatingActionButton(),
    SizedBox.shrink(), // StorePage => apna FAB handle karega
    AdoptPageFloatingActionButton(),
    MorePageFloatingActionButton(),
  ];

  // ✅ Navigation Destinations
  final List<NavigationDestination> _navigationDestinations = const [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: "Home",
    ),
    NavigationDestination(
      icon: Icon(Icons.calendar_today_outlined),
      selectedIcon: Icon(Icons.calendar_today),
      label: "Appointments",
    ),
    NavigationDestination(
      icon: Icon(Icons.storefront_outlined),
      selectedIcon: Icon(Icons.storefront),
      label: "Store",
    ),
    NavigationDestination(
      icon: Icon(Icons.pets_outlined),
      selectedIcon: Icon(Icons.pets),
      label: "Adopt",
    ),
    NavigationDestination(
      icon: Icon(Icons.more_horiz_outlined),
      selectedIcon: Icon(Icons.more_horiz),
      label: "More",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _pages.length, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // UI update when tab changes
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
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: const Color(0xFF0D1C5A), // Dark blue
          indicatorColor: Colors.white24, // Selected item ka halka sa glow
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(color: Colors.white),
          ),
          iconTheme: WidgetStateProperty.all(
            const IconThemeData(color: Colors.white),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _tabController.index,
          onDestinationSelected: (int index) {
            _tabController.animateTo(index);
          },
          destinations: _navigationDestinations,
        ),
      ),
      floatingActionButton: _floatingActionButtons[_tabController.index],
    );
  }
}
