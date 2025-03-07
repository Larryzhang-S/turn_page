import 'package:flutter/material.dart';
import 'dart:math';

class FlipBook extends StatefulWidget {
  final List<String> pages;

  FlipBook({required this.pages});

  @override
  _FlipBookState createState() => _FlipBookState();
}

class _FlipBookState extends State<FlipBook> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentPage = 0;
  double _dragValue = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragValue -= details.primaryDelta! / MediaQuery.of(context).size.width;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dragValue.abs() > 0.3) {
      _currentPage += (_dragValue > 0) ? 1 : -1;
      _currentPage = _currentPage.clamp(0, widget.pages.length - 1);
      _pageController.animateToPage(_currentPage, duration: Duration(milliseconds: 500), curve: Curves.easeOut);
    }
    setState(() => _dragValue = 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: PageView.builder(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        itemCount: widget.pages.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              double rotation = _dragValue * pi / 2;
              return Transform(
                alignment: Alignment.centerRight,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(rotation),
                child: PageWidget(text: widget.pages[index]),
              );
            },
          );
        },
      ),
    );
  }
}

class PageWidget extends StatelessWidget {
  final String text;
  PageWidget({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black),
        boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)],
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
