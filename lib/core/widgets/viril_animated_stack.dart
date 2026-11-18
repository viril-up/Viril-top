import 'package:flutter/material.dart';

/// Keeps every main section alive while softly transitioning between them.
class VirilAnimatedStack extends StatelessWidget {
  const VirilAnimatedStack({
    super.key,
    required this.index,
    required this.children,
  });

  final int index;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      for (var i = 0; i < children.length; i++)
        Positioned.fill(
          child: IgnorePointer(
            ignoring: i != index,
            child: ExcludeSemantics(
              excluding: i != index,
              child: TickerMode(
                enabled: i == index,
                child: AnimatedOpacity(
                  opacity: i == index ? 1 : 0,
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeInOutCubic,
                  child: AnimatedSlide(
                    offset: i == index ? Offset.zero : const Offset(0, .012),
                    duration: const Duration(milliseconds: 360),
                    curve: Curves.easeOutCubic,
                    child: children[i],
                  ),
                ),
              ),
            ),
          ),
        ),
    ],
  );
}
