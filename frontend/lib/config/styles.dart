import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Styles {
  static TextStyle titleStyle = TextStyle(
    fontSize: 40.sp.clamp(30.0, 50.0),
    fontStyle: FontStyle.italic,
  );

  static const TextStyle errorStyle = TextStyle(color: Colors.red);
  static const TextStyle warningStyle = TextStyle(color: Colors.orange);
  static const TextStyle successStyle = TextStyle(color: Colors.green);

  static TextStyle kaushanScriptStyle([double fontSize = 32]) {
    return TextStyle(fontSize: fontSize, fontFamily: 'KaushanScript');
  }
}
