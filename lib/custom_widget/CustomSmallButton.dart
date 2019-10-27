import 'package:Movizz/custom_widget/CustomText.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class CustomSmallButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final FontColor fontColor;
  final FontSize fontSize;
  final FontWeight fontWeight;
  final void Function() onPressed;
  final Color backgroundColor;
  final Color borderColor;

  CustomSmallButton(
      {@required this.text,
      @required this.onPressed,
      @required this.fontColor,
      @required this.backgroundColor,
      @required this.borderColor,
      this.fontSize = FontSize.sm,
      this.fontWeight = FontWeight.normal,
      this.icon});

  @override
  Widget build(BuildContext context) {
    List<Widget> listWidget = [];

    listWidget.add(CustomText(
      text: text,
      fontColor: fontColor,
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
    ));

    if (icon != null) {
      listWidget.add(Icon(
        icon,
        size: CustomText.textSize(fontSize),
        color: CustomText.textColor(fontColor),
      ));
    }

    return GestureDetector(
      onTap: onPressed,
      child: Container(
          decoration: new BoxDecoration(
            color: backgroundColor,
            borderRadius: new BorderRadius.all(const Radius.circular(5)),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          padding: EdgeInsets.symmetric(vertical: 3, horizontal: 7),
          child: Row(children: listWidget)),
    );
  }
}
