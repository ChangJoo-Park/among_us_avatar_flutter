import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainController extends GetxController {
  TabController tabController =
      TabController(length: 2, vsync: NavigatorState());
  int _currentTabIndex = 0;
  Rx<UserCredential> userCredential;

  @override
  void onInit() {
    super.onInit();
  }
  // 여기부터 MakerView 에서 사용한다

  // 여기부터 FeedView 에서 사용한다
}
