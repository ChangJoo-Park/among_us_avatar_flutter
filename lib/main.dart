import 'package:among_us_profile_maker/controller.dart';
import 'package:among_us_profile_maker/messages.dart';
import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:among_us_profile_maker/view/maker.dart';
import 'package:among_us_profile_maker/view/feed.dart';
import 'package:flushbar/flushbar.dart';

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
    return GetMaterialApp(
      translations: Messages(),
      locale: Locale('en', 'US'),
      fallbackLocale: Locale('en', 'UK'),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      title: 'Among Us Avatar Maker',
      theme: ThemeData.from(
        colorScheme: const ColorScheme.light(),
      ).copyWith(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(color: Colors.black87),
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
            title: 'close_back_title',
            message: 'close_back_message',
            duration: Duration(seconds: 15), // show 15 second flushbar
          )..show(context);
        },
        child: Home(),
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

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  List<String> _tabs = ['Maker', 'Feed'];
  TabController _tabController;
  List<IconButton> _actions = <IconButton>[];
  int _index = 0;
  @override
  void initState() {
    _actions = <IconButton>[
      IconButton(
        onPressed: () {},
        icon: Icon(Icons.casino),
      ),
      IconButton(
        onPressed: () {},
        icon: Icon(Icons.save),
      ),
    ];

    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        if (_tabController.indexIsChanging) {
          setState(() => _index = _tabController.index);
          switch (_tabController.index) {
            case 0: // Maker
              _actions = _makerActions();
              break;
            case 1: // Feed
              _actions = _feedActions();
              break;
            default:
          }

          setState(() {});
        }
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text('Drawer Header'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Item 1'),
              onTap: () {},
            ),
            ListTile(
              title: Text('Item 2'),
              onTap: () {},
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('Among Us Avatar'),
        bottom: TabBar(
          controller: _tabController,
          tabs: <Tab>[
            Tab(text: 'Maker'),
            Tab(text: 'Feed'),
          ],
        ),
        actions: _index == 0 ? _makerActions() : _feedActions(),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [MakerView(), FeedView()],
      ),
    );
  }

  List<IconButton> _feedActions() {
    return <IconButton>[
      IconButton(
        onPressed: () {},
        icon: Icon(Icons.star),
      ),
    ];
  }

  List<IconButton> _makerActions() {
    return <IconButton>[
      IconButton(
        onPressed: () {},
        icon: Icon(Icons.casino),
      ),
      IconButton(
        onPressed: () {},
        icon: Icon(Icons.save),
      ),
    ];
  }
}

class Home extends GetView<MainController> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: MainController(),
      builder: (MainController controller) {
        return StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
            if (snapshot.hasError) {
              return Container();
            }
            if (snapshot.connectionState == ConnectionState.active) {
              if (!snapshot.hasData) {
                return FutureBuilder(
                  future: FirebaseAuth.instance.signInAnonymously(),
                  builder: (BuildContext context,
                      AsyncSnapshot<UserCredential> snapshot) {
                    if (snapshot.hasData) {
                      print(snapshot.data);
                      controller.userCredential.value = userCredential;
                    }
                    return Scaffold(
                        body: Center(child: CircularProgressIndicator()));
                  },
                );
              }
              return Scaffold(
                appBar: AppBar(
                  key: ValueKey('APPBAR'),
                  title: Text('Among Us Avatar Maker'),
                  bottom: TabBar(
                    key: ValueKey('TABBAR'),
                    controller: controller.tabController,
                    tabs: [
                      Tab(
                        key: ValueKey('TAB_MAKER'),
                        text: 'Maker',
                      ),
                      Tab(
                        key: ValueKey('TAB_FEED'),
                        text: 'Feed',
                      )
                    ],
                  ),
                ),
                body: TabBarView(
                  key: ValueKey('TABBARVIEW'),
                  controller: controller.tabController,
                  children: [
                    MakerView(),
                    FeedView(),
                  ],
                ),
              );
            }
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          },
        );
      },
    );
  }
}
