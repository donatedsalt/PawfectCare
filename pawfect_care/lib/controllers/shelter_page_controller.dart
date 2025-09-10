import 'package:flutter/material.dart';

import 'package:pawfect_care/pages/user/home_page.dart';
import 'package:pawfect_care/pages/user/more_page.dart';

class ShelterPageController extends StatefulWidget {
  const ShelterPageController({super.key});

  @override
  State<ShelterPageController> createState() => _ShelterPageControllerState();
}

class _ShelterPageControllerState extends State<ShelterPageController>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<Widget> _pages = const [HomePage(), MorePage()];

  final List<PreferredSizeWidget> _appBars = const [
    HomePageAppBar(),
    MorePageAppBar(),
  ];

  final List<Widget> _floatingActionButtons = const [
    HomePageFloatingActionButton(),
    MorePageFloatingActionButton(),
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
    return SafeArea(
      child: Scaffold(
        appBar: _appBars[_tabController.index],
        body: TabBarView(controller: _tabController, children: _pages),
        bottomNavigationBar: customNavigationBar(context),
        floatingActionButton: _floatingActionButtons[_tabController.index],
      ),
    );
  }

  Widget customNavigationBar(BuildContext context) {
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
          icon: const Icon(Icons.pin_drop_outlined),
          selectedIcon: Icon(
            Icons.pin_drop_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          label: "Trips",
        ),
        NavigationDestination(
          icon: const Icon(Icons.monetization_on_outlined),
          selectedIcon: Icon(
            Icons.monetization_on,
            color: Theme.of(context).colorScheme.primary,
          ),
          label: "Expenses",
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
