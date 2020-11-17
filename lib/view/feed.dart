import 'dart:io';

import 'package:among_us_profile_maker/analytics.dart';
import 'package:among_us_profile_maker/view/maker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:paginate_firestore/bloc/pagination_listeners.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class FeedView extends StatefulWidget {
  FeedView({key}) : super(key: key);
  @override
  _FeedViewState createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  PaginateRefreshedChangeListener refreshChangeListener =
      PaginateRefreshedChangeListener();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      // appBar: AppBar(
      //   title: Text(Translations.of(context).trans('avatars_from_users')),
      //   backgroundColor: Colors.black87,
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.star_rate),
      //       onPressed: () {
      //         StoreRedirect.redirect();
      //         analytics.logEvent(name: 'store_redirect');
      //       },
      //     )
      //   ],
      // ),
      body: RefreshIndicator(
        onRefresh: () async {
          refreshChangeListener.refreshed = true;
          showInterstitialAd();
        },
        child: PaginateFirestore(
          itemBuilderType:
              PaginateBuilderType.listView, //Change types accordingly
          itemBuilder: (index, context, documentSnapshot) {
            Map<String, dynamic> item = documentSnapshot.data();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      CachedNetworkImage(
                        width: MediaQuery.of(context).size.height / 4,
                        height: MediaQuery.of(context).size.height / 4,
                        imageUrl: item['url'],
                      ),
                      if (item['body'] != null) SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.topLeft,
                        child: Text(
                          item['body'] ?? '',
                          overflow: TextOverflow.visible,
                        ),
                      ),
                      ButtonBar(
                        children: [
                          FlatButton.icon(
                            icon: Icon(Icons.share),
                            label: Text("SHRE"),
                            onPressed: () async {
                              try {
                                File file = await urlToFile(item['url']);
                                await Share.file(
                                        'avatar',
                                        '${DateTime.now()}.png',
                                        file
                                            .readAsBytesSync()
                                            .buffer
                                            .asUint8List(),
                                        'image/png',
                                        text: 'https://auam.page.link/run')
                                    .then((value) {
                                  analytics.logEvent(name: 'share_from_feed');
                                  showInterstitialAd();
                                });
                              } catch (e) {
                                print('error: $e');
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            );
          },
          query: FirebaseFirestore.instance
              .collection('feed')
              .where('timestamp', isLessThan: DateTime.now())
              .orderBy(
                'timestamp',
                descending: true,
              ),
          itemsPerPage: 15,
          listeners: [
            refreshChangeListener,
          ],
          onLoaded: (value) {
            showInterstitialAd();
          },
        ),
      ),
    );
  }
}
