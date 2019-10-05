import 'dart:math';

import 'package:flutter/material.dart';

/*
 * https://gist.github.com/collinjackson/4fddbfa2830ea3ac033e34622f278824
*/
class CustomIndicator extends AnimatedWidget {
  CustomIndicator({
    this.controller,
    this.itemCount,
    this.color: Colors.white,
  }) : super(listenable: controller);

  final PageController controller;
  final int itemCount;
  final Color color;

  static const double _kDotSpacing = 25.0;
  static const double _kMaxZoom = 2.0;
  static const double _itemWidth = 10.0;
  static const double _itemHeight = 1.5;

  @override
  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: new List<Widget>.generate(itemCount, _buildDot),
    );
  }

  Widget _buildDot(int index) {
    double selectedness = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - ((controller.page ?? controller.initialPage) - index).abs(),
      ),
    );

    double zoom = 1.0 + (_kMaxZoom - 1.0) * selectedness;
    // 計算每一個 item 顔色的透明度
    var alpha = (255 * selectedness).toInt();
    // 設定透明度的最低值
    if (alpha < 102) {
      alpha = 102;
    }

    return new Container(
      width: _kDotSpacing,
      child: new Center(
        child: Container(
          // 自己畫一個長方形
          child: CustomPaint(
            painter: ShapesPainter(alpha: alpha),
            size: Size(_itemWidth * zoom, _itemHeight * zoom),
          ),
        ),
      ),
    );
  }
}

class ShapesPainter extends CustomPainter {
  int alpha = 255;

  ShapesPainter({this.alpha}) : super();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    // set the color property of the paint
    paint.color = Colors.white.withAlpha(alpha);
    // center of the canvas is (x,y) => (width/2, height/2)
    var center = Offset(size.width / 2, size.height / 2);

    // draw the circle on centre of canvas having radius 75.0
    canvas.drawRect(
        Rect.fromCenter(center: center, width: size.width, height: size.height),
        paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
