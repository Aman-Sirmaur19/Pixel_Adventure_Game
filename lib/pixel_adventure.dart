import 'dart:async';

import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'components/level.dart';
import 'components/player.dart';
import 'components/jump_button.dart';

class PixelAdventure extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection,
        TapCallbacks {
  @override
  Color backgroundColor() => const Color(0xFF211F30);

  late CameraComponent cam;
  late JoystickComponent joystick;
  bool showControls = true;
  bool playSounds = true;
  double soundVolume = 1.0;
  Player player = Player(character: 'Pink Man');
  List<String> levelNames = ['Level-01', 'Level-01'];
  int currentLevelIndex = 0;

  @override
  FutureOr<void> onLoad() async {
    // Load all images into cache
    await images.loadAllImages();
    _loadLevel();
    if (showControls) {
      addJoystick();
      add(JumpButton());
    }
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showControls) {
      updateJoystick();
    }
    super.update(dt);
  }

  void addJoystick() {
    joystick = JoystickComponent(
      priority: 1,
      background: CircleComponent(
        radius: 32,
        paint: Paint()..color = const Color(0xFA000000),
      ),
      knob: CircleComponent(
        radius: 16,
        paint: Paint()..color = const Color(0xFFA5A3A3),
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
    );
    // joystick = JoystickComponent(
    //   priority: 1,
    //   knob: SpriteComponent(sprite: Sprite(images.fromCache('HUD/Knob.png'))),
    //   background:
    //   SpriteComponent(sprite: Sprite(images.fromCache('HUD/Joystick.png'))),
    //   margin: const EdgeInsets.only(left: 32, bottom: 32),
    // );
    add(joystick);
    // cam.viewport.add(joystick);
  }

  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        // player.playerDirection = PlayerDirection.left;
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        // player.playerDirection = PlayerDirection.right;
        player.horizontalMovement = 1;
        break;
      default:
        // idle
        // player.playerDirection = PlayerDirection.none;
        player.horizontalMovement = 0;
        break;
    }
  }

  void loadNextLevel() {
    if (currentLevelIndex < levelNames.length - 1) {
      currentLevelIndex++;
      _loadLevel();
    } else {
      // no more levels
      currentLevelIndex = 0;
      _loadLevel();
    }
  }

  void _loadLevel() {
    Future.delayed(const Duration(seconds: 1), () {
      Level levelWorld = Level(
        player: player,
        levelName: levelNames[currentLevelIndex],
      );
      cam = CameraComponent.withFixedResolution(
          world: levelWorld, width: 640, height: 360);
      cam.priority = 0;
      cam.viewfinder.anchor = Anchor.topLeft;
      addAll([cam, levelWorld]);
    });
  }
}
