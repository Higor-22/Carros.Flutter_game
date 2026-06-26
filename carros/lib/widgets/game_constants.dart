import 'package:flutter/material.dart';

class GameConstants {
  static final Map<String, Map<String, dynamic>> difficulties = {
    'Fácil': {'speed': 3, 'obstacles': 3, 'coins': 5, 'color': Colors.green},
    'Médio': {'speed': 5, 'obstacles': 4, 'coins': 4, 'color': Colors.orange},
    'Difícil': {'speed': 7, 'obstacles': 5, 'coins': 3, 'color': Colors.red},
  };
  
  static List<Map<String, dynamic>> cars = [
    {'name': '🚗 Carro 1', 'price': 0, 'color': Colors.red, 'owned': true, 'image': 'assets/sprite/Corte-carro-1.png'},
    {'name': '🚙 Carro 2', 'price': 50, 'color': Colors.blue, 'owned': false, 'image': 'assets/sprite/Corte-carro-2.png'},
    {'name': '🏎️ Carro 3', 'price': 100, 'color': Colors.green, 'owned': false, 'image': 'assets/sprite/Corte-carro-3.png'},
    {'name': '🚕 Carro 4', 'price': 150, 'color': Colors.yellow, 'owned': false, 'image': 'assets/sprite/Corte-carro-4.png'},
  ];
  
  static final List<Map<String, dynamic>> buffs = [
    {'name': '⚡ Velocidade', 'color': Colors.cyan, 'effect': 'speed', 'duration': 5},
    {'name': '🛡️ Escudo', 'color': Colors.orange, 'effect': 'shield', 'duration': 5},
    {'name': '💨 Imune', 'color': Colors.purple, 'effect': 'immune', 'duration': 3},
    {'name': '🔷 Pontos Dobrados', 'color': Colors.lightBlue, 'effect': 'doubleScore', 'duration': 5},
    {'name': '🧲 Ímã', 'color': Colors.brown, 'effect': 'magnet', 'duration': 6},
  ];
  
  static const double carMinX = -0.8;
  static const double carMaxX = 0.8;
  static const double carMoveStep = 0.05;
  static const double collisionThreshold = 0.12;
  static const double coinCollisionThreshold = 0.12;
  static const double buffCollisionThreshold = 0.18;
  static const double obstacleCollisionYMin = 0.6;
  static const double obstacleCollisionYMax = 0.8;
  static const double coinCollisionYMin = 0.6;
  static const double coinCollisionYMax = 0.8;
  static const double buffCollisionYMin = 0.6;
  static const double buffCollisionYMax = 0.8;
}