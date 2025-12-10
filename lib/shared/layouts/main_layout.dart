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
  String? _currentRoute;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCurrentRoute();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateCurrentRoute();
  }

  void _updateCurrentRoute() {
    final route = ModalRoute.of(context)?.settings.name;
    if (route != _currentRoute) {
      setState(() {
        _currentRoute = route;
      });
    }
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
        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
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
    // Use stored current route or get from ModalRoute
    final currentRoute = _currentRoute ?? ModalRoute.of(context)?.settings.name;
    
    // Find the index of current route in visible items
    int activeIndex = 0;
    if (currentRoute != null && currentRoute.isNotEmpty) {
      final foundIndex = _visibleItems.indexWhere(
        (item) => item.route == currentRoute
      );
      if (foundIndex >= 0) {
        activeIndex = foundIndex;
      } else {
        // Route not in visible items, try to map from widget.currentIndex
        // For non-admin users: map index 3 (lainnya) to index 1
        if (widget.currentIndex == 3 && _visibleItems.length == 2) {
          // Non-admin: Dashboard (0), Lainnya (1)
          activeIndex = 1;
        } else if (widget.currentIndex < _visibleItems.length) {
          activeIndex = widget.currentIndex;
        }
      }
    } else {
      // No route found, use widget.currentIndex with mapping
      if (widget.currentIndex == 3 && _visibleItems.length == 2) {
        // Non-admin: Dashboard (0), Lainnya (1)
        activeIndex = 1;
      } else if (widget.currentIndex < _visibleItems.length) {
        activeIndex = widget.currentIndex;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF6938EF),
          unselectedItemColor: Colors.grey[400],
          selectedFontSize: 12,
          unselectedFontSize: 12,
          currentIndex: activeIndex,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          onTap: (index) {
            widget.onItemSelected?.call(index);
            if (widget.onItemSelected == null) {
              final route = _visibleItems[index].route;
              // Update current route immediately for better UX
              setState(() {
                _currentRoute = route;
              });
              Navigator.of(context).pushReplacementNamed(route);
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