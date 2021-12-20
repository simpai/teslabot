import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:teslabot/tiled_map/game_tiled_map.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  });

  FirebaseDatabase database = FirebaseDatabase.instance;

  if (!kIsWeb) {
    await Flame.device.setLandscape();
    await Flame.device.fullScreen();
  }
  runApp(
    const MaterialApp(
      home: AuthTest(),
    ),
  );
}

class AuthTest extends StatefulWidget {
  const AuthTest({Key? key}) : super(key: key);

  @override
  State<AuthTest> createState() => _AuthTestState();
}

class _AuthTestState extends State<AuthTest> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Row(
            children: [
              TextButton(
                child: const Text('signInAnonymously'),
                onPressed: () async {
                  await FirebaseAuth.instance.signInAnonymously();
                },
              ),
              TextButton(
                child: const Text('signInTwitter'),
                onPressed: () async {
                  await signInWithTwitter();
                },
              ),
            ],
          ),
        ),
        const Expanded(child: MyHomePage()),
        const Expanded(child: GameTiledMap()),
      ],
    );
  }
}

Future<UserCredential> signInWithTwitter() async {
  // Create a new provider
  TwitterAuthProvider twitterProvider = TwitterAuthProvider();

  // Once signed in, return the UserCredential
  return await FirebaseAuth.instance.signInWithPopup(twitterProvider);

  // Or use signInWithRedirect
  // return await FirebaseAuth.instance.signInWithRedirect(twitterProvider);
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  late DatabaseReference _counterRef;
  late DatabaseReference _messagesRef;
  late StreamSubscription<DatabaseEvent> _counterSubscription;
  late StreamSubscription<DatabaseEvent> _messagesSubscription;
  bool _anchorToBottom = false;

  final String _kTestKey = 'Hello';
  final String _kTestValue = 'world!';
  FirebaseException? _error;
  bool initialized = false;

  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init() async {
    _counterRef = FirebaseDatabase.instance.ref('counter');

    final database = FirebaseDatabase.instance;

    _messagesRef = database.ref('messages');

    database.setLoggingEnabled(false);

    if (!kIsWeb) {
      database.setPersistenceEnabled(true);
      database.setPersistenceCacheSizeBytes(10000000);
    }

    if (!kIsWeb) {
      await _counterRef.keepSynced(true);
    }

    setState(() {
      initialized = true;
    });

    try {
      final counterSnapshot = await _counterRef.get();

      print(
        'Connected to directly configured database and read '
        '${counterSnapshot.value}',
      );
    } catch (err) {
      print(err);
    }

    _counterSubscription = _counterRef.onValue.listen(
      (DatabaseEvent event) {
        setState(() {
          _error = null;
          _counter = (event.snapshot.value ?? 0) as int;
        });
      },
      onError: (Object o) {
        final error = o as FirebaseException;
        setState(() {
          _error = error;
        });
      },
    );

    final messagesQuery = _messagesRef.limitToLast(10);

    _messagesSubscription = messagesQuery.onChildAdded.listen(
      (DatabaseEvent event) {
        print('Child added: ${event.snapshot.value}');
      },
      onError: (Object o) {
        final error = o as FirebaseException;
        print('Error: ${error.code} ${error.message}');
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _messagesSubscription.cancel();
    _counterSubscription.cancel();
  }

  Future<void> _increment() async {
    await _counterRef.set(ServerValue.increment(1));

    await _messagesRef.push().set(<String, String>{
      _kTestKey:
          '$_kTestValue ${FirebaseAuth.instance.currentUser?.displayName} $_counter'
    });
  }

  Future<void> _incrementAsTransaction() async {
    try {
      final transactionResult = await _counterRef.runTransaction((mutableData) {
        return Transaction.success((mutableData as int? ?? 0) + 1);
      });

      if (transactionResult.committed) {
        final newMessageRef = _messagesRef.push();
        await newMessageRef.set(<String, String>{
          _kTestKey:
              '$_kTestValue ${FirebaseAuth.instance.currentUser?.displayName} ${transactionResult.snapshot.value}'
        });
      }
    } on FirebaseException catch (e) {
      print(e.message);
    }
  }

  Future<void> _deleteMessage(DataSnapshot snapshot) async {
    final messageRef = _messagesRef.child(snapshot.key!);
    await messageRef.remove();
  }

  void _setAnchorToBottom(bool? value) {
    if (value == null) {
      return;
    }

    setState(() {
      _anchorToBottom = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!initialized) return Container();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Database Example'),
      ),
      body: Column(
        children: [
          Flexible(
            child: Center(
              child: _error == null
                  ? Text(
                      'Button tapped $_counter time${_counter == 1 ? '' : 's'}.\n\n'
                      'This includes all devices, ever.',
                    )
                  : Text(
                      'Error retrieving button tap count:\n${_error!.message}',
                    ),
            ),
          ),
          ElevatedButton(
            onPressed: _incrementAsTransaction,
            child: const Text('Increment as transaction'),
          ),
          ListTile(
            leading: Checkbox(
              onChanged: _setAnchorToBottom,
              value: _anchorToBottom,
            ),
            title: const Text('Anchor to bottom'),
          ),
          Flexible(
            child: FirebaseAnimatedList(
              key: ValueKey<bool>(_anchorToBottom),
              query: _messagesRef,
              reverse: _anchorToBottom,
              itemBuilder: (context, snapshot, animation, index) {
                return SizeTransition(
                  sizeFactor: animation,
                  child: ListTile(
                    trailing: IconButton(
                      onPressed: () => _deleteMessage(snapshot),
                      icon: const Icon(Icons.delete),
                    ),
                    title: Text('$index: ${snapshot.value.toString()}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _increment,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
