import 'package:Movizz/custom_widget/CustomAppBar.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'all_translations.dart';
import 'custom_librairies/Common.dart';
import 'custom_widget/CustomBottomBar.dart';
import 'custom_widget/CustomText.dart';
import 'custom_widget/CustomTop.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final double topBarHeightPercent = 0.06;

  bool _isOpenedItem = false;
  Widget _openItem;
  String _openItemLabel;
  PackageInfo packageInfo;

  Widget buildListItems(heightScreen, widthScreen) {
    return Column(
      children: [
        buildStandardItem(heightScreen, widthScreen,
            allTranslations.text("settings_languages"), "languages"),
        buildSeparator(widthScreen),
        buildStandardItem(heightScreen, widthScreen,
            allTranslations.text("settings_contact"), "contact"),
        buildSeparator(widthScreen),
        buildStandardItem(heightScreen, widthScreen,
            allTranslations.text("settings_about"), "about"),
      ],
    );
  }

  Widget buildStandardItem(
      heightScreen, widthScreen, String text, String label) {
    return GestureDetector(
      child: Container(
        width: widthScreen,
        color: Colors.white,
        padding: EdgeInsets.all(widthScreen * 0.05),
        child: CustomText(
          text: text,
          fontColor: FontColor.darkGrey,
          fontSize: FontSize.md,
        ),
      ),
      onTap: () {
        setOpenWidget(widthScreen, label);
      },
    );
  }

  void openEmailManager() {
    showAlertDialog(allTranslations.text("settings_dialog_email"), context,
        () async {
      const url = "mailto:madproject.corp@gmail.com";
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    });
  }

  setOpenWidget(widthScreen, String label) async {
    List<Map<String, dynamic>> aboutList = [
      {"label": allTranslations.text("settings_about_version"), "text": ""}
    ];

    List<Map<String, dynamic>> contactList = [
      {
        "label": allTranslations.text("settings_contact_email"),
        "text": "madproject.corp@gmail.com",
        "onPressed": openEmailManager
      },
      {
        "label": allTranslations.text("settings_contact_developper"),
        "text": "Alexandre Dutrès"
      },
      {
        "label": allTranslations.text("settings_contact_designer"),
        "text": "Maxime Dutrès"
      }
    ];

    switch (label) {
      case "languages":
        setState(() {
          _openItemLabel = allTranslations.text("settings_languages");
          _openItem = buildLanguagesBody(widthScreen);
          _isOpenedItem = true;
        });
        break;
      case "contact":
        setState(() {
          _openItemLabel = "Contact";
          _openItem = buildListBody(widthScreen, contactList);
          _isOpenedItem = true;
        });
        break;
      case "about":
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        aboutList[0]["text"] = packageInfo.version;
        setState(() {
          _openItemLabel = "A propos";
          _openItem = buildListBody(widthScreen, aboutList);
          _isOpenedItem = true;
        });
        break;
    }
  }

  Widget buildLanguagesBody(widthScreen) {
    List<Widget> listLanguagesWidget = [];
    List<Locale> supportedLanguages =
        allTranslations.supportedLocales().toList();
    dynamic currentLanguage = allTranslations.currentLanguage;

    bool isCurrentLang;
    String cleanSupported;

    List<String> listLanguagesString = [];

    for (var i = 0; i < supportedLanguages.length; i++) {
      cleanSupported = supportedLanguages[i].toString().replaceAll("_", "");
      listLanguagesString.add(cleanSupported);
    }

    for (var i = 0; i < listLanguagesString.length; i++) {
      isCurrentLang = (listLanguagesString[i] == currentLanguage);

      listLanguagesWidget.add(
        GestureDetector(
          child: Container(
            color: Colors.white,
            width: widthScreen,
            padding: EdgeInsets.all(widthScreen * 0.05),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.keyboard_arrow_right,
                  size: CustomText.textSize(FontSize.md),
                  color: isCurrentLang
                      ? CustomText.textColor(FontColor.blue)
                      : Colors.transparent,
                ),
                Padding(
                  padding: EdgeInsets.only(right: widthScreen * 0.01),
                ),
                CustomText(
                  text: allTranslations.text("lang_" + listLanguagesString[i]),
                  fontColor:
                      isCurrentLang ? FontColor.blue : FontColor.darkGrey,
                  fontSize: FontSize.md,
                ),
              ],
            ),
          ),
          onTap: () async {
            await allTranslations.setNewLanguage(listLanguagesString[i], true);
            setOpenWidget(widthScreen, "languages");
          },
        ),
      );

      listLanguagesWidget.add(
        buildSeparator(widthScreen),
      );
    }

    return Column(
      children: listLanguagesWidget,
    );
  }

  Widget buildListBody(widthScreen, List<Map<String, dynamic>> listBody) {
    List<Widget> listContactWidget = [];

    for (var i = 0; i < listBody.length; i++) {
      listContactWidget.add(
        GestureDetector(
          child: Container(
            color: Colors.white,
            width: widthScreen,
            padding: EdgeInsets.all(widthScreen * 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                CustomText(
                  text: listBody[i]["label"],
                  fontColor: FontColor.darkGrey,
                  fontSize: FontSize.md,
                ),
                Padding(
                  padding: EdgeInsets.only(right: widthScreen * 0.02),
                ),
                CustomText(
                  text: listBody[i]["text"],
                  fontColor: FontColor.darkGrey,
                  fontSize: FontSize.md,
                ),
              ],
            ),
          ),
          onTap: () {
            if (listBody[i]["onPressed"] != null) {
              listBody[i]["onPressed"]();
            }
          },
        ),
      );
    }

    return Column(
      children: listContactWidget,
    );
  }

  Widget constructTopBar(heightScreen, widthScreen) {
    Widget barChild;

    if (_isOpenedItem) {
      barChild = Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_back),
            iconSize: CustomText.textSize(FontSize.lg),
            color: Colors.grey[500],
            onPressed: () {
              setState(() {
                _isOpenedItem = false;
              });
            },
          ),
          CustomText(
            text: _openItemLabel,
            fontColor: FontColor.pink,
            fontSize: FontSize.md,
            fontWeight: FontWeight.bold,
          ),
        ],
      );
    } else {
      barChild = CustomText(
        text: allTranslations.text("title_settings"),
        fontColor: FontColor.pink,
        fontSize: FontSize.md,
        fontWeight: FontWeight.bold,
      );
    }

    return new CustomTopbar(
      context: context,
      widthScreen: widthScreen,
      heightScreen: heightScreen,
      appBarHeight: topBarHeightPercent,
      topBarChild: barChild,
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
  }

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    double _screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
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
          margin: EdgeInsets.only(top: _screenHeight * topBarHeightPercent),
          child: SingleChildScrollView(
            physics: new ClampingScrollPhysics(),
            child: (_isOpenedItem
                ? _openItem
                : buildListItems(_screenHeight, _screenWidth)),
          ),
        ),
      ]),
    );
  }
}
