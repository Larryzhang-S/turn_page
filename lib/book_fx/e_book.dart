import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'book_controller.dart';
import 'book_fx.dart';
import 'ebook_controller.dart';
import 'utils/text.dart';


class EBook extends StatefulWidget {
  // 书籍宽度
  final double maxWidth;

  // 书籍高度
  final double maxHeight;

  // 书籍内容
  final String data;

  // 字号
  final double fontSize;

  // 段落间距
  final double fontHeight;

  //书籍边距
  final EdgeInsetsGeometry padding;
  final EBookController? eBookController;
  final BookController bookController;
  final Duration? duration;

  const EBook(
      {Key? key,
      required this.maxWidth,
      required this.data,
      required this.maxHeight,
      this.fontSize = 16.0,
      this.padding = const EdgeInsetsDirectional.all(20),
      this.eBookController,
      required this.bookController,
      this.fontHeight = 1.4,
      this.duration})
      : super(key: key);

  @override
  State<EBook> createState() => _EBookState();
}

class _EBookState extends State<EBook> {
  String data = """""";
  double textHeight = 10;
  int currentStartPos = 0; // 当前页起始文字位置角标
  int nextStartPos = 0; // 下一页起始文字位置角标
  double maxTextHeight = 0; // 文字区域最大高度
  bool isOver = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      /// 文本区域高度 \r\n 计算有误 ... 高度有误
      data = widget.data.replaceAll('\r\n', '\n');

      // print('fontSize $fontSize');
      textHeight = TextUtil.calculateTextHeight('发发发...', widget.fontSize,
          fontHeight: widget.fontHeight,
          maxWidth: widget.maxWidth,
          padding: widget.padding);

      /// 文本最大高度 648
      maxTextHeight =
          ((widget.maxHeight - widget.padding.vertical) ~/ textHeight) *
              textHeight;

      print('textHeight${textHeight}');
      print('maxTextHeight${maxTextHeight}');
      // print(
      //     'calculateTextHeight${calculateTextHeight(data.substring(0, 140), fontSize)}');
      // print('data index ${data.substring(0, 440)}');

      // widget.eBookController?.addListener(() {
      //   /// 改变字号
      //   fontSize = widget.eBookController?.fontSize ?? 18;
      //   textHeight = calculateTextHeight('疯', fontSize,
      //       fontHeight: widget.fontHeight,
      //       maxWidth: widget.maxWidth,
      //       padding: widget.padding);
      //
      //   /// 文本最大高度 648
      //   maxTextHeight = (widget.maxHeight ~/ textHeight) * textHeight;
      //   isOver = false;

      /// 获取书籍所有页码
      // loadPages().then((value) {
      //   // print("字号$fontSize");
      //   setState(() {});
      // });
      // });

