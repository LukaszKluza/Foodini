import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TitleTextWidgets {
  static Widget scaledTitle(String text, {FontStyle fontStyle = FontStyle.italic, bool longText = false}) {
    double fontSize = longText ? 80.sp.clamp(20.0, 24.0) : 80.sp.clamp(25.0, 35.0);

    return Text(
      text,
      textAlign: TextAlign.center,
      softWrap: longText ? true : false,
      overflow: TextOverflow.visible,
      style: TextStyle(
        fontSize: fontSize,
        fontStyle: fontStyle,
      ),
    );
  }
}
