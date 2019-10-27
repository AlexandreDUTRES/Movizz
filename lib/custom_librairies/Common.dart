import 'dart:io';

import 'package:Movizz/all_translations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget buildSeparator(width) {
  return Container(
    height: 3,
    width: width,
    color: Colors.grey[200],
  );
}

String formatDateWithLocale(String dateToConvert) {
  var standardDateFormat = new DateFormat("yyyy-MM-dd");

  DateTime tmp = standardDateFormat.parse(dateToConvert);

  DateFormat finalFormat =
      new DateFormat.yMMMMd(allTranslations.currentLanguage);

  return finalFormat.format(tmp);
}

String getAppId() {
  if (Platform.isIOS) {
    return 'ca-app-pub-3799016640529761~3854165122';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-3799016640529761~5666720498';
  }
  return null;
}

String getInterstitialId() {
  if (Platform.isIOS) {
    return 'ca-app-pub-3799016640529761/7061130002';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-3799016640529761/5190888403';
  }
  return null;
}

void showSnackbar(GlobalKey<ScaffoldState> scaffoldKey, String text) {
  final snackBar = SnackBar(content: Text(text));
  scaffoldKey.currentState.hideCurrentSnackBar();
  scaffoldKey.currentState.showSnackBar(snackBar);
}

void showAlertDialog(String title, BuildContext context, Function() callback) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      if (Platform.isAndroid) {
        return AlertDialog(
          content: new Text(title),
          actions: <Widget>[
            new FlatButton(
              child: new Text(allTranslations.text("cancel")),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text(allTranslations.text("confirm")),
              onPressed: () {
                return callback();
              },
            )
          ],
        );
      } else {
        return new CupertinoAlertDialog(
          title: new Text(title),
          actions: <Widget>[
            new FlatButton(
              child: new Text(allTranslations.text("cancel")),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text(allTranslations.text("confirm")),
              onPressed: () {
                return callback();
              },
            )
          ],
        );
      }
    },
  );
}
