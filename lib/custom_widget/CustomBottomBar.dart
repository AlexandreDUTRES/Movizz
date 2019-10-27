import 'package:Movizz/custom_icons/movizz_icons.dart';
import 'package:flutter/material.dart';

class CustomBottomBar extends StatelessWidget {
  final BuildContext context;
  final double heightScreen;
  final double widthScreen;
  final double appBarHeight;
  final double appBarWidth;
  final double appBarIconHeight;
  final double appBarBorderHeight;

  CustomBottomBar({
    @required this.context,
    @required this.heightScreen,
    @required this.widthScreen,
    this.appBarHeight = 0.07,
    this.appBarWidth = 1.0,
    this.appBarIconHeight = 0.040,
    this.appBarBorderHeight = 0.01,
  });

  
  Widget buildBottomNavigationBar() {
    double iconSize = this.heightScreen * this.appBarIconHeight;
    double borderHeight = this.heightScreen * this.appBarBorderHeight;
    double outBorderHeight =
        this.heightScreen * this.appBarHeight - borderHeight;

    Widget buildTopBorder() {
      return Container(
        height: borderHeight,
        width: this.widthScreen,
        color: Colors.grey[300],
      );
    }

    Widget buildIconsRow() {
      return Container(
        color: Colors.white,
        height: outBorderHeight,
        width: this.widthScreen,
        alignment: Alignment.topCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            IconButton(
              iconSize: iconSize,
              color: Theme.of(context).primaryColor,
              icon: Icon(Movizz.trends),
              onPressed: () {
                return Navigator.pushReplacementNamed(this.context, "/home");
              },
            ),
            IconButton(
              iconSize: iconSize,
              color: Theme.of(context).primaryColor,
              icon: Icon(Movizz.search),
              onPressed: () {
                return Navigator.pushReplacementNamed(this.context, "/search");
              },
            ),
            IconButton(
              iconSize: iconSize,
              color: Theme.of(context).primaryColor,
              icon: Icon(Movizz.heart),
              onPressed: () {
                return Navigator.pushReplacementNamed(this.context, "/favories");
              },
            )
          ],
        ),
      );
    }

    return Container(
      height: this.heightScreen * this.appBarHeight,
      width: this.appBarWidth,
      child: Column(
        children: <Widget>[
          buildTopBorder(),
          buildIconsRow(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildBottomNavigationBar();
  }
}
