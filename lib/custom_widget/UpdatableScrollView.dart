import 'package:flutter/material.dart';

class UpdatableScrollView extends StatelessWidget {
  final List<Widget> listWidget;
  final VoidCallback updateMethod;
  final ScrollController scrollingController;

  UpdatableScrollView(
      {@required this.listWidget,
      @required this.updateMethod,
      this.scrollingController});

  
  @override
  Widget build(BuildContext context) {
    return new RefreshIndicator(
      onRefresh: this.updateMethod,
      displacement: 30.0,
      child: new SingleChildScrollView(
        controller: this.scrollingController,
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: this.listWidget,
        ),
      ),
    );
  }
}
