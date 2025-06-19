import 'package:flutter/widgets.dart';

class ResponsiveUtils {
  static double scaledFontSize(BuildContext context, double baseSize) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final shortest = size.shortestSide;
    final longest = size.longestSide;
    final aspectRatio = longest / shortest;

    double scaleFactor = shortest / 375.0;

    if (width > height) {
      scaleFactor *= 0.70;
    }

    final aspectPenalty = aspectRatio > 2.0 ? 0.95 : 1.0;

    return baseSize * scaleFactor * aspectPenalty;
  }
}
