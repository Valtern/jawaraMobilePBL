import 'package:flutter/material.dart';

class TabPlaceholder extends StatelessWidget {
  const TabPlaceholder({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('$title belum tersedia'));
  }
}
