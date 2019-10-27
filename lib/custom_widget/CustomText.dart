import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

enum FontOpacity { max, medium, min, none }

enum FontColor { white, dark, lightGrey, darkGrey, pink, blue }

enum FontSize { xs, sm, md, lg, xl }

class CustomText extends StatelessWidget {
  final String text;
  final FontColor fontColor;
  final FontSize fontSize;
  final FontWeight fontWeight;
  final FontOpacity fontOpacity;
  final TextAlign alignment;
  final int maxLines;
  final bool underline;
  final TextOverflow overflowStyle;

  CustomText({
    @required this.text,
    @required this.fontColor,
    @required this.fontSize,
    this.fontWeight = FontWeight.normal,
    this.fontOpacity = FontOpacity.none,
    this.alignment = TextAlign.start,
    this.maxLines = 2,
    this.underline = false,
    this.overflowStyle = TextOverflow.ellipsis,
  });

  static Color textColor(FontColor fontColor) {
    Color color;
    switch (fontColor) {
      case FontColor.white:
        color = Colors.white;
        break;
      case FontColor.dark:
        color = Colors.black;
        break;
      case FontColor.lightGrey:
        color = const Color(0xff999999);
        break;
      case FontColor.darkGrey:
        color = const Color(0xff666666);
        break;
      case FontColor.pink:
        color = const Color(0xFFff1493);
        break;
      case FontColor.blue:
        color = const Color(0xFF1E90FF);
        break;
    }

    return color;
  }

  static double textSize(FontSize fontSize) {
    double size;
    switch (fontSize) {
      case FontSize.xs:
        size = 10;
        break;
      case FontSize.sm:
        size = 12;
        break;
      case FontSize.md:
        size = 14;
        break;
      case FontSize.lg:
        size = 16;
        break;
      case FontSize.xl:
        size = 18;
        break;
    }

    return size;
  }

  @override
  Widget build(BuildContext context) {
    return new Text(
      text,
      maxLines: maxLines,
      overflow: overflowStyle,
      textAlign: alignment,
      style: new TextStyle(
        decoration: underline ? TextDecoration.underline : TextDecoration.none,
        fontSize: textSize(fontSize),
        color: textColor(fontColor),
        fontWeight: fontWeight,
      ),
    );
  }
}
