import 'package:flutter/material.dart';

import 'package:pawfect_care/pages/admin/home_page.dart';
import 'package:pawfect_care/pages/admin/more_page.dart';

class AdminPageController extends StatefulWidget {
  const AdminPageController({super.key});

  @override
  State<AdminPageController> createState() => _AdminPageControllerState();
}

class _AdminPageControllerState extends State<AdminPageController>
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

  final List<Widget> _navigationDestination = const [
    HomePageNavigationDestination(),
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
      destinations: _navigationDestination,
    );
  }
}