      /// 获取书籍所有页码
      loadPages();
    });
  }

  @override
  void dispose() {
    // widget.eBookController?.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isOver
        ? BookFx(
            size: Size(MediaQuery.of(context).size.width, widget.maxHeight),
            pageCount: allPages.length - 1,
            currentBgColor: Colors.yellow.shade800,
            nextCallBack: (index) {
              debugPrint('下一页  $index');
            },
            lastCallBack: (index) {
              debugPrint('上一页  $index');
            },
            duration: widget.duration,
            nextPage: (index) {
              /// 下一页
              return index >= allPages.length - 1
                  ? const SizedBox()
                  : Stack(
                      children: [
                        Container(
                            width: double.infinity,
                            height: double.infinity,
                            padding: widget.padding,
                            color: Colors.yellow,
                            child: Stack(
                              children: [
                                Text(
                                  data.isNotEmpty
                                      ? data.substring(
                                          allPages[index], allPages[index + 1])
                                      : "",
                                  maxLines: maxTextHeight ~/ textHeight,
                                  strutStyle: StrutStyle(
                                    forceStrutHeight: true,
                                    height: widget.fontHeight,
                                    fontSize: widget.fontSize,
                                  ),
                                  style: TextStyle(
                                      height: widget.fontHeight,
                                      fontSize: widget.fontSize,
                                      color: const Color(0xff333333)),
                                ),
                              ],
                            )),
                        Positioned(
                          child: Text("${index + 1}/${allPages.length - 1}"),
                          bottom: 5,
                          right: 20,
                        )
                      ],
                    );
            },
            currentPage: (int index) {
              print('当前哦index $index ${allPages[index]}');

              /// 当前页 index 页码
              return Stack(
                children: [
                  Container(
                    padding: widget.padding,
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.yellow,
                    child: Text(
                      data.isNotEmpty
                          ? data.substring(allPages[index], allPages[index + 1])
                          : "",
                      maxLines: maxTextHeight ~/ textHeight,
                      strutStyle: StrutStyle(
                        forceStrutHeight: true,
                        height: widget.fontHeight,
                        fontSize: widget.fontSize,
                      ),
                      style: TextStyle(
                          fontSize: widget.fontSize,
                          height: widget.fontHeight,
                          color: const Color(0xff333333)),
                    ),
                  ),
                  Positioned(
                    child: Text("${index + 1}/${allPages.length - 1}"),
                    bottom: 5,
                    right: 20,
                  )
                ],
              );
            },
            controller: widget.bookController,
          )
        : const CupertinoActivityIndicator();
  }

  List<int> allPages = [];

  /// 每页最多1000字计算
  Future loadPages() async {
    allPages.clear();
    debugPrint("开始${DateTime.now()}");
    var request = TaskRequest(data, widget.fontSize, widget.fontHeight,
        widget.maxWidth, widget.padding, maxTextHeight);
    debugPrint('r ${request.fontSize}');
    debugPrint('r ${request.fontHeight}');

    // TaskResult result = await compute<TaskRequest, TaskResult>(
    //     _doTaskPageIndex,
    //     TaskRequest(data, widget.fontSize, widget.fontSize, widget.maxWidth,
    //         widget.padding, maxTextHeight),
    //     debugLabel: 'w');
    // setState(() {
    //   allPages.addAll(result.result);
    // });

    return await Future(() {
      List<int> allPages = [];
      int num = 0;
      int index = 0;
      allPages.add(index);
      int left = index;
      int right = 1000;
      while (true) {
        num++;
        if (right >= request.data.length) {
          right = request.data.length;
          // debugPrint("结尾 left$left  right$right");
          // if (TextUtil.calculateTextHeight(
          //     request.data.substring(left, right), request.fontSize,
          //     fontHeight: request.fontHeight,
          //     maxWidth: request.maxWidth,
          //     padding: request.padding) <= request.maxTextHeight) {
          //   allPages.add(left);
          //   debugPrint("结束");
          //   debugPrint("allPages ${allPages.toString()}");
          //   debugPrint("结束${DateTime.now()}");
          //   debugPrint("结束循环次数$num");
          //   TaskResult result = TaskResult(cost: 200, result: allPages);
          //   setState(() {
          //     this.allPages.addAll(result.result);
          //     isOver = true;
          //   });
          //   return result;
          // }
        }

        int mid = (left + right) ~/ 2;
        if (TextUtil.calculateTextHeight(
                request.data.substring(index, mid), request.fontSize,
                fontHeight: request.fontHeight,
                maxWidth: request.maxWidth,
                padding: request.padding) ==
            request.maxTextHeight) {
          for (int i = 0; i < 100; i++) {
            num++;
            if (TextUtil.calculateTextHeight(
                    request.data.substring(index, mid + i), request.fontSize,
                    fontHeight: request.fontHeight,
                    maxWidth: request.maxWidth,
                    padding: request.padding) >
                request.maxTextHeight) {
              index = mid + i - 1;
              left = index;
              right = index + 1000;
              if (index < request.data.length - 3 &&
                  request.data.substring(index, index + 3).startsWith(''
                      '\n')) {
                index += 2;
              }
              allPages.add(index);
              break;
            }
          }
        } else if (TextUtil.calculateTextHeight(
                request.data.substring(index, mid), request.fontSize,
                fontHeight: request.fontHeight,
                maxWidth: request.maxWidth,
                padding: request.padding) <
            request.maxTextHeight) {
          if (mid >= data.length - 1) {
            allPages.add(mid);
            TaskResult result = TaskResult(cost: 200, result: allPages);
            setState(() {
              this.allPages.addAll(result.result);
              isOver = true;
            });
            debugPrint("结束");
            debugPrint("allPages ${allPages.toString()}");
            debugPrint("结束${DateTime.now()}");
            debugPrint("结束循环次数$num");
            return result;
          }
          left = mid + 1;
        } else if (TextUtil.calculateTextHeight(
                request.data.substring(index, mid), request.fontSize,
                fontHeight: request.fontHeight,
                maxWidth: request.maxWidth,
                padding: request.padding) >
            request.maxTextHeight) {
          right = mid - 1;
        }
      }
    });
  }

  static Future<TaskResult> _doTaskPageIndex(TaskRequest request) async {
    List<int> allPages = [];
    int num = 0;
    int index = 0;
    allPages.add(index);
    int left = index;
    int right = 1000;
    while (true) {
      num++;
      if (right >= request.data.length) {
        right = request.data.length;
        debugPrint("结尾 ");
        if (TextUtil.calculateTextHeight(
                request.data.substring(left, right), request.fontSize,
                fontHeight: request.fontHeight,
                maxWidth: request.maxWidth,
                padding: request.padding) <=
            request.maxTextHeight) {
          allPages.add(left);
          debugPrint("结束");
          debugPrint("allPages ${allPages.toString()}");
          debugPrint("结束${DateTime.now()}");
          debugPrint("结束循环次数$num");
          TaskResult result = TaskResult(cost: 200, result: allPages);
          return result;
        }
      }
      int mid = (left + right) ~/ 2;
      if (TextUtil.calculateTextHeight(
              request.data.substring(index, mid), request.fontSize,
              fontHeight: request.fontHeight,
              maxWidth: request.maxWidth,
              padding: request.padding) ==
          request.maxTextHeight) {
        for (int i = 0; i < 100; i++) {
          num++;
          if (TextUtil.calculateTextHeight(
                  request.data.substring(index, mid + i), request.fontSize,
                  fontHeight: request.fontHeight,
                  maxWidth: request.maxWidth,
                  padding: request.padding) >
              request.maxTextHeight) {
            index = mid + i - 1;
            left = index;
            right = index + 1000;
            if (index < request.data.length - 3 &&
                request.data.substring(index, index + 3).startsWith(''
                    '\n')) {
              index += 2;
            }
            allPages.add(index);

            break;
          }
        }
      } else if (TextUtil.calculateTextHeight(
              request.data.substring(index, mid), request.fontSize,
              fontHeight: request.fontHeight,
              maxWidth: request.maxWidth,
              padding: request.padding) <
          request.maxTextHeight) {
        debugPrint('left $left');
        left = mid + 1;
      } else if (TextUtil.calculateTextHeight(
              request.data.substring(index, mid), request.fontSize,
              fontHeight: request.fontHeight,
              maxWidth: request.maxWidth,
              padding: request.padding) >
          request.maxTextHeight) {
        right = mid - 1;
      }
    }
  }
}

class TaskRequest {
  final String data;
  final double fontSize;
  final double fontHeight;
  final double maxWidth;
  final double maxTextHeight;
  final EdgeInsetsGeometry padding;

  TaskRequest(
    this.data,
    this.fontSize,
    this.fontHeight,
    this.maxWidth,
    this.padding,
    this.maxTextHeight,
  );
}

class TaskResult {
  final int cost;
  final List<int> result;

  TaskResult({required this.cost, required this.result});
}
