import 'package:Movizz/custom_librairies/Common.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future initAppAds() async {
  await FirebaseAdMob.instance.initialize(appId: getAppId());
}

Future launchInterstitialAds() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  int _lastAds = prefs.getInt("last_ads");
  bool showAds = true;

  int nowInSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  if (_lastAds != null) {
    if (nowInSeconds - _lastAds < 60) showAds = false;
  }

  if (showAds) {
    MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
      nonPersonalizedAds: true,
    );

    InterstitialAd myInterstitial = InterstitialAd(
      adUnitId: getInterstitialId(),
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        if (event == MobileAdEvent.opened) {
          prefs.setInt("last_ads", nowInSeconds);
        }
      },
    );

    await myInterstitial.load();
    await myInterstitial.show(
      anchorType: AnchorType.bottom,
      anchorOffset: 0.0,
      horizontalCenterOffset: 0.0,
    );
  }
}
