import 'package:flutter/material.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({
    super.key,
    required this.body,
    this.currentIndex = 0,
    this.onItemSelected,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.extendBody = false,
    this.showBottomNavigationBar = true,
  });

  final Widget body;
  final int currentIndex;
  final ValueChanged<int>? onItemSelected;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;
  final bool extendBody;
  final bool showBottomNavigationBar;

  static const List<_NavigationItem> _navigationItems = [
    _NavigationItem(
      route: '/home', // Points to the main dashboard page
      item: BottomNavigationBarItem(label: 'Dashboard', icon: Icon(Icons.home)),
    ),
    _NavigationItem(
      route: '/pemasukan', // Points to the Pemasukan page
      item: BottomNavigationBarItem(
        label: 'Pemasukan',
        icon: Icon(Icons.attach_money),
      ),
    ),
    _NavigationItem(
      route: '/pengeluaran', // New route for Pengeluaran
      item: BottomNavigationBarItem(
        label: 'Pengeluaran',
        icon: Icon(Icons.money_off),
      ),
    ),
    _NavigationItem(
      route: '/lainnya', // New route for Lainnya
      item: BottomNavigationBarItem(label: 'Lainnya', icon: Icon(Icons.menu)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final Widget content = SafeArea(
      top: appBar == null,
      bottom: !extendBody,
      child: body,
    );

    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      extendBody: extendBody,
      body: Container(
        padding: EdgeInsets.only(top: 16, bottom: 16, left: 12, right: 12),
        child: content,
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: showBottomNavigationBar
          ? _buildBottomNavigationBar(context)
          : null,
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey,
          currentIndex: currentIndex,
          onTap: (index) {
            onItemSelected?.call(index);
            if (onItemSelected == null) {
              final route = _navigationItems[index].route;
              // This logic pushes the new named routes
              Navigator.of(context).pushNamed(route);
            }
          },
          items: _navigationItems
              .map<BottomNavigationBarItem>((item) => item.item)
              .toList(),
        ),
      ),
    );
  }
}

class _NavigationItem {
  const _NavigationItem({required this.route, required this.item});

  final String route;
  final BottomNavigationBarItem item;
}
