import 'package:flutter/material.dart';

class ConsistentTabBar extends StatelessWidget {
  final List<String> tabs;
  final List<Widget> tabViews;
  final bool isScrollable;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final double? borderRadius;
  final Color? containerColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final Color? indicatorColor;
  final TextStyle? labelStyle;
  final TextStyle? unselectedLabelStyle;
  final TabBarIndicatorSize? indicatorSize;
  final List<BoxShadow>? boxShadow;
  final double? elevation;

  const ConsistentTabBar({
    super.key,
    required this.tabs,
    required this.tabViews,
    this.isScrollable = true,
    this.margin,
    this.padding,
    this.borderRadius,
    this.containerColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.indicatorColor,
    this.labelStyle,
    this.unselectedLabelStyle,
    this.indicatorSize,
    this.boxShadow,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Column(
        children: [
          Container(
            margin: margin ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: padding,
            decoration: BoxDecoration(
              color: containerColor ?? Colors.white,
              borderRadius: BorderRadius.circular(borderRadius ?? 12),
              boxShadow: boxShadow ??
                  [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
            ),
            child: TabBar(
              isScrollable: isScrollable,
              labelColor: labelColor ?? const Color(0xFF6938EF),
              unselectedLabelColor:
                  unselectedLabelColor ?? const Color(0xFF636E72),
              indicatorColor: indicatorColor ?? const Color(0xFF6938EF),
              indicatorSize: indicatorSize ?? TabBarIndicatorSize.tab,
              labelStyle: labelStyle ??
                  const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
              unselectedLabelStyle: unselectedLabelStyle ??
                  const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
              tabs: tabs.map((tab) => Tab(text: tab)).toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              physics: const ClampingScrollPhysics(),
              children: tabViews,
            ),
          ),
        ],
      ),
    );
  }
}

class AppBarTabBar extends StatelessWidget {
  final String title;
  final List<String> tabs;
  final List<Widget> tabViews;
  final bool isScrollable;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final Color? indicatorColor;
  final TextStyle? labelStyle;
  final TextStyle? unselectedLabelStyle;
  final TabBarIndicatorSize? indicatorSize;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final List<Widget>? actions;

  const AppBarTabBar({
    super.key,
    required this.title,
    required this.tabs,
    required this.tabViews,
    this.isScrollable = true,
    this.labelColor,
    this.unselectedLabelColor,
    this.indicatorColor,
    this.labelStyle,
    this.unselectedLabelStyle,
    this.indicatorSize,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            title,
            style: TextStyle(
              color: foregroundColor ?? Colors.black,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: backgroundColor ?? Colors.white,
          elevation: elevation ?? 0,
          foregroundColor: foregroundColor ?? Colors.black,
          actions: actions,
          bottom: TabBar(
            isScrollable: isScrollable,
            labelColor: labelColor ?? const Color(0xFF6938EF),
            unselectedLabelColor:
                unselectedLabelColor ?? const Color(0xFF636E72),
            indicatorColor: indicatorColor ?? const Color(0xFF6938EF),
            indicatorSize: indicatorSize ?? TabBarIndicatorSize.tab,
            labelStyle: labelStyle ??
                const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
            unselectedLabelStyle: unselectedLabelStyle ??
                const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
            tabs: tabs.map((tab) => Tab(text: tab)).toList(),
          ),
        ),
        body: TabBarView(
          physics: const ClampingScrollPhysics(),
          children: tabViews,
        ),
      ),
    );
  }
}
