// ignore_for_file: prefer_const_constructors, deprecated_member_use
import 'package:carlink/firebase_options.dart';
import 'package:carlink/helpar/get_di.dart' as di;
import 'package:carlink/screen/gerneral_support/Applanguage_screen.dart';
import 'package:carlink/screen/login_flow/splash_screen.dart';
import 'package:carlink/utils/Dark_lightmode.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Localmodal_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    Stripe.publishableKey =
        'pk_live_51Q2dMKRtNMZxgBHAi2Zm4FnU0fqBjOd7oN1btg7JoNDr1E49LOr8p4TylBYJWuBpIAe7G9s1in1c4RqXI1N4yG9I0094fwG6td';
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    print("error initializing firebase");
  }

  FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  await di.init();
  await GetStorage.init();
  await dotenv.load(fileName: "assets/.env");

  if (DefaultFirebaseOptions.currentPlatform == TargetPlatform.iOS ||
      DefaultFirebaseOptions.currentPlatform == TargetPlatform.android) {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize("97b95d2a-f3ec-4578-850d-855fdc62df25");
    OneSignal.Notifications.requestPermission(true);
  }
  final prefs = await SharedPreferences.getInstance();
//hello azure
  runApp(MyApp(
    prefs: prefs,
  ));
}

class MyApp extends StatelessWidget {
  final SharedPreferences _prefs;
  const MyApp({super.key, required SharedPreferences prefs}) : _prefs = prefs;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ColorNotifire()),
        ChangeNotifierProvider(create: (context) => LocaleModel(_prefs)),
      ],
      child: Consumer<LocaleModel>(
        builder: (context, localeModel, child) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            translations: LocalString(),
            locale: localeModel.locale,
            theme: ThemeData(
              useMaterial3: false,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              dividerColor: Colors.transparent,
              fontFamily: "urbani_regular",
              primaryColor: const Color(0xff1347FF),
              colorScheme: ColorScheme.fromSwatch().copyWith(
                primary: const Color(0xff194BFB),
              ),
            ),
            home: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
                child: const SplashScreen()),
          );
        },
      ),
    );
  }
}
