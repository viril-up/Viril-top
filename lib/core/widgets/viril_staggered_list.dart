import 'package:flutter/material.dart';

/// Displays all section blocks together without staggered entrance delays.
/// Section-level opacity is handled by VirilAnimatedStack.
class VirilStaggeredList extends StatelessWidget {
  const VirilStaggeredList({
    super.key,
    required this.pageIndex,
    required this.padding,
    required this.children,
  });

  final int pageIndex;
  final EdgeInsetsGeometry padding;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => ListView(
    padding: padding,
    children: children,
  );
}
