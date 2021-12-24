import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:teslabot/app_model.dart';
import 'package:teslabot/tiled_map/game_tiled_map.dart';
import 'package:teslabot/world_model.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      appModel.signOut();
    } else {
      List<UserInfo> providerData = user.providerData;
      if (providerData.isNotEmpty) {
        if (providerData[0].providerId == 'twitter.com') {
          appModel.signIn(
              photoUrl: providerData[0].photoURL,
              displayName: providerData[0].displayName);
        }
      } else {
        appModel.signIn();
      }
    }
  });

  FirebaseDatabase database = FirebaseDatabase.instance;

  if (!kIsWeb) {
    await Flame.device.setLandscape();
    await Flame.device.fullScreen();
  }

  GetIt.I.registerSingleton<AppModel>(AppModelImplementation());

  runApp(
    const MaterialApp(
      home: TeslaWorldApp(),
    ),
  );
}

class TeslaWorldApp extends StatefulWidget {
  const TeslaWorldApp({Key? key}) : super(key: key);

  @override
  State<TeslaWorldApp> createState() => _TeslaWorldAppState();
}

class _TeslaWorldAppState extends State<TeslaWorldApp> {
  @override
  void initState() {
    super.initState();
    appModel.addListener(update);
  }

  @override
  void dispose() {
    super.dispose();
    appModel.removeListener(update);
  }

  void update() => setState(() => {});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Row(
            children: [
              if (appModel.signedIn) ...[
                (appModel.photoURL != null)
                    ? Image.network(appModel.photoURL!)
                    : const SizedBox(),
                TextButton(
                  child: const Text('Sign Out'),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                ),
              ] else ...[
                TextButton(
                  child: const Text('SignIn'),
                  onPressed: () async {
                    await FirebaseAuth.instance.signInAnonymously();
                  },
                ),
                TextButton(
                  child: const Text('SignIn Twit Popup'),
                  onPressed: () async {
                    await signInWithTwitter();
                  },
                ),
                TextButton(
                  child: const Text('SignIn Twit Redirect'),
                  onPressed: () async {
                    await signInWithTwitterRedirect();
                  },
                ),
              ]
            ],
          ),
        ),
        const Expanded(flex: 1, child: WorldModel()),
        const Expanded(flex: 5, child: GameTiledMap()),
      ],
    );
  }
}

Future<UserCredential> signInWithTwitter() async {
  // Create a new provider
  TwitterAuthProvider twitterProvider = TwitterAuthProvider();

  // Once signed in, return the UserCredential
  return await FirebaseAuth.instance.signInWithPopup(twitterProvider);
}

Future<void> signInWithTwitterRedirect() async {
  // Create a new provider
  TwitterAuthProvider twitterProvider = TwitterAuthProvider();

  // Or use signInWithRedirect
  await FirebaseAuth.instance.signInWithRedirect(twitterProvider);
}
