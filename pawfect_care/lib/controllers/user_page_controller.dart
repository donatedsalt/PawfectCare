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
    StorePage(),
    AdoptPage(),
    MorePage(),
  ];

  final List<PreferredSizeWidget> _appBars = const [
    HomePageAppBar(),
    AppointmentPageAppBar(),
    StorePageAppBar(),
    AdoptPageAppBar(),
    MorePageAppBar(),
  ];

  final List<Widget> _floatingActionButtons = const [
    HomePageFloatingActionButton(),
    AppointmentPageFloatingActionButton(),
    StorePageFloatingActionButton(),
    AdoptPageFloatingActionButton(),
    MorePageFloatingActionButton(),
  ];

  final List<Widget> _navigationDestination = const [
    HomePageNavigationDestination(),
    AppointmentPageNavigationDestination(),
    StorePageNavigationDestination(),
    AdoptPageNavigationDestination(),
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
