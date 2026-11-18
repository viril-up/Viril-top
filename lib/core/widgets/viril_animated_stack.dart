import 'package:flutter/material.dart';

/// Keeps section state alive, but paints only the selected section.
/// The new section fades in as one surface; old sections are hidden immediately
/// so their cards can never remain layered underneath it.
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
            child: AnimatedOpacity(
              opacity: i == index ? 1 : 0,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              child: children[i],
            ),
          ),
        ),
    ],
  );
}
