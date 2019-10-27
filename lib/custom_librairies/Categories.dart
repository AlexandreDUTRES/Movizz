import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

class Categories {
  static Categories _instance;
  BuildContext _currentContext;

  List<dynamic> categoriesData;

  static Categories get instance {
    if (_instance == null) _instance = new Categories();
    return _instance;
  }

  Future initCategories(context, lang) async {
    _currentContext = context;
    String data = await DefaultAssetBundle.of(_currentContext)
        .loadString("assets/categories/" + lang + ".json");
    this.categoriesData = json.decode(data)["genres"];
  }

  String getNameCategorie(int id) {
    var name = "";
    for (var i = 0; i < this.categoriesData.length; i++) {
      if (this.categoriesData[i]["id"] == id)
        name = this.categoriesData[i]["name"];
    }

    return name;
  }

  String arrayCategoriesToString(List movieCategories) {
    const maxCategories = 2;
    var str = "";

    for (var i = 0; i < movieCategories.length; i++) {
      if (i >= maxCategories) break;
      str += getNameCategorie(movieCategories[i]) + ", ";
    }

    if (str.length > 0) str = str.substring(0, str.length - 2);

    return str;
  }

  List<dynamic> getAllCategories() {
    return this.categoriesData;
  }
}
