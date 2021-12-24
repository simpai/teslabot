import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

abstract class AppModel extends ChangeNotifier {
  void signIn({String? photoUrl, String? displayName});
  void signOut();

  String? displayName;
  String? photoURL;
  bool debugMode = false;
  bool signedIn = false;
}

class AppModelImplementation extends AppModel {
  AppModelImplementation() {
    debugMode =
        const String.fromEnvironment('DEBUG_MODE', defaultValue: '0') != '0';
  }

  @override
  void signIn({String? photoUrl, String? displayName}) {
    photoUrl = photoUrl;
    displayName = displayName;
    signedIn = true;
    notifyListeners();
  }

  @override
  void signOut() {
    signedIn = false;
    notifyListeners();
  }
}

var appModel = GetIt.I<AppModel>();
