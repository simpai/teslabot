import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:teslabot/app_model.dart';

class WorldModel extends StatefulWidget {
  const WorldModel({Key? key}) : super(key: key);

  @override
  _WorldModelState createState() => _WorldModelState();
}

class _WorldModelState extends State<WorldModel> {
  int numUsers = 0;
  late DatabaseReference _usersRef;

  late StreamSubscription<DatabaseEvent> _userAddedSubscription;
  late StreamSubscription<DatabaseEvent> _userRemovedSubscription;
  late StreamSubscription<DatabaseEvent> _userChangedSubscription;
  late StreamSubscription<DatabaseEvent> _userMovedSubscription;
  late StreamSubscription<DatabaseEvent> _userValueSubscription;

  FirebaseException? _error;
  bool initialized = false;

  @override
  void initState() {
    init();
    super.initState();
  }

  void onErrorHandler(Object o) {
    _error = o as FirebaseException;
    // print('Error: ${error.code} ${error.message}');
  }

  Future<void> init() async {
    final database = FirebaseDatabase.instance;
    database.setLoggingEnabled(false);

    _usersRef = database.ref('users');

    if (!kIsWeb) {
      database.setPersistenceEnabled(true);
      database.setPersistenceCacheSizeBytes(10000000);
    }

    if (!kIsWeb) {
      await _usersRef.keepSynced(true);
    }

    setState(() {
      initialized = true;
    });

    final usersQuery = _usersRef.limitToLast(50);

    _userAddedSubscription =
        usersQuery.onChildAdded.listen((DatabaseEvent event) {
      print('Child added: ${event.snapshot.value}');
    }, onError: onErrorHandler);

    _userRemovedSubscription =
        usersQuery.onChildRemoved.listen((DatabaseEvent event) {
      print('Child removed: ${event.snapshot.value}');
    }, onError: onErrorHandler);

    _userChangedSubscription =
        usersQuery.onChildChanged.listen((DatabaseEvent event) {
      print('Child changed: ${event.snapshot.key} ${event.snapshot.value}');
    }, onError: onErrorHandler);

    _userMovedSubscription =
        usersQuery.onChildMoved.listen((DatabaseEvent event) {
      print('Child moved: ${event.snapshot.value}');
    }, onError: onErrorHandler);

    _userValueSubscription = usersQuery.onValue.listen((DatabaseEvent event) {
      print('Child value: ${event.snapshot.key} ${event.snapshot.value}');
    }, onError: onErrorHandler);
  }

  @override
  void dispose() {
    super.dispose();
    _userAddedSubscription.cancel();
    _userRemovedSubscription.cancel();
    _userChangedSubscription.cancel();
    _userMovedSubscription.cancel();
    _userValueSubscription.cancel();
  }

  // Future<void> onSignIn(String action) async {
  //   await _usersRef.child('simpai').set(action);
  // }

  // Future<void> onSignOut() async {
  //   await _usersRef.child('simpai').set(action);
  // }

  // Future<void> _signOutUser(DataSnapshot snapshot) async {
  //   final usersRef = _usersRef.child(snapshot.key!);
  //   await messageRef.remove();
  // }

  Future<void> setAction(String path, String action) async {
    await _usersRef.child('$path/action').set(action);
  }

  Future<void> setMessage(String path, String msg) async {
    await _usersRef.child('$path/message').set(msg);
  }

  Future<void> move(int x, int y) async {}

  @override
  Widget build(BuildContext context) {
    if (!initialized) return Container();

    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              ElevatedButton(
                onPressed: () => move(-1, 0),
                child: const Icon(Icons.arrow_left),
              ),
              ElevatedButton(
                onPressed: () => move(0, 1),
                child: const Icon(Icons.arrow_upward),
              ),
              ElevatedButton(
                onPressed: () => move(0, -1),
                child: const Icon(Icons.arrow_downward),
              ),
              ElevatedButton(
                onPressed: () => move(1, 0),
                child: const Icon(Icons.arrow_right),
              ),
            ],
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => setAction('happy', 'idle'),
                child: const Text('happy/idle'),
              ),
              ElevatedButton(
                onPressed: () => setAction('happy', 'walk'),
                child: const Text('happy/walk'),
              ),
              ElevatedButton(
                onPressed: () => setAction('happy', 'sleep'),
                child: const Text('happy/sleep'),
              ),
            ],
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => setAction('simpai', 'idle'),
                child: const Text('simpai/idle'),
              ),
              ElevatedButton(
                onPressed: () => setAction('simpai', 'walk'),
                child: const Text('simpai/walk'),
              ),
              ElevatedButton(
                onPressed: () => setAction('simpai', 'sleep'),
                child: const Text('simpai/sleep'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
