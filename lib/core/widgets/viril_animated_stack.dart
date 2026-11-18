import 'package:flutter/material.dart';

/// Keeps each main section mounted so its local state is preserved.
/// Tab changes are immediate: no overlapping layers, sliding or vertical motion.
class VirilAnimatedStack extends StatelessWidget {
  const VirilAnimatedStack({
    super.key,
    required this.index,
    required this.children,
  });

  final int index;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => IndexedStack(
    index: index,
    sizing: StackFit.expand,
    children: [
      for (var i = 0; i < children.length; i++)
        TickerMode(
          enabled: i == index,
          child: Offstage(
            offstage: i != index,
            child: children[i],
          ),
        ),
    ],
  );
}
