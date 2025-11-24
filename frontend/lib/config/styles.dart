import 'package:flutter/material.dart';

class Styles {
  static const TextStyle errorStyle = TextStyle(color: Colors.red);
  static const TextStyle warningStyle = TextStyle(color: Colors.orange);
  static const TextStyle successStyle = TextStyle(color: Colors.green);

  static TextStyle kaushanScriptStyle([double fontSize = 32]) {
    return TextStyle(fontSize: fontSize, fontFamily: 'KaushanScript');
  }
}
