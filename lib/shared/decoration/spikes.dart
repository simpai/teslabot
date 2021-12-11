import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/priority_layer.dart';
import 'package:teslabot/manual_map/dungeon_map.dart';
import 'package:teslabot/shared/util/common_sprite_sheet.dart';

class Spikes extends GameDecoration with Sensor {
  double dt = 0;

  Spikes(Vector2 position)
      : super.withSprite(
          CommonSpriteSheet.spikesSprite,
          position: position,
          width: DungeonMap.tileSize / 1.5,
          height: DungeonMap.tileSize / 1.5,
        ) {
    setupSensorArea(intervalCheck: 500);
  }

  @override
  void update(double dt) {
    this.dt = dt;
    super.update(dt);
  }

  @override
  void onContact(GameComponent component) {
    if (component is Attackable) {
      component.receiveDamage(10, 1);
    }
  }

  @override
  int get priority => LayerPriority.MAP + 1;
}
