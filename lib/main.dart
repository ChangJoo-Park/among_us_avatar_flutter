import 'package:among_us_profile_maker/translations.dart';
import 'package:among_us_profile_maker/translations_delegate.dart';
import 'package:among_us_profile_maker/view/feed.dart';
import 'package:among_us_profile_maker/view/maker.dart';
import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

FirebaseAnalytics analytics = FirebaseAnalytics();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        const TranslationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('de', ''),
        const Locale('es', ''),
        const Locale('fr', ''),
        const Locale('id', ''),
        const Locale('it', ''),
        const Locale('pt', ''),
        const Locale('ru', ''),
        const Locale('vi', ''),
      ],
      localeResolutionCallback:
          (Locale locale, Iterable<Locale> supportedLocales) {
        if (locale == null) {
          debugPrint("*language locale is null!!!");
          return supportedLocales.first;
        }

        for (Locale supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode ||
              supportedLocale.countryCode == locale.countryCode) {
            debugPrint("*language ok $supportedLocale");
            return supportedLocale;
          }
        }

        debugPrint("*language to fallback ${supportedLocales.first}");
        return supportedLocales.first;
      },
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      title: 'Among Us Avatar Maker',
      theme: ThemeData.from(
        colorScheme: const ColorScheme.light(),
      ).copyWith(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
          },
        ),
      ),
      home: DoubleBack(
        onFirstBackPress: (context) {
          Flushbar(
            flushbarPosition: FlushbarPosition.TOP,
            title: Translations.of(context).trans('close_back_title'),
            message: Translations.of(context).trans('close_back_message'),
            duration: Duration(seconds: 15), // show 15 second flushbar
          )..show(context);
        },
        child: MyHomePage(title: 'Flutter Demo Home Page'),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PageController pageController = PageController();
  List<Widget> _page = [];
  @override
  void initState() {
    _page = [
      MakerView(
        key: UniqueKey(),
        onFeedUploaded: () {
          pageController.jumpToPage(1);
        },
      ),
      FeedView(key: UniqueKey())
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: PageView.builder(
        pageSnapping: true,
        key: ValueKey('PAGEVIEW'),
        controller: pageController,
        itemCount: 2,
        itemBuilder: (BuildContext context, int index) {
          return _page[index];
        },
      ),
    );
  }
}
