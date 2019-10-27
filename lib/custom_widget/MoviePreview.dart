import 'package:Movizz/custom_icons/movizz_icons.dart';
import 'package:Movizz/custom_librairies/Categories.dart';
import 'package:Movizz/custom_librairies/Common.dart';
import 'package:Movizz/custom_librairies/Favories.dart';
import 'package:Movizz/custom_widget/CustomSmallButton.dart';
import 'package:Movizz/custom_widget/CustomText.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../all_translations.dart';

const imagePrefix = "https://image.tmdb.org/t/p/w500";

class MoviePreview extends StatefulWidget {
  MoviePreview(
      {@required this.heigthScreen,
      @required this.widthScreen,
      @required this.movieId,
      @required this.movieTitle,
      @required this.movieDate,
      @required this.movieDescription,
      @required this.movieImage,
      @required this.movieScore,
      @required this.movieCategories,
      @required this.scaffoldKey});

  final double heigthScreen;
  final double widthScreen;
  final int movieId;
  final String movieTitle;
  final String movieDate;
  final String movieDescription;
  final String movieImage;
  final double movieScore;
  final List movieCategories;
  final GlobalKey<ScaffoldState> scaffoldKey;

  final double imageWidth = 0.3;
  final double imageHeight = 0.2;
  final double infosWidth = 0.7;
  final double infosPadding = 0.01;

  @override
  _MoviePreview createState() => new _MoviePreview();
}

class _MoviePreview extends State<MoviePreview> {
  bool _isFavorite = false;
  Categories categories = Categories();
  Favories favories = Favories();

  bool _showDescription = false;
  int _numberLinesDescription = 1;

