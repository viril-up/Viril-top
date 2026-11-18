import 'package:flutter/material.dart';
import 'viril_animated_stack.dart';

/// A restrained staggered entrance for the main screen's content blocks.
class VirilStaggeredList extends StatefulWidget {
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
  State<VirilStaggeredList> createState() => _VirilStaggeredListState();
}

class _VirilStaggeredListState extends State<VirilStaggeredList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 620),
  );

  ValueNotifier<int>? _activePage;

  @override
  void initState() {
    super.initState();
    _controller.value = 1;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = VirilMotionScope.maybeOf(context);
    if (identical(next, _activePage)) return;
    _activePage?.removeListener(_handlePageChange);
    _activePage = next;
    _activePage?.addListener(_handlePageChange);
    _handlePageChange();
  }

  void _handlePageChange() {
    if (!mounted || _activePage?.value != widget.pageIndex) return;
    _controller.forward(from: 0);
  }

  @override
  void didUpdateWidget(covariant VirilStaggeredList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageIndex != widget.pageIndex) _handlePageChange();
  }

  @override
  void dispose() {
    _activePage?.removeListener(_handlePageChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: widget.padding,
    children: [
      for (var i = 0; i < widget.children.length; i++)
        AnimatedBuilder(
          animation: _controller,
          child: widget.children[i],
          builder: (context, child) {
            final start = (i * .10).clamp(0.0, .62);
            final end = (start + .38).clamp(.01, 1.0);
            final animation = CurvedAnimation(
              parent: _controller,
              curve: Interval(start, end, curve: Curves.easeOutCubic),
            );
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, .035),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
        ),
    ],
  );
}
