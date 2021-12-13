import 'package:bonfire/bonfire.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:teslabot/manual_map/game_manual_map.dart';
import 'package:teslabot/simple_example/simple_example_game.dart';
import 'package:teslabot/tiled_map/game_tiled_map.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb) {
    await Flame.device.setLandscape();
    await Flame.device.fullScreen();
  }
  runApp(
    MaterialApp(
      home: Menu(),
    ),
  );
}

class Menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan[900],
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'Bonfire',
              style: TextStyle(fontSize: 30, color: Colors.white),
            ),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                child: const Text('Simple example'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SimpleExampleGame()),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                child: const Text('Manual Map'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GameManualMap()),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                child: const Text('Tiled Map'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GameTiledMap(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 40,
        child: const Center(
          child: const Text(
            'Keyboard: directional and Space Bar to attack',
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
