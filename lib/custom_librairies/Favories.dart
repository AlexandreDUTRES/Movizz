import 'dart:async';
import 'dart:convert';
import 'package:Movizz/all_translations.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'Common.dart';

class Favories {
  static Favories _instance;
  String path;
  Database database;

  static Favories get instance {
    if (_instance == null) _instance = new Favories();
    return _instance;
  }

  Future initTable() async {
    // Get a location using getDatabasesPath
    var databasePath = await getDatabasesPath();
    String path = join(databasePath, "favories.db");

    // open the database
    this.database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE favories (id INTEGER PRIMARY KEY, movieId INTEGER, enable BOOLEAN, movieTitle TEXT, movieDate TEXT, movieDescription TEXT, movieImage TEXT, movieScore REAL, movieCategories TEXT)');
    });
  }

  Future addFavory(GlobalKey<ScaffoldState> scaffoldKey, int movieId,
      Map<String, dynamic> data) async {
    //test if movieId already exist
    List<Map> list = await database
        .rawQuery('SELECT * FROM favories WHERE movieId=' + movieId.toString());

    if (list.length > 0) {
      await database.rawUpdate(
          'UPDATE favories SET enable = 1 WHERE movieId=' + movieId.toString());
    } else {
      var labels =
          "enable, movieId, movieTitle, movieDate, movieDescription, movieImage, movieScore, movieCategories";
      var values = "1," +
          movieId.toString() +
          ",'" +
          sqlEscape(data["movieTitle"]) +
          "','" +
          data["movieDate"] +
          "','" +
          sqlEscape(data["movieDescription"]) +
          "','" +
          data["movieImage"] +
          "'," +
          (data["movieScore"]).toString() +
          ",'" +
          json.encode(data["movieCategories"]) +
          "'";

      // Insert some records in a transaction
      await database.transaction((txn) async {
        await txn.rawInsert(
            'INSERT INTO favories(' + labels + ') VALUES(' + values + ')');
      });
    }

    showSnackbar(scaffoldKey, allTranslations.text("snackbar_add_favorite"));
  }

  Future removeFavory(GlobalKey<ScaffoldState> scaffoldKey, int movieId) async {
    await database.rawUpdate(
        'UPDATE favories SET enable = 0 WHERE movieId=' + movieId.toString());

    showSnackbar(scaffoldKey, allTranslations.text("snackbar_remove_favorite"));
  }

  Future<bool> testFavory(int movieId) async {
    // Get the records
    List<Map> list = await database.rawQuery(
        'SELECT * FROM favories WHERE enable = 1 AND movieId=' +
            movieId.toString());
    if (list.length > 0)
      return true;
    else
      return false;
  }

  Future<List> getFavories() async {
    // Get the records
    List<Map> list =
        await database.rawQuery('SELECT * FROM favories WHERE enable = 1');
    return list;
  }
}

String sqlEscape(String value) {
  if (value != null && value.length > 0) {
    value = value.replaceAll("'", "''");
  }

  return value;
}
