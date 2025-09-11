import 'package:flutter/material.dart';

import 'package:pawfect_care/pages/store/home_page.dart';
import 'package:pawfect_care/pages/store/more_page.dart';
import 'package:pawfect_care/pages/store/orders_page.dart';
import 'package:pawfect_care/pages/store/products_page.dart';

class StorePageController extends StatefulWidget {
  const StorePageController({super.key});

  @override
  State<StorePageController> createState() => _StorePageControllerState();
}

class _StorePageControllerState extends State<StorePageController>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<Widget> _pages = const [
    HomePage(),
    ProductsPage(),
    OrdersPage(),
    MorePage(),
  ];

  final List<PreferredSizeWidget> _appBars = const [
    HomePageAppBar(),
    ProductsPageAppBar(),
    OrdersPageAppBar(),
    MorePageAppBar(),
  ];

  final List<Widget> _floatingActionButtons = const [
    HomePageFloatingActionButton(),
    ProductsPageFloatingActionButton(),
    OrdersPageFloatingActionButton(),
    MorePageFloatingActionButton(),
  ];

  final List<Widget> _navigationDestination = const [
    HomePageNavigationDestination(),
    ProductsPageNavigationDestination(),
    OrdersPageNavigationDestination(),
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
