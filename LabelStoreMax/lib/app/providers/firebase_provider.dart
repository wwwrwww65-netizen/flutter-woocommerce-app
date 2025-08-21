import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:wp_json_api/models/wp_user.dart';
import 'package:wp_json_api/wp_json_api.dart';
import '/bootstrap/app_helper.dart';
import '/firebase_options.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/woosignal.dart';

class FirebaseProvider implements NyProvider {
  @override
  boot(Nylo nylo) async {
    return null;
  }

  @override
  afterBoot(Nylo nylo) async {
    // Initialize Firebase (always)
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Initialize Analytics/Crashlytics/Remote Config
    try {
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    } catch (_) {}
    try {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    } catch (_) {}
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      await remoteConfig.fetchAndActivate();
    } catch (_) {}

    bool? firebaseFcmIsEnabled =
        AppHelper.instance.appConfig?.firebaseFcmIsEnabled;
    firebaseFcmIsEnabled ??= getEnv('FCM_ENABLED', defaultValue: false);

    if (firebaseFcmIsEnabled != true) return;

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      return;
    }

    WpUser? wpUser = await WPJsonAPI.wpUser();
    if (wpUser != null && wpUser.id != null) {
      WooSignal.instance.setWpUserId(wpUser.id.toString());
    }

    try {
      String? token = await messaging.getToken();
      if (token != null) {
        WooSignal.instance.setFcmToken(token);
      }
    } catch (e) {
      printError(e);
    }
  }
}
