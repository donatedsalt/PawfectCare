import 'package:flutter/material.dart';
import 'package:pawfect_care/pages/vet/CalendarPage.dart';
import 'package:pawfect_care/pages/vet/PatientMedicalRecordsPage.dart';
import 'package:pawfect_care/pages/vet/home_page.dart';
import 'package:pawfect_care/pages/vet/more_page.dart';

class VetPageController extends StatefulWidget {
  const VetPageController({super.key});

  @override
  State<VetPageController> createState() => _VetPageControllerState();
}

class _VetPageControllerState extends State<VetPageController>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<Widget> _pages = const [
    HomePage(),
    CalendarPage(),
    PatientMedicalRecordsPage(),
    MorePage(),
  ];

  final List<Widget> _floatingActionButtons = const [
    HomePageFloatingActionButtonExpanded(),
    SizedBox.shrink(), // Calendar page ke liye empty FAB
    SizedBox.shrink(), // Records page ke liye empty FAB
    MorePageFloatingActionButton(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _pages.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {}); // Refresh FAB
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: _pages,
        ),
        bottomNavigationBar: _customNavigationBar(context),
        floatingActionButton: _floatingActionButtons[_tabController.index],
      ),
    );
  }

  Widget _customNavigationBar(BuildContext context) {
    return NavigationBar(
      selectedIndex: _tabController.index,
      onDestinationSelected: (int index) {
        _tabController.animateTo(index);
      },
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: Icon(
            Icons.home_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          label: "Home",
        ),
        NavigationDestination(
          icon: const Icon(Icons.calendar_today_outlined),
          selectedIcon: Icon(
            Icons.calendar_today_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          label: "Appointments",
        ),
        NavigationDestination(
          icon: const Icon(Icons.folder_open_outlined),
          selectedIcon: Icon(
            Icons.folder_open,
            color: Theme.of(context).colorScheme.primary,
          ),
          label: "Records",
        ),
        NavigationDestination(
          icon: const Icon(Icons.more_horiz),
          selectedIcon: Icon(
            Icons.more,
            color: Theme.of(context).colorScheme.primary,
          ),
          label: "More",
        ),
      ],
    );
  }
}
