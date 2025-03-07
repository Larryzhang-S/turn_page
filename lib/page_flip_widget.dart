import 'package:flutter/material.dart';
import 'dart:math';

class PageFlipWidget extends StatefulWidget {
  final List<Widget> pages;

  const PageFlipWidget({Key? key, required this.pages}) : super(key: key);

  @override
  _PageFlipWidgetState createState() => _PageFlipWidgetState();
}

class _PageFlipWidgetState extends State<PageFlipWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _angle = 0.0;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {
          _angle = _animation.value;
        });
      });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final double delta = details.primaryDelta! / MediaQuery.of(context).size.width;
    setState(() {
      _angle = (_angle + delta * 0.5).clamp(0.0, 1.0);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_angle > 0.3 || details.velocity.pixelsPerSecond.dx > 500) {
      _controller.forward().then((_) {
        setState(() {
          _currentPage = (_currentPage + 1) % widget.pages.length;
          _angle = 0.0;
          _controller.reset();
        });
      });
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Transform(
            alignment: Alignment.centerLeft,
            transform: Matrix4.identity()..rotateY(-_angle * pi),
            child: widget.pages[(_currentPage + 1) % widget.pages.length],
          ),
        ),
        GestureDetector(
          onHorizontalDragUpdate: _handleDragUpdate,
          onHorizontalDragEnd: _handleDragEnd,
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_angle * pi),
            alignment: Alignment.centerLeft,
            child: widget.pages[_currentPage],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
