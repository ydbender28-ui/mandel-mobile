import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/utility/common_custom_color.dart';

class TopIndicator extends Decoration {
  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _TopIndicatorBox();
  }
}

class _TopIndicatorBox extends BoxPainter {
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    Paint _paint = Paint()
      ..color = CommonCustomColor.mandelPrimaryColor
      ..strokeWidth = 2
      ..isAntiAlias = true;

    canvas.drawLine(
        Offset(offset.dx, 0), Offset(cfg.size!.width + (offset.dx), 0), _paint);
  }
}
