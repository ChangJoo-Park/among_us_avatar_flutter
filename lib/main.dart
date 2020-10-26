import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Among Us Avatar Maker',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  final _formKey = GlobalKey<FormState>();
  GlobalKey _globalKey = new GlobalKey();
  int randomTapCount = 0;
  PageController controller = PageController(viewportFraction: 0.8);
  final gridDelegate = const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 5,
    crossAxisSpacing: 5.0,
    mainAxisSpacing: 5.0,
  );
  final gridPadding = const EdgeInsets.all(4);
  List<Image> _backgrounds = [];
  List<Image> _players = [];
  List<Image> _outfits = [];
  List<Image> _hats = [];
  List<Image> _pets = [];
  List<Image> _votes = [];
  bool _load = false;
  Image _background;
  Image _player;
  Image _outfit;
  Image _hat;
  Image _pet;
  Image _vote;
  String shareMessage = '';
  @override
  void initState() {
    _initImages().then((value) {
      setState(() {
        _load = true;
      });
    });
    super.initState();
  }

  Future _initImages() async {
    String manifestContent =
        await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    Map<String, dynamic> manifestMap = await json.decode(manifestContent);

    List<Image> _bg = manifestMap.keys
        .where((String key) => key.contains('images/BG/'))
        .map((String path) => Image.asset(path))
        .toList();
    List<Image> _pl = manifestMap.keys
        .where((String key) => key.contains('images/PLAYER/'))
        .map((String path) => Image.asset(path))
        .toList();
    List<Image> _of = manifestMap.keys
        .where((String key) => key.contains('images/OUTFITS/'))
        .map((String path) => Image.asset(path))
        .toList();
    List<Image> _pt = manifestMap.keys
        .where((String key) => key.contains('images/PETS/'))
        .map((String path) => Image.asset(path))
        .toList();
    List<Image> _ht = manifestMap.keys
        .where((String key) => key.contains('images/HATS/'))
        .map((String path) => Image.asset(path))
        .toList();
    List<Image> _vt = manifestMap.keys
        .where((String key) => key.contains('images/VOTE/'))
        .map((String path) => Image.asset(path))
        .toList();

    setState(() {
      _backgrounds = _bg;
      _players = _pl;
      _outfits = _of;
      _pets = _pt;
      _hats = _ht;
      _votes = _vt;
      _player = _players.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Amoung Us Avatar'),
        backgroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: Icon(Icons.casino),
            onPressed: () {
              setState(() {
                final _random = Random();
                int min = 0;
                _background =
                    _backgrounds[_random.nextInt(_backgrounds.length - min)];
                _player = _players[_random.nextInt(_players.length - min)];
                _outfit = _outfits[_random.nextInt(_outfits.length - min)];
                _hat = _hats[_random.nextInt(_hats.length - min)];
                _pet = _pets[_random.nextInt(_pets.length - min)];
                _vote = _votes[_random.nextInt(_votes.length - min)];
                randomTapCount++;
              });
              if (randomTapCount % 5 == 0) {
                print('광고 나와야지');
              }
            },
          ),
          IconButton(
              icon: Icon(Icons.camera_alt_outlined),
              onPressed: () async {
                try {
                  RenderRepaintBoundary boundary =
                      _globalKey.currentContext.findRenderObject();
                  ui.Image image = await boundary.toImage();
                  ByteData byteData =
                      await image.toByteData(format: ui.ImageByteFormat.png);
                  showDialog(
                    context: context,
                    child: AlertDialog(
                      content: Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.memory(byteData.buffer.asUint8List()),
                            Form(
                              key: _formKey,
                              child: TextFormField(
                                initialValue: 'This is my avatar!',
                                onSaved: (value) {
                                  setState(() {
                                    shareMessage = value;
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                      actions: [
                        FlatButton.icon(
                          icon: Icon(Icons.save),
                          label: Text('Save'),
                          onPressed: () async {
                            try {
                              if (await Permission.storage
                                  .request()
                                  .isGranted) {
                                await ImageGallerySaver.saveImage(
                                  byteData.buffer.asUint8List(),
                                  quality: 100,
                                );
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        const Text('Save avatar successfully'),
                                  ),
                                );
                              }
                            } catch (e) {
                              print('error: $e');
                            }
                          },
                        ),
                        FlatButton.icon(
                          icon: Icon(Icons.share),
                          label: Text('Share'),
                          onPressed: () async {
                            try {
                              _formKey.currentState.save();
                              await Share.file(
                                  'avatar',
                                  '${DateTime.now()}.png',
                                  byteData.buffer.asUint8List(),
                                  'image/png',
                                  text:
                                      '$shareMessage\nhttps://bit.ly/3omY7hn');

                              Navigator.of(context).pop();
                            } catch (e) {
                              print('error: $e');
                            }
                          },
                        ),
                        FlatButton(
                            child: Text('Close'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            }),
                      ],
                    ),
                  );
                } catch (e) {
                  print(e);
                }
              }),
        ],
      ),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: RepaintBoundary(
                  key: _globalKey,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(children: [
                      if (!_load) Center(child: CircularProgressIndicator()),
                      if (_background != null)
                        Container(child: _background, key: UniqueKey()),
                      if (_player != null)
                        Container(child: _player, key: UniqueKey()),
                      if (_outfit != null)
                        Container(child: _outfit, key: UniqueKey()),
                      if (_hat != null)
                        Container(child: _hat, key: UniqueKey()),
                      if (_pet != null)
                        Container(child: _pet, key: UniqueKey()),
                      if (_vote != null)
                        Container(child: _vote, key: UniqueKey()),
                    ]),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding: gridPadding,
                  child: PageView(
                    controller: controller,
                    children: [
                      Container(
                        child: GridView.builder(
                          gridDelegate: gridDelegate,
                          itemCount: _backgrounds.length,
                          itemBuilder: (BuildContext context, int index) {
                            Image image = _backgrounds[index];
                            return GestureDetector(
                              onTap: () => setState(() => _background = image),
                              child: image,
                            );
                          },
                        ),
                      ),
                      Container(
                        child: GridView.builder(
                          gridDelegate: gridDelegate,
                          itemCount: _players.length,
                          itemBuilder: (BuildContext context, int index) {
                            Image image = _players[index];
                            return GestureDetector(
                              onTap: () => setState(() => _player = image),
                              child: image,
                            );
                          },
                        ),
                      ),
                      Container(
                        child: GridView.builder(
                          gridDelegate: gridDelegate,
                          itemCount: _outfits.length,
                          itemBuilder: (BuildContext context, int index) {
                            Image image = _outfits[index];
                            return GestureDetector(
                              onTap: () => setState(() => _outfit = image),
                              child: image,
                            );
                          },
                        ),
                      ),
                      Container(
                        child: GridView.builder(
                          gridDelegate: gridDelegate,
                          itemCount: _hats.length,
                          itemBuilder: (BuildContext context, int index) {
                            Image image = _hats[index];
                            return GestureDetector(
                              onTap: () => setState(() => _hat = image),
                              child: image,
                            );
                          },
                        ),
                      ),
                      Container(
                        child: GridView.builder(
                          gridDelegate: gridDelegate,
                          itemCount: _pets.length,
                          itemBuilder: (BuildContext context, int index) {
                            Image image = _pets[index];
                            return GestureDetector(
                              onTap: () => setState(() => _pet = image),
                              child: image,
                            );
                          },
                        ),
                      ),
                      Container(
                        child: GridView.builder(
                          gridDelegate: gridDelegate,
                          itemCount: _votes.length,
                          itemBuilder: (BuildContext context, int index) {
                            Image image = _votes[index];
                            return GestureDetector(
                              onTap: () => setState(() => _vote = image),
                              child: image,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 인디케이터
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: SmoothPageIndicator(
                  controller: controller,
                  count: 6,
                  effect: ExpandingDotsEffect(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
