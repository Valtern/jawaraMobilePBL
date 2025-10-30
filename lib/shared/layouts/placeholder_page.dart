import 'package:flutter/material.dart';

class PlaceholderPage extends StatelessWidget {
  final String pageTitle;
  const PlaceholderPage({super.key, required this.pageTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(pageTitle)),
      body: Center(
        child: Text(
          'This is the $pageTitle page.',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
