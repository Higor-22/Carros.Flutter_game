import 'package:flutter/material.dart';

class GameConstants {
  static final Map<String, Map<String, dynamic>> difficulties = {
    'Fácil': {'speed': 3, 'obstacles': 3, 'coins': 5, 'color': Colors.green},
    'Médio': {'speed': 5, 'obstacles': 4, 'coins': 4, 'color': Colors.orange},
    'Difícil': {'speed': 7, 'obstacles': 5, 'coins': 3, 'color': Colors.red},
  };
  
  static List<Map<String, dynamic>> cars = [
    {'name': '🚗 Carro Vermelho', 'price': 0, 'color': Colors.red, 'owned': true},
    {'name': '🚙 Carro Azul', 'price': 50, 'color': Colors.blue, 'owned': false},
    {'name': '🏎️ Carro Verde', 'price': 100, 'color': Colors.green, 'owned': false},
    {'name': '🚕 Carro Amarelo', 'price': 150, 'color': Colors.yellow, 'owned': false},
    {'name': '🖤 Carro Preto', 'price': 200, 'color': Colors.black, 'owned': false},
    {'name': '💜 Carro Roxo', 'price': 300, 'color': Colors.purple, 'owned': false},
  ];
  
  // Tipos de buffs
  static final List<Map<String, dynamic>> buffs = [
    {'name': '⭐ Velocidade', 'color': Colors.cyan, 'effect': 'speed', 'duration': 5},
    {'name': '🛡️ Escudo', 'color': Colors.orange, 'effect': 'shield', 'duration': 5},
    {'name': '💨 Imune', 'color': Colors.purple, 'effect': 'immune', 'duration': 3},
    {'name': '🔷 Pontos Dobrados', 'color': Colors.lightBlue, 'effect': 'doubleScore', 'duration': 5},
  ];
  
  static const double carMinX = -0.8;
  static const double carMaxX = 0.8;
  static const double carMoveStep = 0.05;
  static const double collisionThreshold = 0.15;
  static const double coinCollisionThreshold = 0.15;
  static const double buffCollisionThreshold = 0.15;
  static const double obstacleCollisionYMin = 0.6;
  static const double obstacleCollisionYMax = 0.8;
  static const double coinCollisionYMin = 0.6;
  static const double coinCollisionYMax = 0.8;
  static const double buffCollisionYMin = 0.6;
  static const double buffCollisionYMax = 0.8;
}