import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:among_us_profile_maker/view/custom_layer_editor.dart';
import 'package:http/http.dart' as http;

import 'package:among_us_profile_maker/analytics.dart';
import 'package:among_us_profile_maker/view/custom_text_editor.dart';
import 'package:among_us_profile_maker/translations.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// ADMOB
const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    childDirected: true,
    nonPersonalizedAds: true,
    testDevices: <String>['516599cf-81f4-4d34-8579-f8bb846c21ef']);

int adActionCount = 0;
showInterstitialAd() {
  adActionCount++;
  if (adActionCount % 5 == 0) {
    createInterstitialAd()
      ..load()
      ..show();
  }
}

UserCredential userCredential;

InterstitialAd createInterstitialAd() {
  return InterstitialAd(
    adUnitId: 'ca-app-pub-7164614404138031/5433319182',
    targetingInfo: targetingInfo,
    listener: (MobileAdEvent event) {
      print("InterstitialAd event $event");
    },
  );
}

class MakerView extends StatefulWidget {
  MakerView({key, this.onFeedUploaded}) : super(key: key);
  final VoidCallback onFeedUploaded;
  @override
  _MakerViewState createState() => _MakerViewState();
}

class _MakerViewState extends State<MakerView>
    with AutomaticKeepAliveClientMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Player
  AudioCache audioCache = AudioCache();

  BannerAd _bannerAd;
  NativeAd _nativeAd;
  InterstitialAd _interstitialAd;

  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: 'ca-app-pub-7164614404138031/4635242833',
      size: AdSize.smartBanner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print(event);
      },
    );
  }

  final _formKey = GlobalKey<FormState>();
  GlobalKey _globalKey = new GlobalKey();
  int randomTapCount = 0;
  PageController controller = PageController(viewportFraction: 0.8);
  final gridDelegate = const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 5,
    crossAxisSpacing: 5.0,
    mainAxisSpacing: 5.0,
  );
  final gridPadding = const EdgeInsets.all(16);
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
      _selectRandomAvatar();
      setState(() {
        _load = true;
      });
    });
    FirebaseAdMob.instance
        .initialize(appId: 'ca-app-pub-7164614404138031~2200651188');
    _bannerAd = createBannerAd()..load();
    _bannerAd.show(
        anchorType: AnchorType.bottom,
        anchorOffset: _bannerAd.size.height.toDouble());
    super.initState();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _nativeAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  Future _initImages() async {
    String manifestContent =
        await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    Map<String, dynamic> manifestMap = await json.decode(manifestContent);

    List<Image> _bg = manifestMap.keys
        .where((String key) => key.contains('images/BG/'))
        .map((String path) => Image.asset(path))
        .toList();
    _bg.insert(0, null);
    List<Image> _pl = manifestMap.keys
        .where((String key) => key.contains('images/PLAYER/'))
        .map((String path) => Image.asset(path))
        .toList();
    List<Image> _of = manifestMap.keys
        .where((String key) => key.contains('images/OUTFITS/'))
        .map((String path) => Image.asset(path))
        .toList();
    _of.insert(0, null);
    List<Image> _pt = manifestMap.keys
        .where((String key) => key.contains('images/PETS/'))
        .map((String path) => Image.asset(path))
        .toList();
    _pt.insert(0, null);
    List<Image> _ht = manifestMap.keys
        .where((String key) => key.contains('images/HATS/'))
        .map((String path) => Image.asset(path))
        .toList();
    _ht.insert(0, null);
    List<Image> _vt = manifestMap.keys
        .where((String key) => key.contains('images/VOTE/'))
        .map((String path) => Image.asset(path))
        .toList();
    _vt.insert(0, null);

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

  _selectRandomAvatar({bool all = false}) async {
    setState(() {
      final _random = Random();
      int min = 0;
      _background = _backgrounds[_random.nextInt(_backgrounds.length - min)];
      _player = _players[_random.nextInt(_players.length - min)];
      if (all) {
        _outfit = _outfits[_random.nextInt(_outfits.length - min)];
        _hat = _hats[_random.nextInt(_hats.length - min)];
        _pet = _pets[_random.nextInt(_pets.length - min)];
        _vote = _votes[_random.nextInt(_votes.length - min)];
        randomTapCount++;
        try {
          audioCache.play('effect/select.mp3');
        } catch (e) {
          print(e);
        }
      }
    });
    if (kReleaseMode) {
      analytics.logEvent(
        name: 'random',
        parameters: <String, dynamic>{'count': randomTapCount},
      );
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      key: scaffoldKey,
      // appBar: AppBar(
      //   title: Text('Amoung Us Avatar'),
      //   backgroundColor: Colors.black87,
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.casino),
      //       onPressed: () {
      //         _selectRandomAvatar(all: true);
      //       },
      //     ),
      //     IconButton(
      //         icon: Icon(Icons.share),
      //         onPressed: () async {
      //           try {
      //             RenderRepaintBoundary boundary =
      //                 _globalKey.currentContext.findRenderObject();
      //             ui.Image image = await boundary.toImage();
      //             ByteData byteData =
      //                 await image.toByteData(format: ui.ImageByteFormat.png);
      //             showDialog(
      //               context: context,
      //               child: AlertDialog(
      //                 content: Container(
      //                   child: Column(
      //                     mainAxisSize: MainAxisSize.min,
      //                     children: [
      //                       Image.memory(byteData.buffer.asUint8List()),
      //                       Form(
      //                         key: _formKey,
      //                         child: TextFormField(
      //                           initialValue:
      //                               Translations.of(scaffoldKey.currentContext)
      //                                   .trans('default_dialog_text'),
      //                           onSaved: (value) {
      //                             setState(() {
      //                               shareMessage = value;
      //                             });
      //                           },
      //                         ),
      //                       )
      //                     ],
      //                   ),
      //                 ),
      //                 actions: [
      //                   FlatButton.icon(
      //                     icon: Icon(Icons.save),
      //                     label: Text(Translations.of(context).trans('save')),
      //                     onPressed: () async {
      //                       await save(byteData, context);
      //                     },
      //                   ),
      //                   FlatButton.icon(
      //                     icon: Icon(Icons.share),
      //                     label: Text(Translations.of(context).trans('share')),
      //                     onPressed: () async {
      //                       await _share(byteData, context);
      //                     },
      //                   ),
      //                   FlatButton.icon(
      //                     icon: Icon(Icons.cloud_circle),
      //                     label: Text(Translations.of(context).trans('feed')),
      //                     onPressed: () async {
      //                       await _feed(context, byteData);
      //                     },
      //                   ),
      //                 ],
      //               ),
      //             );
      //           } catch (e) {
      //             print(e);
      //           }
      //         }),
      //   ],
      // ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("images/among_us_hd.png"), fit: BoxFit.cover),
          ),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Expanded(
                flex: 0,
                child: RepaintBoundary(
                  key: _globalKey,
                  child: Container(
                    width: 250,
                    height: 250,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.white,
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
              // 인디케이터
              Container(
                padding: const EdgeInsets.only(top: 20),
                child: SmoothPageIndicator(
                  onDotClicked: (value) {
                    controller.animateToPage(value,
                        curve: Curves.easeIn,
                        duration: Duration(milliseconds: 100));
                  },
                  controller: controller,
                  count: 6,
                  effect: ExpandingDotsEffect(activeDotColor: Colors.white),
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
                        key: ValueKey('player-page'),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.builder(
                          gridDelegate: gridDelegate,
                          itemCount: _players.length,
                          itemBuilder: (BuildContext context, int index) {
                            Image image = _players[index];
                            return GestureDetector(
                              key: ValueKey('player-$index'),
                              onTap: () => setState(() => _player = image),
                              child: Container(
                                key: ValueKey('player-$index-image'),
                                color: Colors.white,
                                child: image,
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.builder(
                          gridDelegate: gridDelegate,
                          itemCount: _backgrounds.length + 1,
                          itemBuilder: (BuildContext context, int index) {
                            if (index == _backgrounds.length) {
                              return Stack(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    color: Colors.amber,
                                    child: Icon(Icons.add, color: Colors.black),
                                  ),
                                  Positioned.fill(
                                    child: InkWell(
                                      onTap: () {
                                        analytics.logEvent(
                                            name: 'start_editor');
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            fullscreenDialog: true,
                                            maintainState: true,
                                            builder: (context) =>
                                                CustomLayerEditor(
                                              title: 'Background Editor',
                                              type: 'BACKGROUND',
                                            ),
                                          ),
                                        ).then((value) {
                                          if (value != null) {
                                            analytics.logEvent(
                                                name: 'end_editor');
                                            setState(() {
                                              _backgrounds
                                                  .add(Image.memory(value));
                                              _background = Image.memory(value);
                                            });
                                          }
                                        });
                                      },
                                    ),
                                  )
                                ],
                              );
                            }
                            Widget image = _backgrounds[index];
                            return GestureDetector(
                              onTap: () => setState(() => _background = image),
                              child:
                                  Container(color: Colors.white, child: image),
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.builder(
                          gridDelegate: gridDelegate,
                          itemCount: _outfits.length + 1,
                          itemBuilder: (BuildContext context, int index) {
                            if (index == _outfits.length) {
                              return Stack(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    color: Colors.amber,
                                    child: Icon(Icons.add, color: Colors.black),
                                  ),
                                  Positioned.fill(
                                    child: InkWell(
                                      onTap: () {
                                        analytics.logEvent(
                                            name: 'start_editor');
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            fullscreenDialog: true,
                                            maintainState: true,
                                            builder: (context) =>
                                                CustomLayerEditor(
                                              title: 'Outfit Editor',
                                              type: 'OUTFIT',
                                            ),
                                          ),
                                        ).then((value) {
                                          if (value != null) {
                                            analytics.logEvent(
                                                name: 'end_editor');
                                            setState(() {
                                              _outfits.add(Image.memory(value));
                                              _outfit = Image.memory(value);
                                            });
                                          }
                                        });
                                      },
                                    ),
                                  )
                                ],
                              );
                            }
                            Widget image = _outfits[index];
                            return GestureDetector(
                              onTap: () => setState(() => _outfit = image),
                              child: Container(
                                color: Colors.white,
                                child: image,
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.builder(
                          gridDelegate: gridDelegate,
                          itemCount: _hats.length + 1,
                          itemBuilder: (BuildContext context, int index) {
                            if (index == _hats.length) {
                              return Stack(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    color: Colors.amber,
                                    child: Icon(Icons.add, color: Colors.black),
                                  ),
                                  Positioned.fill(
                                    child: InkWell(
                                      onTap: () {
                                        analytics.logEvent(
                                            name: 'start_editor');
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            fullscreenDialog: true,
                                            maintainState: true,
                                            builder: (context) =>
                                                CustomLayerEditor(
                                              title: 'Hat Editor',
                                              type: 'HAT',
                                            ),
                                          ),
                                        ).then((value) {
                                          if (value != null) {
                                            analytics.logEvent(
                                                name: 'end_editor');
                                            setState(() {
                                              _hats.add(Image.memory(value));
                                              _hat = Image.memory(value);
                                            });
                                          }
                                        });
                                      },
                                    ),
                                  )
                                ],
                              );
                            }

                            Widget image = _hats[index];
                            return GestureDetector(
                              onTap: () => setState(() => _hat = image),
                              child: Container(
                                color: Colors.white,
                                child: image,
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.builder(
                          gridDelegate: gridDelegate,
                          itemCount: _pets.length + 1,
                          itemBuilder: (BuildContext context, int index) {
                            if (index == _pets.length) {
                              return Stack(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    color: Colors.amber,
                                    child: Icon(Icons.add, color: Colors.black),
                                  ),
                                  Positioned.fill(
                                    child: InkWell(
                                      onTap: () {
                                        analytics.logEvent(
                                            name: 'start_editor');
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            fullscreenDialog: true,
                                            maintainState: true,
                                            builder: (context) =>
                                                CustomLayerEditor(
                                              title: 'Pet Editor',
                                              type: 'PET',
                                            ),
                                          ),
                                        ).then((value) {
                                          if (value != null) {
                                            analytics.logEvent(
                                                name: 'end_editor');
                                            setState(() {
                                              _pets.add(Image.memory(value));
                                              _pet = Image.memory(value);
                                            });
                                          }
                                        });
                                      },
                                    ),
                                  )
                                ],
                              );
                            }

                            Widget image = _pets[index];
                            return GestureDetector(
                              onTap: () => setState(() => _pet = image),
                              child: Container(
                                color: Colors.white,
                                child: image,
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.builder(
                          gridDelegate: gridDelegate,
                          itemCount: _votes.length + 1, // 마지막은 커스텀
                          itemBuilder: (BuildContext context, int index) {
                            if (index == _votes.length) {
                              return Stack(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    color: Colors.amber,
                                    child: Icon(Icons.add, color: Colors.black),
                                  ),
                                  Positioned.fill(
                                    child: InkWell(
                                      onTap: () {
                                        analytics.logEvent(
                                            name: 'start_editor');
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            fullscreenDialog: true,
                                            maintainState: true,
                                            builder: (context) =>
                                                CustomTextEditor(),
                                          ),
                                        ).then((value) {
                                          if (value != null) {
                                            analytics.logEvent(
                                                name: 'end_editor');
                                            setState(() {
                                              _votes.add(Image.memory(value));
                                              _vote = Image.memory(value);
                                            });
                                          }
                                        });
                                      },
                                    ),
                                  )
                                ],
                              );
                            }
                            Widget image = _votes[index];
                            return GestureDetector(
                              onTap: () => setState(() => _vote = image),
                              child: Container(
                                color: Colors.white,
                                child: image,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Future _feed(BuildContext context, ByteData byteData) async {
    scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text(Translations.of(context).trans('uploading'))));
    _formKey.currentState.save();
    Navigator.of(context).pop();
    UserCredential userCredential = await signIn();
    final fireStorage = FirebaseStorage.instance;
    String url = '${DateTime.now().millisecondsSinceEpoch.toString()}.jpg';
    StorageReference ref = fireStorage
        .ref()
        .child('feed')
        .child(userCredential.user.uid)
        .child(url);
    File file = await writeToFile(byteData);
    await ref.putFile(file).onComplete;
    String downloadURL = await ref.getDownloadURL();

    await FirebaseFirestore.instance.collection('feed').add({
      'url': downloadURL,
      'body': shareMessage,
      'uid': userCredential.user.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });
    widget.onFeedUploaded();
    analytics.logEvent(name: 'feed');
    try {
      scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(Translations.of(context).trans('upload_success'))));
    } catch (e) {}
    showInterstitialAd();
  }

  Future save(ByteData byteData, BuildContext context) async {
    try {
      if (await Permission.storage.request().isGranted) {
        await ImageGallerySaver.saveImage(
          byteData.buffer.asUint8List(),
          quality: 100,
        );
        Navigator.of(context).pop();
        try {
          Scaffold.of(context).showSnackBar(SnackBar(
              content: Text(Translations.of(context).trans('save_success'))));
        } catch (e) {}
        if (kReleaseMode) {
          analytics.logEvent(name: 'save');
        }
      }
      showInterstitialAd();
    } catch (e) {
      print('error: $e');
    }
  }

  Future _share(ByteData byteData, BuildContext context) async {
    try {
      _formKey.currentState.save();
      await Share.file('avatar', '${DateTime.now()}.png',
              byteData.buffer.asUint8List(), 'image/png',
              text: '$shareMessage\nhttps://auam.page.link/run')
          .then((value) {
        showInterstitialAd();
      });
      analytics.logEvent(name: 'share');

      Navigator.of(context).pop();
    } catch (e) {
      print('error: $e');
    }
  }
}

Future<File> writeToFile(ByteData data) async {
  final buffer = data.buffer;
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;
  var filePath =
      tempPath + '/file_01.tmp'; // file_01.tmp is dump file, can be anything
  return File(filePath)
      .writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
}

Future<File> urlToFile(String imageUrl) async {
  // generate random number.
  var rng = Random();
  // get temporary directory of device.
  Directory tempDir = await getTemporaryDirectory();
  // get temporary path from temporary directory.
  String tempPath = tempDir.path;
  // create a new file in temporary path with random file name.
  File file = new File('$tempPath' + (rng.nextInt(100)).toString() + '.png');
  // call http.get method and pass imageUrl into it to get response.
  http.Response response = await http.get(imageUrl);
  // write bodyBytes received in response to file.
  await file.writeAsBytes(response.bodyBytes);
  // now return the file which is created with random name in
  // temporary directory and image bytes from response is written to // that file.
  return file;
}

signIn() async {
  if (userCredential == null) {
    userCredential = await FirebaseAuth.instance.signInAnonymously();
  }
  return userCredential;
}
