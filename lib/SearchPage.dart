import 'package:Movizz/Request.dart';
import 'package:Movizz/custom_librairies/Categories.dart';
import 'package:Movizz/custom_librairies/Search.dart';
import 'package:Movizz/custom_widget/CustomAppBar.dart';
import 'package:Movizz/custom_widget/MoviePreview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:load/load.dart';
import 'all_translations.dart';
import 'custom_icons/movizz_icons.dart';
import 'custom_librairies/Common.dart';
import 'custom_widget/CustomBottomBar.dart';
import 'custom_widget/CustomText.dart';
import 'custom_widget/CustomTop.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  double _screenWidth;
  double _screenHeight;

  var categories = Categories();
  List categoriesList = [];
  List<bool> checkedCategoriesList = [];

  List<Widget> listLastSearchWidget = [];
  List<Widget> searchListMovies = [];

  final searchFiedlController = TextEditingController();
  ScrollController _searchController = new ScrollController();

  Search sharedSearch = new Search();

  final double topBarHeightPercent = 0.06;

  bool isLoadingSearch = false;
  bool hasSearchResult = false;

  int _pageCounter = 1;

  String _searchTerms = "";
  bool _isCategorySearch = false;
  int _categoryIndex;

  Future<void> getLastSearch() async {
    List<String> listLastSearchString = sharedSearch.getLastSearch();
    if (!mounted) return false;
    setState(() {
      listLastSearchWidget = generateLastSearchList(listLastSearchString);
    });
  }

  Future<void> searchMovies(bool newList) async {
    if (!isLoadingSearch) {
      isLoadingSearch = true;

      if (newList) {
        showLoadingDialog();
        _pageCounter = 1;
      }
      
      var response;

      if (_isCategorySearch) {
        response = await fetchPost(RequestType.get, "/discover/movie", {
          "page": _pageCounter.toString(),
          "sort_by": "popularity.desc",
          "with_genres": categoriesList[_categoryIndex]["id"].toString(),
        });
      } else {
        response = await fetchPost(RequestType.get, "/search/movie", {
          "page": _pageCounter.toString(),
          "query": Uri.encodeFull(_searchTerms),
        });
      }

      if (response.status == 200) {
        var listMovies = generateListMoviesFromBody(response.body);

        if (listMovies.length > 0) {
          _pageCounter++;

          if (!mounted) return false;
          setState(() {
            if (newList)
              searchListMovies = listMovies;
            else
              searchListMovies = new List.from(searchListMovies)
                ..addAll(listMovies);

            hasSearchResult = true;
          });
        } else {
          showSnackbar(_scaffoldKey, allTranslations.text("search_no_result"));
          hasSearchResult = false;
        }
      }
      isLoadingSearch = false;

      if (newList) hideLoadingDialog();
    }
  }

  List<Widget> generateListMoviesFromBody(body) {
    List<Widget> listMovies = [];

    for (var i = 0; i < body['results'].length; i++) {
      if (body['results'][i]['id'] == null) continue;
      if (body['results'][i]['title'] == null ||
          body['results'][i]['title'].length == 0) continue;
      if (body['results'][i]['release_date'] == null ||
          body['results'][i]['release_date'].length == 0) continue;
      if (body['results'][i]['overview'] == null ||
          body['results'][i]['overview'].length == 0) continue;
      if (body['results'][i]['poster_path'] == null ||
          body['results'][i]['poster_path'].length == 0) continue;
      if (body['results'][i]['vote_average'] == null) continue;
      if (body['results'][i]['genre_ids'] == null) continue;

      listMovies.add(MoviePreview(
        scaffoldKey: _scaffoldKey,
        widthScreen: _screenWidth,
        heigthScreen: _screenHeight,
        movieId: body['results'][i]['id'],
        movieTitle: body['results'][i]['title'],
        movieDate: body['results'][i]['release_date'],
        movieDescription: body['results'][i]['overview'],
        movieImage: body['results'][i]['poster_path'],
        movieScore: body['results'][i]['vote_average'].toDouble(),
        movieCategories: body['results'][i]['genre_ids'],
      ));
      listMovies.add(buildSeparator(_screenWidth));
    }

    return listMovies;
  }

  List<Widget> generateLastSearchList(listSearch) {
    double _screenWidth = MediaQuery.of(context).size.width;

    List<Widget> widgetList = [];

    for (var i = 0; i < listSearch.length; i++) {
      widgetList.add(
        GestureDetector(
          onTap: () {
            _searchTerms = listSearch[i];
            _isCategorySearch = false;
            searchFiedlController.value = new TextEditingController.fromValue(
                    new TextEditingValue(text: _searchTerms))
                .value;
            searchMovies(true);
          },
          child: Container(
            alignment: Alignment.center,
            color: Colors.white,
            padding: EdgeInsets.only(
              top: _screenWidth * 0.02,
              bottom: _screenWidth * 0.02,
              left: _screenWidth * 0.06,
              right: _screenWidth * 0.01,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                CustomText(
                  text: listSearch[i],
                  fontColor: FontColor.lightGrey,
                  fontSize: FontSize.lg,
                ),
                IconButton(
                  icon: Icon(Movizz.cross),
                  iconSize: CustomText.textSize(FontSize.xl),
                  color: CustomText.textColor(FontColor.lightGrey),
                  onPressed: () async {
                    await sharedSearch.removeSearch(i);
                    await getLastSearch();
                  },
                )
              ],
            ),
          ),
        ),
      );

      widgetList.add(buildSeparator(_screenWidth));
    }

    return widgetList;
  }

  Widget constructTopBar(heightScreen, widthScreen) {
    return new CustomTopbar(
      context: context,
      widthScreen: widthScreen,
      heightScreen: heightScreen,
      appBarHeight: topBarHeightPercent,
      topBarChild: CustomText(
        text: allTranslations.text("title_search"),
        fontColor: FontColor.pink,
        fontSize: FontSize.md,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget buildSearchBarContainer(heightScreen, widthScreen) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: widthScreen * 0.03,
            vertical: widthScreen * 0.02,
          ),
          width: widthScreen,
          color: Colors.white,
          child: Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                  right: widthScreen * 0.02,
                ),
                child: Icon(
                  Movizz.search,
                  size: widthScreen * 0.08,
                  color: CustomText.textColor(FontColor.lightGrey),
                ),
              ),
              Flexible(
                child: TextField(
                  controller: searchFiedlController,
                  style: TextStyle(
                    fontSize: CustomText.textSize(FontSize.md),
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: allTranslations.text("search_textfield"),
                  ),
                  onTap: () {
                    if (_isCategorySearch) {
                      _isCategorySearch = false;
                      searchFiedlController.value =
                          new TextEditingController.fromValue(
                                  new TextEditingValue(text: ""))
                              .value;
                    }
                  },
                ),
              ),
              GestureDetector(
                child: CustomText(
                  text: allTranslations.text("search_button_genre"),
                  fontColor: FontColor.pink,
                  fontSize: FontSize.md,
                  fontWeight: FontWeight.bold,
                ),
                onTap: () {
                  showPicker();
                },
              )
            ],
          ),
        ),
        GestureDetector(
          child: Container(
            width: widthScreen,
            padding: EdgeInsets.symmetric(
              horizontal: widthScreen * 0.03,
              vertical: widthScreen * 0.03,
            ),
            color: Theme.of(context).primaryColor,
            alignment: Alignment.center,
            child: CustomText(
              text: allTranslations.text("search_button_search"),
              fontColor: FontColor.white,
              fontSize: FontSize.lg,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () async {
            _searchTerms = searchFiedlController.text;

            if (!_isCategorySearch && _searchTerms.length > 0) {
              FocusScope.of(context)
                  .requestFocus(FocusNode()); //to loose focus and hide keyboard
              _isCategorySearch = false;
              await searchMovies(true);
              await sharedSearch.addSearch(_searchTerms);
              getLastSearch();
            }
          },
        ),
        buildSeparator(widthScreen),
      ],
    );
  }

  List<String> buidCategoriesList() {
    List<String> checkboxList = [];
    for (var i = 0; i < categoriesList.length; i++) {
      checkboxList.add(categoriesList[i]["name"]);
    }
    return checkboxList;
  }

  showPicker() {
    new Picker(
      adapter: PickerDataAdapter<String>(
        pickerdata: buidCategoriesList(),
      ),
      hideHeader: true,
      itemExtent: 40,
      height: 200,
      cancelText: allTranslations.text("cancel"),
      confirmText: allTranslations.text("confirm"),
      onConfirm: (Picker picker, List value) {
        String categoryNameSelect = picker.getSelectedValues()[0].toUpperCase();
        int categoryIdSelect = value[0];

        _isCategorySearch = true;
        _categoryIndex = categoryIdSelect;

        searchFiedlController.value = new TextEditingController.fromValue(
                new TextEditingValue(text: categoryNameSelect))
            .value;

        searchMovies(true);
      },
    ).showDialog(context);
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    searchFiedlController.dispose();
    super.dispose();
  }

  void initState() {
    super.initState();

    _searchController.addListener(() async {
      if (_searchController.offset >=
          _searchController.position.maxScrollExtent * 0.7) {
        await searchMovies(false);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await sharedSearch.initLastSearch();
      await categories.initCategories(context, allTranslations.currentLanguage);
      categoriesList = categories.getAllCategories();

      await getLastSearch();
    });
  }

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;

    List<Widget> listBodyWidget;

    if (hasSearchResult) {
      listBodyWidget = new List.from([
        buildSearchBarContainer(_screenHeight, _screenWidth),
        buildSeparator(_screenWidth),
      ])
        ..addAll(searchListMovies);
    } else {
      listBodyWidget = [
        buildSearchBarContainer(_screenHeight, _screenWidth),
        buildSeparator(_screenWidth),
      ]..addAll(listLastSearchWidget);
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[200],
      appBar: CustomAppbar(
        context: context,
        widthScreen: _screenWidth,
        heightScreen: _screenHeight,
      ),
      bottomNavigationBar: CustomBottomBar(
        context: context,
        widthScreen: _screenWidth,
        heightScreen: _screenHeight,
      ),
      body: new Stack(children: <Widget>[
        constructTopBar(_screenHeight, _screenWidth),
        Container(
          width: _screenWidth,
          padding: EdgeInsets.only(top: _screenHeight * topBarHeightPercent),
          child: SingleChildScrollView(
            controller: _searchController,
            physics: new ClampingScrollPhysics(),
            child: Column(
              children: listBodyWidget,
            ),
          ),
        ),
      ]),
    );
  }
}
