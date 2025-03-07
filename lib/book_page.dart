import 'dart:math';
import 'package:flutter/material.dart';

import 'inner_shadow.dart';

class BookPage extends StatefulWidget {
  const BookPage({Key? key}) : super(key: key);

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage>
    with SingleTickerProviderStateMixin {
  final double _pageWidth = 560;
  final double _pageHeigt = 660;
  final double _verticalPadding = 12;
  final double _horizontalPadding = 30;
  final List<Widget> _pages = [];
  List<List<Widget>> _pageGroup = [];
  int _currentPageGroupIndex = 0;
  late AnimationController _animationController;
  late Animation _animationRight;
  late Animation _animationLeft;

  @override
  void initState() {
    super.initState();
    List.generate(
      6,
          (i) => _pages.add(_pageWrap(i + 1)),
    );
    _pageGroup = [
      [_pages[0], _pages[1], _pages[2], _pages[3]],
      [_pages[2], _pages[3], _pages[4], _pages[5]]
    ];
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (_currentPageGroupIndex == _pageGroup.length - 1) {
            _animationController.stop();
            return;
          }
          _animationController.reset();
          Future.delayed(const Duration(seconds: 5), () {
            _animationController.forward();
          });
          setState(() {
            _currentPageGroupIndex++;
          });
        }
      });
    _animationRight = Tween(begin: 0.0, end: pi / 2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, .5),
      ),
    );
    _animationLeft = Tween(begin: -pi / 2, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(.5, 1),
      ),
    );
    Future.delayed(const Duration(seconds: 5), () {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.contain,
            image: AssetImage('assets/images/wood_bg.png'),
          ),
        ),
        child: Stack(
          children: <Widget>[
            Center(
              child: InnerShadow(
                blur: 5,
                shadowColor: Colors.black.withOpacity(.6),
                offset: const Offset(2, 2),
                child: Container(
                  padding: const EdgeInsets.only(left: 22, right: 14),
                  width: (_pageWidth + _horizontalPadding) * 2,
                  height: _pageHeigt + _verticalPadding * 2,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(120, 120, 120, 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SizedBox(
                        width: 8,
                        height: _pageHeigt,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: List.generate(
                            8,
                                (i) => Container(
                              width: 1,
                              height: _pageHeigt - (8 - i),
                              color: i.isEven
                                  ? const Color.fromRGBO(212, 212, 212, 1)
                                  : const Color.fromRGBO(245, 245, 245, 1),
                            ),
                          ),
                        ),
                      ),
                      InnerShadow(
                        blur: 3,
                        shadowColor: Colors.black.withOpacity(.6),
                        offset: const Offset(1, 1),
                        child: Container(
                          width: 66,
                          height: double.infinity,
                          color: const Color.fromRGBO(100, 100, 100, 1),
                        ),
                      ),
                      SizedBox(
                        width: 16,
                        height: _pageHeigt,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: List.generate(
                            16,
                                (i) => Container(
                              width: 1,
                              height: _pageHeigt - i,
                              color: i.isEven
                                  ? const Color.fromRGBO(212, 212, 212, 1)
                                  : const Color.fromRGBO(245, 245, 245, 1),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded( // 让左页自适应
                    child: Stack(
                      children: [
                        _pageGroup[_currentPageGroupIndex][0],
                        Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.0004)
                            ..rotateY(_animationLeft.value),
                          alignment: Alignment.centerRight,
                          child: _pageGroup[_currentPageGroupIndex][2],
                        )
                      ],
                    ),
                  ),
                  Expanded( // 让右页自适应
                    child: Stack(
                      children: [
                        _pageGroup[_currentPageGroupIndex][3],
                        Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.0004)
                            ..rotateY(_animationRight.value),
                          alignment: Alignment.centerLeft,
                          child: _pageGroup[_currentPageGroupIndex][1],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pageWrap(int pageNumber) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 40),
          width: _pageWidth,
          height: _pageHeigt,
          color: Colors.white,
          child: Image.asset(
            'assets/images/book_page$pageNumber.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.fill,
          ),
        ),
        pageNumber.isOdd
            ? Positioned(
          top: 0,
          right: 0,
          bottom: 0,
          child: Container(
            width: 40,
            height: _pageHeigt,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    Color.fromRGBO(188, 188, 188, 1),
                    Color.fromRGBO(200, 200, 200, 1),
                    Color.fromRGBO(240, 240, 240, 1),
                    Color.fromRGBO(255, 255, 255, 1),
                  ],
                  stops: [
                    0,
                    .1,
                    .6,
                    1
                  ]),
            ),
          ),
        )
            : Positioned(
          top: 0,
          left: 0,
          bottom: 0,
          child: Container(
            width: 40,
            height: _pageHeigt,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
                Color.fromRGBO(200, 200, 200, 1),
                Color.fromRGBO(255, 255, 255, 1),
              ]),
            ),
          ),
        ),
        pageNumber.isOdd
            ? Positioned(
          left: 12,
          bottom: 12,
          child: Text(
            '$pageNumber',
          ),
        )
            : Positioned(
          right: 12,
          bottom: 12,
          child: Text(
            '$pageNumber',
          ),
        ),
      ],
    );
  }
}

