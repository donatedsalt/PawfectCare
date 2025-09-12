import 'package:flutter/material.dart';
import 'package:pawfect_care/pages/store/more_page.dart';
import 'package:pawfect_care/pages/store/home_page.dart';
import 'package:pawfect_care/pages/store/orders_page.dart';
import 'package:pawfect_care/pages/store/products_page.dart';

// Brand Colors (like Vet UI)
class BrandColors {
  static const Color primaryBlue = Color.fromRGBO(38, 49, 100, 1);
  static const Color accentGreen = Color(0xFF32C48D);
  static const Color darkBackground = Color.fromRGBO(222, 239, 255, 1);
  static const Color cardBlue = Color.fromRGBO(38, 49, 100, 0.9);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFFC5C6C7);
}

// -------------------- Main Controller -------------------- //
class StorePageController extends StatefulWidget {
  const StorePageController({super.key});

  @override
  State<StorePageController> createState() => _StorePageControllerState();
}

class _StorePageControllerState extends State<StorePageController>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<Widget> _pages = const [
    HomePageStore(),
    ProductsDetailPage(),
    OrdersPageStore(),
    MorePageStore(),
  ];

  final List<String> _titles = ["Home", "Products", "Orders", "More"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _pages.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: TabBarView(controller: _tabController, children: _pages),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildNavigationBar(),
    );
  }

  Widget _buildNavigationBar() {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        backgroundColor: BrandColors.primaryBlue,
        indicatorColor: Colors.white.withOpacity(0.2),

        // ✅ Icon theme set
        iconTheme: MaterialStateProperty.resolveWith<IconThemeData>((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: Colors.white, size: 28);
          }
          return const IconThemeData(color: Colors.white, size: 24);
        }),

        labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>((states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            );
          }
          return const TextStyle(color: Colors.white);
        }),
      ),
      child: NavigationBar(
        selectedIndex: _tabController.index,
        onDestinationSelected: (index) => _tabController.animateTo(index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag_rounded),
            label: "Products",
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: "Orders",
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            selectedIcon: Icon(Icons.more_horiz),
            label: "More",
          ),
        ],
      ),
    );
  }
}
