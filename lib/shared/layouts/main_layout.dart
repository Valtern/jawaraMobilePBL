import 'package:flutter/material.dart';
import 'package:jawarapbl/services/auth_services.dart';

class MainLayout extends StatefulWidget {
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

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  String? _role;
  final AuthService _authService = AuthService();
  List<_NavigationItem> _visibleItems = [];

  // Define roles for clarity
  static const String admin = 'admin';
  static const String bendahara = 'bendahara';
  static const String rw = 'rw';
  static const String rt = 'rt';

  // Master list of all possible items
  static const List<_NavigationItem> _allNavigationItems = [
    _NavigationItem(
      route: '/home',
      allowedRoles: ['all'], // Everyone sees Dashboard
      item: BottomNavigationBarItem(label: 'Dashboard', icon: Icon(Icons.home)),
    ),
    _NavigationItem(
      route: '/pemasukan',
      // Admin, Bendahara, RW, RT can see Income
      allowedRoles: [admin, bendahara, rw, rt],
      item: BottomNavigationBarItem(
        label: 'Pemasukan',
        icon: Icon(Icons.attach_money),
      ),
    ),
    _NavigationItem(
      route: '/pengeluaran',
      // Admin, Bendahara, RW, RT can see Expenses
      allowedRoles: [admin, bendahara, rw, rt],
      item: BottomNavigationBarItem(
        label: 'Pengeluaran',
        icon: Icon(Icons.money_off),
      ),
    ),
    _NavigationItem(
      route: '/lainnya',
      allowedRoles: ['all'], // Everyone sees Lainnya
      item: BottomNavigationBarItem(label: 'Lainnya', icon: Icon(Icons.menu)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _updateVisibleItems(); 
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final role = await _authService.getRole();
    if (mounted) {
      setState(() {
        _role = role;
        _updateVisibleItems();
      });
    }
  }

  void _updateVisibleItems() {
    if (_role == null) {
      // Default: show only public items (Dashboard & Lainnya)
      _visibleItems = _allNavigationItems
          .where((nav) => nav.allowedRoles.contains('all'))
          .toList();
    } else {
      _visibleItems = _allNavigationItems.where((nav) {
        if (nav.allowedRoles.contains('all')) return true;
        return nav.allowedRoles.contains(_role);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget content = SafeArea(
      top: widget.appBar == null,
      bottom: !widget.extendBody,
      child: widget.body,
    );

    return Scaffold(
      appBar: widget.appBar,
      backgroundColor: widget.backgroundColor,
      extendBody: widget.extendBody,
      body: Container(
        padding: const EdgeInsets.only(top: 16, bottom: 16, left: 12, right: 12),
        child: content,
      ),
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      bottomNavigationBar: widget.showBottomNavigationBar
          ? _buildBottomNavigationBar(context)
          : null,
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    // Safety check: ensure activeIndex is valid for the current visible list
    int activeIndex = 0;
    if (widget.currentIndex < _visibleItems.length) {
      activeIndex = widget.currentIndex;
    }

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
          currentIndex: activeIndex,
          onTap: (index) {
            widget.onItemSelected?.call(index);
            if (widget.onItemSelected == null) {
              final route = _visibleItems[index].route;
              Navigator.of(context).pushNamed(route);
            }
          },
          items: _visibleItems
              .map<BottomNavigationBarItem>((item) => item.item)
              .toList(),
        ),
      ),
    );
  }
}

class _NavigationItem {
  const _NavigationItem({
    required this.route,
    required this.item,
    required this.allowedRoles,
  });

  final String route;
  final BottomNavigationBarItem item;
  final List<String> allowedRoles;
}