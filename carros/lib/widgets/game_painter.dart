import 'dart:math';
import 'package:flutter/material.dart';

class GamePainter extends CustomPainter {
  final double carX;
  final List<Map<String, dynamic>> obstacles;
  final List<Map<String, dynamic>> coins;
  final List<Map<String, dynamic>> buffs;
  final bool isGameOver;
  final Color carColor;
  final String carImagePath;
  final bool hasShield;
  final bool isImmune;
  final bool doubleScore;
  final bool hasSpeed;
  final bool hasMagnet;

  GamePainter({
    required this.carX,
    required this.obstacles,
    required this.coins,
    required this.buffs,
    required this.isGameOver,
    required this.carColor,
    required this.carImagePath,
    required this.hasShield,
    required this.isImmune,
    required this.doubleScore,
    required this.hasSpeed,
    required this.hasMagnet,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double gameWidth = size.width;
    double gameHeight = size.height;
    
    // Estrada
    Paint roadPaint = Paint()..color = Colors.grey[800]!;
    canvas.drawRect(Rect.fromLTWH(0, 0, gameWidth, gameHeight), roadPaint);
    
    // Linhas da estrada
    Paint linePaint = Paint()..color = Colors.white..strokeWidth = 2;
    for (int i = 0; i < 3; i++) {
      double x = gameWidth * (i + 1) / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, gameHeight), linePaint);
    }
    
    // BUFFS
    for (var buff in buffs) {
      double x = (buff['x'] + 1) / 2 * gameWidth;
      double y = (buff['y'] + 1) / 2 * gameHeight;
      Color buffColor = buff['color'] as Color;
      Paint buffPaint = Paint()..color = buffColor;
      canvas.drawCircle(Offset(x, y), gameWidth / 20, buffPaint);
      Paint glowPaint = Paint()..color = buffColor.withOpacity(0.5);
      canvas.drawCircle(Offset(x, y), gameWidth / 15, glowPaint);
      
      // Nome do buff
      String buffName = buff['name'] as String;
      TextPainter tp = TextPainter(
        text: TextSpan(text: buffName.split(' ')[0], style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
    }
    
    // MOEDAS
    Paint coinPaint = Paint()..color = Colors.amber;
    for (var coin in coins) {
      double x = (coin['x'] + 1) / 2 * gameWidth;
      double y = (coin['y'] + 1) / 2 * gameHeight;
      canvas.drawCircle(Offset(x, y), gameWidth / 32, coinPaint);
      Paint coinDetailPaint = Paint()..color = Colors.amber[700]!;
      canvas.drawCircle(Offset(x, y), gameWidth / 45, coinDetailPaint);
    }
    
    // OBSTÁCULOS
    Paint obstaclePaint = Paint()..color = Colors.red;
    for (var obstacle in obstacles) {
      double x = (obstacle['x'] + 1) / 2 * gameWidth;
      double y = (obstacle['y'] + 1) / 2 * gameHeight;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, y), width: gameWidth / 12, height: gameHeight / 12),
          const Radius.circular(6),
        ),
        obstaclePaint,
      );
    }
    
    // ==================== CARRO COM SPRITE ====================
    double carWidth = gameWidth / 5;
    double carHeight = gameHeight / 4;
    double carY = gameHeight - carHeight - 15;
    double carCenterX = (carX + 1) / 2 * gameWidth;
    
    // Efeitos visuais
    if (hasShield) {
      Paint shieldPaint = Paint()..color = Colors.orange.withOpacity(0.5);
      canvas.drawCircle(Offset(carCenterX, carY + carHeight / 2), gameWidth / 4.5, shieldPaint);
    }
    if (isImmune) {
      Paint immunePaint = Paint()..color = Colors.purple.withOpacity(0.5);
      canvas.drawCircle(Offset(carCenterX, carY + carHeight / 2), gameWidth / 4, immunePaint);
    }
    if (hasMagnet) {
      Paint magnetPaint = Paint()..color = Colors.brown.withOpacity(0.4);
      canvas.drawCircle(Offset(carCenterX, carY + carHeight / 2), gameWidth / 4.2, magnetPaint);
    }
    if (hasSpeed) {
      Paint speedPaint = Paint()..color = Colors.cyan.withOpacity(0.3);
      for (int i = 0; i < 3; i++) {
        canvas.drawCircle(Offset(carCenterX, carY + carHeight / 2 + i * 5), gameWidth / 8, speedPaint);
      }
    }
    if (doubleScore) {
      Paint starPaint = Paint()..color = Colors.amber.withOpacity(0.8);
      for (int i = 0; i < 8; i++) {
        double angle = i * 3.14159 * 2 / 8;
        double starX = carCenterX + cos(angle) * (gameWidth / 4.5);
        double starY = carY + carHeight / 2 + sin(angle) * (gameWidth / 4.5);
        canvas.drawCircle(Offset(starX, starY), gameWidth / 40, starPaint);
      }
    }
    
    // CARREGAR E DESENHAR A IMAGEM DO SPRITE
    try {
      final ImageProvider image = AssetImage(carImagePath);
      final ImageStream stream = image.resolve(ImageConfiguration.empty);
      
      // Usar ImageStreamListener para carregar a imagem
      stream.addListener(ImageStreamListener((info, _) {
        canvas.drawImageRect(
          info.image,
          Rect.fromLTWH(0, 0, info.image.width.toDouble(), info.image.height.toDouble()),
          Rect.fromCenter(
            center: Offset(carCenterX, carY + carHeight / 2),
            width: carWidth,
            height: carHeight,
          ),
          Paint(),
        );
      }));
    } catch (e) {
      // FALLBACK: Se a imagem não carregar, desenha um carro colorido
      Paint fallbackPaint = Paint()..color = carColor;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(carCenterX, carY + carHeight / 2), width: carWidth, height: carHeight),
          const Radius.circular(8),
        ),
        fallbackPaint,
      );
    }
    
    // Game Over
    if (isGameOver) {
      Paint overlayPaint = Paint()..color = Colors.black.withOpacity(0.7);
      canvas.drawRect(Rect.fromLTWH(0, 0, gameWidth, gameHeight), overlayPaint);
      
      TextPainter textPainter = TextPainter(
        text: const TextSpan(text: 'GAME OVER', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(gameWidth / 2 - textPainter.width / 2, gameHeight / 2 - 30));
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}