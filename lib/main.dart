import 'dart:convert';

import 'package:Movizz/FavoriesPage.dart';
import 'package:Movizz/HomePage.dart';
import 'package:Movizz/IntroductionPage.dart';
import 'package:Movizz/MoviePage.dart';
import 'package:Movizz/SearchPage.dart';
import 'package:Movizz/SettingsPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:load/load.dart';
import 'package:loading/indicator/line_scale_indicator.dart';
import 'package:loading/loading.dart';
import 'package:page_transition/page_transition.dart';
import 'all_translations.dart';
import 'custom_librairies/Ads.dart';

//flutter create --org com.yourdomain appname

void main() async {
  //correction new Flutter version
  WidgetsFlutterBinding.ensureInitialized();
  
  //init admob ads
  await initAppAds();
  // Initializes the translation module
  await allTranslations.init();

  // then start the application
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(
      LoadingProvider(
        loadingWidgetBuilder: (ctx, data) {
          return Center(
            child: Loading(indicator: LineScaleIndicator(), size: 70.0),
          );
        },
        child: MyApp(),
      ),
    );
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // Initializes a callback should something need
    // to be done when the language is changed
    allTranslations.onLocaleChangedCallback = _onLocaleChanged;
  }

  ///
  /// If there is anything special to do when the user changes the language
  ///
  _onLocaleChanged() async {
    // do anything you need to do if the language changes
    print('Language has been changed to: ${allTranslations.currentLanguage}');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movizz',
      //pour enlever le bandeau "debug"
      debugShowCheckedModeBanner: false,
      //je définis les couleurs et la police de mon application
      theme: ThemeData(fontFamily: 'Roboto', primaryColor: Color(0xFFff1493)),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: allTranslations.supportedLocales(),
      //je définis la route à appeler à l'ouverture
      initialRoute: '/',
      //je liste l'ensemble des routes de mon application
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return PageTransition(
                child: IntroductionPage(), type: PageTransitionType.fade);
            break;
          case '/home':
            return PageTransition(
                child: HomePage(), type: PageTransitionType.fade);
            break;
          case '/favories':
            return PageTransition(
                child: FavoriesPage(), type: PageTransitionType.fade);
            break;
          case '/search':
            return PageTransition(
                child: SearchPage(), type: PageTransitionType.fade);
            break;
          case '/settings':
            return PageTransition(
                child: SettingsPage(), type: PageTransitionType.fade);
            break;
          case '/movie':
            return PageTransition(
                child: MoviePage(
                  movieId: getParameters(settings.arguments, 'movieId'),
                ),
                type: PageTransitionType.fade);
            break;
          default:
            return null;
        }
      },
    );
  }
}

dynamic getParameters(Object arguments, String name) {
  return json.decode(JsonEncoder().convert(arguments))[name];
}
