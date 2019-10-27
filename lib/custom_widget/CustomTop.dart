import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTopbar extends StatelessWidget {
  final BuildContext context;
  final double heightScreen;
  final double widthScreen;
  final double appBarHeight;
  final Widget topBarChild;

  CustomTopbar({
    @required this.context,
    @required this.heightScreen,
    @required this.widthScreen,
    @required this.appBarHeight,
    @required this.topBarChild,
  });

  @override
  Widget build(BuildContext context) {
    double topBarHeight = heightScreen * appBarHeight;
    return new Positioned(
        width: widthScreen,
        child: Container(
          alignment: Alignment.center,
          width: widthScreen,
          height: topBarHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[300],
                width: 3,
              ),
            ),
          ),
          child: topBarChild,
        ));
  }
}