  String _categoriesString = "";

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  didUpdateWidget(MoviePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      _categoriesString =
          categories.arrayCategoriesToString(widget.movieCategories);
    });

    favories.testFavory(widget.movieId).then((isFav) {
      setState(() {
        _isFavorite = isFav;
      });
    });
  }

  GlobalKey _containerInfosKey = new GlobalKey();
  GlobalKey _bottomInfosKey = new GlobalKey();
  GlobalKey _topInfosKey = new GlobalKey();

  Size getSizes(key) {
    if (key.currentContext != null) {
      final RenderBox render = key.currentContext.findRenderObject();
      final size = render.size;
      return size;
    } else
      return Size.zero;
  }

  int calculateNumberLinesDescription() {
    double totalHeight = getSizes(_containerInfosKey).height;
    double topHeight = getSizes(_topInfosKey).height;
    double bottomHeight = getSizes(_bottomInfosKey).height;

    double restHeight = totalHeight - (topHeight + bottomHeight);

    return (restHeight / 20).floor();
  }

  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await categories.initCategories(context, allTranslations.currentLanguage);
      await favories.initTable();

      bool isFav = await favories.testFavory(widget.movieId);

      setState(() {
        _numberLinesDescription = calculateNumberLinesDescription();
        _showDescription = true;
        _categoriesString =
            categories.arrayCategoriesToString(widget.movieCategories);
        _isFavorite = isFav;
      });
    });
  }

  Future clickOnFavoriteButton() async {
    if (_isFavorite) {
      await removeMovieToFavories();
    } else {
      await addMovieToFavories();
    }
  }

  Future addMovieToFavories() async {
    await favories.addFavory(widget.scaffoldKey, widget.movieId, {
      "movieTitle": widget.movieTitle,
      "movieDate": widget.movieDate,
      "movieDescription": widget.movieDescription,
      "movieImage": widget.movieImage,
      "movieScore": widget.movieScore,
      "movieCategories": widget.movieCategories,
    });
    setState(() {
      _isFavorite = true;
    });
  }

  Future removeMovieToFavories() async {
    await favories.removeFavory(widget.scaffoldKey, widget.movieId);
    setState(() {
      _isFavorite = false;
    });
  }

  Widget moviePoster() {
    double imageHeight = widget.imageHeight * widget.heigthScreen;
    double imageWidth = imageHeight / 1.5;

    return GestureDetector(
      child: CachedNetworkImage(
        imageUrl: imagePrefix + widget.movieImage,
        height: imageHeight,
        width: imageWidth,
        fit: BoxFit.fill,
        placeholder: (context, url) => new Container(
          height: imageHeight,
          width: imageWidth,
          color: Colors.grey[200],
        ),
      ),
      onTap: () {
        return Navigator.pushNamed(context, "/movie",
            arguments: {"movieId": widget.movieId});
      },
    );
  }

  Widget movieInfos() {
    return Expanded(
      child: Container(
        key: _containerInfosKey,
        padding: EdgeInsets.all(widget.infosPadding * widget.widthScreen),
        height: widget.imageHeight * widget.heigthScreen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            topInfosMovie(),
            bottomInfosMovie(),
          ],
        ),
      ),
    );
  }

  Widget topInfosMovie() {
    return Column(
      key: _topInfosKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CustomText(
          text: widget.movieTitle,
          fontSize: FontSize.md,
          fontColor: FontColor.dark,
          fontWeight: FontWeight.bold,
          maxLines: 2,
        ),
        Padding(
          padding: EdgeInsets.only(top: 3),
        ),
        Row(
          children: <Widget>[
            CustomText(
              text: allTranslations.text("movie_release_date") + " ",
              fontSize: FontSize.sm,
              fontColor: FontColor.darkGrey,
            ),
            CustomText(
              text: formatDateWithLocale(widget.movieDate),
              fontSize: FontSize.sm,
              fontColor: FontColor.darkGrey,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: 3),
        ),
        Row(
          children: <Widget>[
            CustomText(
              text: allTranslations.text("movie_genre") + " ",
              fontSize: FontSize.sm,
              fontColor: FontColor.darkGrey,
            ),
            CustomText(
              text: _categoriesString,
              fontSize: FontSize.sm,
              fontColor: FontColor.darkGrey,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: 5),
        ),
        Visibility(
          visible: _showDescription,
          child: CustomText(
            text: widget.movieDescription,
            fontSize: FontSize.xs,
            fontColor: FontColor.darkGrey,
            maxLines: _numberLinesDescription,
          ),
        )
      ],
    );
  }

  Widget bottomInfosMovie() {
    var bgFavoryColor =
        (_isFavorite ? Theme.of(context).primaryColor : Colors.transparent);
    var fontFavoryColor = (_isFavorite ? FontColor.white : FontColor.pink);
    var iconFavoryColor = (_isFavorite ? Movizz.check : Movizz.plus);

    return Row(
      key: _bottomInfosKey,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        CustomSmallButton(
          text: allTranslations.text("movie_button_view") + " ",
          backgroundColor: Theme.of(context).primaryColor,
          fontColor: FontColor.white,
          borderColor: Theme.of(context).primaryColor,
          onPressed: () {
            return Navigator.pushNamed(context, "/movie",
                arguments: {"movieId": widget.movieId});
          },
        ),
        Padding(
          padding: EdgeInsets.only(right: 3),
        ),
        CustomSmallButton(
          text: allTranslations.text("movie_button_favorite") + " ",
          backgroundColor: bgFavoryColor,
          fontColor: fontFavoryColor,
          borderColor: Theme.of(context).primaryColor,
          icon: iconFavoryColor,
          onPressed: clickOnFavoriteButton,
        ),
        Padding(
          padding: EdgeInsets.only(right: 5),
        ),
        CustomText(
          text: widget.movieScore.toString() + "/10",
          fontColor: FontColor.darkGrey,
          fontSize: FontSize.sm,
          fontWeight: FontWeight.bold,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: Colors.white,
      width: widget.widthScreen,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          moviePoster(),
          movieInfos(),
        ],
      ),
    );
  }
}
