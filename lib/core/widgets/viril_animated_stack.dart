import 'package:flutter/material.dart';

/// Shares the active section with content widgets without rebuilding their state.
class VirilMotionScope extends InheritedWidget {
  const VirilMotionScope({
    super.key,
    required this.activePage,
    required super.child,
  });

  final ValueNotifier<int> activePage;

  static ValueNotifier<int>? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<VirilMotionScope>()?.activePage;

  @override
  bool updateShouldNotify(VirilMotionScope oldWidget) =>
      !identical(activePage, oldWidget.activePage);
}

/// Keeps every main section alive while softly transitioning between them.
class VirilAnimatedStack extends StatefulWidget {
  const VirilAnimatedStack({
    super.key,
    required this.index,
    required this.children,
  });

  final int index;
  final List<Widget> children;

  @override
  State<VirilAnimatedStack> createState() => _VirilAnimatedStackState();
}

class _VirilAnimatedStackState extends State<VirilAnimatedStack> {
  late final ValueNotifier<int> _activePage = ValueNotifier<int>(widget.index);

  @override
  void didUpdateWidget(covariant VirilAnimatedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) _activePage.value = widget.index;
  }

  @override
  void dispose() {
    _activePage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => VirilMotionScope(
    activePage: _activePage,
    child: Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < widget.children.length; i++)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: i != widget.index,
              child: ExcludeSemantics(
                excluding: i != widget.index,
                child: TickerMode(
                  enabled: i == widget.index,
                  child: AnimatedOpacity(
                    opacity: i == widget.index ? 1 : 0,
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeInOutCubic,
                    child: AnimatedSlide(
                      offset: i == widget.index ? Offset.zero : const Offset(0, .012),
                      duration: const Duration(milliseconds: 360),
                      curve: Curves.easeOutCubic,
                      child: widget.children[i],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
