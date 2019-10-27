import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class Search {
  static Search _instance;
  List<String> _lastSearch;

  SharedPreferences prefs;

  final int _maxIndex = 5;

  static Search get instance {
    if (_instance == null) _instance = new Search();
    return _instance;
  }

  Future initLastSearch() async {
    this.prefs = await SharedPreferences.getInstance();

    List<String> tmpList = this.prefs.getStringList("lastSearch");

    if(tmpList != null) this._lastSearch = tmpList;
    else this._lastSearch = [];
  }

  Future addSearch(String terms) async {
    if (this._lastSearch.contains(terms)) this._lastSearch.remove(terms);

    List<String> tmpList = new List.from([terms])..addAll(this._lastSearch);

    if (tmpList.length >= _maxIndex)
      this._lastSearch = tmpList.sublist(0, _maxIndex);
    else
      this._lastSearch = tmpList;

    await this.prefs.setStringList("lastSearch", this._lastSearch);
  }

  Future removeSearch(int index) async {
    this._lastSearch.removeAt(index);

    await this.prefs.setStringList("lastSearch", this._lastSearch);
  }

  List<String> getLastSearch(){
    return this._lastSearch;
  }

}
