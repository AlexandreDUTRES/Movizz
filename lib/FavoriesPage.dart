import 'dart:convert';

import 'package:Movizz/custom_librairies/Favories.dart';
import 'package:Movizz/custom_widget/CustomAppBar.dart';
import 'package:Movizz/custom_widget/MoviePreview.dart';
import 'package:flutter/material.dart';
import 'all_translations.dart';
import 'custom_librairies/Common.dart';
import 'custom_widget/CustomBottomBar.dart';
import 'custom_widget/CustomText.dart';
import 'custom_widget/CustomTop.dart';
import 'custom_widget/UpdatableScrollView.dart';

class FavoriesPage extends StatefulWidget {
  @override
  _FavoriesPageState createState() => _FavoriesPageState();
}

class _FavoriesPageState extends State<FavoriesPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Widget> favoriesListMovies = [];
  Favories favories = Favories();

  final double topBarHeightPercent = 0.06;

  Future<void> getFavories() async {
    List listFavories = await favories.getFavories();

    listFavories = listFavories.reversed.toList();

    var listMovies = generateMoviesPreviewFromSQFList(listFavories);

    if (!mounted) return false;
    setState(() {
      favoriesListMovies = listMovies;
    });
  }

  List<Widget> generateMoviesPreviewFromSQFList(list) {
    List<Widget> listMovies = [];
    double _screenWidth = MediaQuery.of(context).size.width;
    double _screenHeight = MediaQuery.of(context).size.height;

    for (var i = 0; i < list.length; i++) {
      listMovies.add(MoviePreview(
        scaffoldKey: _scaffoldKey,
        widthScreen: _screenWidth,
        heigthScreen: _screenHeight,
        movieId: list[i]['movieId'],
        movieTitle: list[i]['movieTitle'],
        movieDate: list[i]['movieDate'],
        movieDescription: list[i]['movieDescription'],
        movieImage: list[i]['movieImage'],
        movieScore: list[i]['movieScore'].toDouble(),
        movieCategories: json.decode(list[i]['movieCategories']),
      ));
      listMovies.add(buildSeparator(_screenWidth));
    }

    return listMovies;
  }

  Widget constructTopBar(heightScreen, widthScreen) {
    return new CustomTopbar(
      context: context,
      widthScreen: widthScreen,
      heightScreen: heightScreen,
      appBarHeight: topBarHeightPercent,
      topBarChild: CustomText(
        text: allTranslations.text("title_favorites"),
        fontColor: FontColor.pink,
        fontSize: FontSize.md,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await favories.initTable();
      await getFavories();
    });
  }

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    double _screenHeight = MediaQuery.of(context).size.height;

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
          color: Colors.transparent,
          padding: EdgeInsets.only(top: _screenHeight * topBarHeightPercent),
          child: UpdatableScrollView(
            updateMethod: () async {
              await getFavories();
            },
            listWidget: favoriesListMovies,
          ),
        ),
      ]),
    );
  }
}
