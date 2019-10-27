import 'package:Movizz/Request.dart';
import 'package:Movizz/custom_widget/CustomAppBar.dart';
import 'package:Movizz/custom_widget/CustomTop.dart';
import 'package:Movizz/custom_widget/MoviePreview.dart';
import 'package:Movizz/custom_widget/UpdatableScrollView.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'all_translations.dart';
import 'custom_librairies/Common.dart';
import 'custom_widget/CustomBottomBar.dart';
import 'custom_widget/CustomText.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  double _screenWidth;
  double _screenHeight;

  List<Widget> trendsListMovies = [];
  List<Widget> discoverListMovies = [];
  String listChoice = "trends";
  var _sliderHome;

  ScrollController _trendsController = new ScrollController();
  bool isLoadingTrends = false;

  ScrollController _discoverController = new ScrollController();
  bool isLoadingDiscover = false;

  Map<String, int> _pageCounter = {"trends": 1, "discover": 1};

  final double topBarHeightPercent = 0.06;

  Future<void> getTrends(newList) async {
    if (!isLoadingTrends) {
      isLoadingTrends = true;

      Post response = await fetchPost(RequestType.get, "/trending/movie/day",
          {"page": _pageCounter["trends"].toString()});

      if (response.status == 200) {
        List<Widget> listMovies = generateListMoviesFromBody(response.body);

        _pageCounter["trends"]++;

        if (!mounted) return false;
        setState(() {
          if (newList)
            trendsListMovies = listMovies;
          else
            trendsListMovies = new List.from(trendsListMovies)
              ..addAll(listMovies);
        });
      }

      isLoadingTrends = false;
    }
  }

  Future<void> getDiscover(newList) async {
    if (!isLoadingDiscover) {
      isLoadingDiscover = true;

      Post response = await fetchPost(RequestType.get, "/discover/movie", {
        "sort_by": "popularity.desc",
        "page": _pageCounter["discover"].toString()
      });

      if (response.status == 200) {
        List<Widget> listMovies = generateListMoviesFromBody(response.body);

        _pageCounter["discover"]++;

        if (!mounted) return false;
        setState(() {
          if (newList)
            discoverListMovies = listMovies;
          else
            discoverListMovies = new List.from(discoverListMovies)
              ..addAll(listMovies);
        });
      }

      isLoadingDiscover = false;
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

  Widget constructTopBar(heightScreen, widthScreen) {
    double topBarHeight = heightScreen * topBarHeightPercent;

    return new CustomTopbar(
      context: context,
      widthScreen: widthScreen,
      heightScreen: heightScreen,
      appBarHeight: topBarHeightPercent,
      topBarChild: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          new GestureDetector(
            onTap: () {
              if (listChoice != "trends") {
                _sliderHome.previousPage(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.linear,
                );
                setState(() {
                  listChoice = "trends";
                });
              }
            },
            child: new Container(
              alignment: Alignment.center,
              color: Colors.white,
              width: widthScreen / 2,
              padding: EdgeInsets.only(left: widthScreen / 8),
              height: topBarHeight,
              child: new CustomText(
                text: allTranslations.text("title_home_trends"),
                fontColor: (listChoice == "trends"
                    ? FontColor.pink
                    : FontColor.lightGrey),
                fontSize: FontSize.md,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          new GestureDetector(
            onTap: () {
              if (listChoice != "discover") {
                _sliderHome.nextPage(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.linear,
                );
                setState(() {
                  listChoice = "discover";
                });
              }
            },
            child: new Container(
              color: Colors.white,
              width: widthScreen / 2,
              height: topBarHeight,
              padding: EdgeInsets.only(right: widthScreen / 8),
              alignment: Alignment.center,
              child: new CustomText(
                text: allTranslations.text("title_home_discover"),
                fontColor: (listChoice == "discover"
                    ? FontColor.pink
                    : FontColor.lightGrey),
                fontSize: FontSize.md,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSlider(height) {
    return CarouselSlider(
      height: height,
      viewportFraction: 1.0,
      enableInfiniteScroll: false,
      autoPlay: false,
      scrollPhysics: ClampingScrollPhysics(),
      onPageChanged: (page) {
        setState(() {
          if (page == 0)
            listChoice = "trends";
          else
            listChoice = "discover";
        });
      },
      items: [
        UpdatableScrollView(
          listWidget: trendsListMovies,
          scrollingController: _trendsController,
          updateMethod: () async {
            refresh("trends");
          },
        ),
        UpdatableScrollView(
          listWidget: discoverListMovies,
          scrollingController: _discoverController,
          updateMethod: () async {
            await refresh("discover");
          },
        ),
      ],
    );
  }

  Future refresh(listToRefresh) async {
    _pageCounter[listToRefresh] = 1;
    if (listToRefresh == "trends") await getTrends(true);
    if (listToRefresh == "discover") await getDiscover(true);
  }

  void initState() {
    super.initState();

    getTrends(true);
    getDiscover(true);

    _trendsController.addListener(() async {
      if (_trendsController.offset >=
          _trendsController.position.maxScrollExtent * 0.7) {
        await getTrends(false);
      }
    });

    _discoverController.addListener(() async {
      if (_discoverController.offset >=
          _discoverController.position.maxScrollExtent * 0.7) {
        await getDiscover(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;

    _sliderHome = buildSlider(_screenHeight);

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
        Padding(
          padding: EdgeInsets.only(top: _screenHeight * topBarHeightPercent),
          child: _sliderHome,
        ),
      ]),
    );
  }
}
