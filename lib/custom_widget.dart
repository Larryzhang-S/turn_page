import 'package:flutter/material.dart';
import 'package:page_turn/book_fx/book_controller.dart';
import 'package:page_turn/book_fx/book_fx.dart';

/// 自定义
class CustomWidget extends StatefulWidget {
  const CustomWidget({Key? key}) : super(key: key);

  @override
  State<CustomWidget> createState() => _CustomWidgetState();
}

class _CustomWidgetState extends State<CustomWidget> {
  final BookController bookController = BookController();
  final List<List<String>> imagePairs = [
    ['assets/aaa.webp', 'assets/bbb.webp'],
    ['assets/ccc.webp', 'assets/ddd.webp'],
    ['assets/ddd.webp', 'assets/aaa.webp'],
    ['assets/bbb.webp', 'assets/ccc.webp'],
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BookFx(
      size: Size(size.width, size.height),
      pageCount: imagePairs.length,
      currentPage: (index) {
        return BookImage(images: imagePairs[index], size: size);
      },
      nextPage: (index) {
        return BookImage(images: imagePairs[index], size: size);
      },
      lastCallBack: (index) => print('上一页: $index'),
      nextCallBack: (index) => print('下一页: $index'),
      controller: bookController,
    );
  }
}

/// 图片组件，左右排版两张不同的图片
class BookImage extends StatelessWidget {
  final List<String> images;
  final Size size;

  const BookImage({Key? key, required this.images, required this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Image.asset(
            images[0],
            fit: BoxFit.cover,
            width: size.width / 2,
            height: size.height,
          ),
        ),
        Expanded(
          child: Image.asset(
            images[1],
            fit: BoxFit.cover,
            width: size.width / 2,
            height: size.height,
          ),
        ),
      ],
    );
  }
}
