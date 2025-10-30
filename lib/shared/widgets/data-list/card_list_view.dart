import 'package:flutter/material.dart';

class CardListView<T> extends StatelessWidget {
  const CardListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.padding = const EdgeInsets.only(top: 8, bottom: 8, left: 12),
    this.cardMargin,
    this.cardColor,
    this.cardShape,
    this.physics,
    this.shrinkWrap = true,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? cardMargin;
  final Color? cardColor;
  final ShapeBorder? cardShape;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: cardMargin,
      color: cardColor,
      shape: cardShape,
      child: Padding(
        padding: padding,
        child: ListView.builder(
          shrinkWrap: shrinkWrap,
          physics: physics ?? const ClampingScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return itemBuilder(context, item);
          },
        ),
      ),
    );
  }
}
