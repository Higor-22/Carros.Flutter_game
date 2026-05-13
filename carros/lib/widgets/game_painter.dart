import 'dart:math';

import 'package:flutter/material.dart';

class GamePainter extends CustomPainter {
  final double carX;
  final List<Map<String, dynamic>> obstacles;
  final List<Map<String, dynamic>> coins;
  final List<Map<String, dynamic>> buffs;
  final bool isGameOver;
  final Color carColor;
  final bool hasShield;
  final bool isImmune;
  final bool doubleScore;

  GamePainter({
    required this.carX,
    required this.obstacles,
    required this.coins,
    required this.buffs,
    required this.isGameOver,
    required this.carColor,
    required this.hasShield,
    required this.isImmune,
    required this.doubleScore,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double laneWidth = size.width;
    double laneHeight = size.height;
    
    // Zoom reduzido
    double zoomPercent = 0.80;
    double gameWidth = laneWidth * zoomPercent;
    double gameHeight = laneHeight * zoomPercent;
    double offsetX = (laneWidth - gameWidth) / 2;
    double offsetY = (laneHeight - gameHeight) / 2;
    
    // Fundo preto
    Paint blackPaint = Paint()..color = Colors.black;
    canvas.drawRect(Rect.fromLTWH(0, 0, laneWidth, laneHeight), blackPaint);
    
    // Estrada
    Paint roadPaint = Paint()..color = Colors.grey[800]!;
    canvas.drawRect(Rect.fromLTWH(offsetX, offsetY, gameWidth, gameHeight), roadPaint);
    
    // Linhas da estrada
    Paint linePaint = Paint()..color = Colors.white..strokeWidth = 2;
    for (int i = 0; i < 3; i++) {
      double x = offsetX + gameWidth * (i + 1) / 4;
      canvas.drawLine(Offset(x, offsetY), Offset(x, offsetY + gameHeight), linePaint);
    }
    
    // Desenhar BUFFS
    for (var buff in buffs) {
      double x = offsetX + (buff['x'] + 1) / 2 * gameWidth;
      double y = offsetY + (buff['y'] + 1) / 2 * gameHeight;
      
      Color buffColor = buff['color'] as Color;
      Paint buffPaint = Paint()..color = buffColor;
      canvas.drawCircle(Offset(x, y), gameWidth / 20, buffPaint);
      
      // Efeito brilhante
      Paint glowPaint = Paint()..color = buffColor.withOpacity(0.5);
      canvas.drawCircle(Offset(x, y), gameWidth / 15, glowPaint);
      
      String buffName = buff['name'] as String;
      TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: buffName.split(' ')[0],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
    
    // Desenhar moedas
    Paint coinPaint = Paint()..color = Colors.amber;
    for (var coin in coins) {
      double x = offsetX + (coin['x'] + 1) / 2 * gameWidth;
      double y = offsetY + (coin['y'] + 1) / 2 * gameHeight;
      
      canvas.drawCircle(Offset(x, y), gameWidth / 28, coinPaint);
      
      Paint coinDetailPaint = Paint()..color = Colors.amber[700]!;
      canvas.drawCircle(Offset(x, y), gameWidth / 40, coinDetailPaint);
      
      final TextPainter textPainter = TextPainter(
        text: const TextSpan(
          text: '🪙',
          style: TextStyle(
            color: Colors.black,
            fontSize: 10,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
    
    // Desenhar obstáculos
    Paint obstaclePaint = Paint()..color = Colors.red;
    for (var obstacle in obstacles) {
      double x = offsetX + (obstacle['x'] + 1) / 2 * gameWidth;
      double y = offsetY + (obstacle['y'] + 1) / 2 * gameHeight;
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x, y),
            width: gameWidth / 12,
            height: gameHeight / 12,
          ),
          const Radius.circular(6),
        ),
        obstaclePaint,
      );
    }
    
    // Desenhar carro com efeitos de buff
    Paint carPaint = Paint()..color = carColor;
    
    // Efeito escudo
    if (hasShield) {
      Paint shieldPaint = Paint()..color = Colors.orange.withOpacity(0.5);
      canvas.drawCircle(
        Offset(offsetX + (carX + 1) / 2 * gameWidth, offsetY + gameHeight - gameHeight / 8 - 15),
        gameWidth / 7,
        shieldPaint,
      );
    }
    
    // Efeito imunidade
    if (isImmune) {
      Paint immunePaint = Paint()..color = Colors.purple.withOpacity(0.5);
      canvas.drawCircle(
        Offset(offsetX + (carX + 1) / 2 * gameWidth, offsetY + gameHeight - gameHeight / 8 - 15),
        gameWidth / 6,
        immunePaint,
      );
    }
    
    // Efeito double score (estrelas ao redor)
    if (doubleScore) {
      Paint starPaint = Paint()..color = Colors.amber.withOpacity(0.8);
      double centerX = offsetX + (carX + 1) / 2 * gameWidth;
      double centerY = offsetY + gameHeight - gameHeight / 8 - 15;
      for (int i = 0; i < 8; i++) {
        double angle = i * 3.14159 * 2 / 8;
        double starX = centerX + cos(angle) * (gameWidth / 6);
        double starY = centerY + sin(angle) * (gameWidth / 6);
        canvas.drawCircle(Offset(starX, starY), gameWidth / 25, starPaint);
      }
    }
    
    double carWidth = gameWidth / 10;
    double carHeight = gameHeight / 8;
    double carY = offsetY + gameHeight - carHeight - 15;
    double carCenterX = offsetX + (carX + 1) / 2 * gameWidth;
    
    // Corpo do carro
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(carCenterX, carY),
          width: carWidth,
          height: carHeight,
        ),
        const Radius.circular(8),
      ),
      carPaint,
    );
    
    // Janelas
    Paint windowPaint = Paint()..color = Colors.blue[300]!;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(carCenterX, carY - carHeight / 4),
          width: carWidth / 1.3,
          height: carHeight / 3,
        ),
        const Radius.circular(4),
      ),
      windowPaint,
    );
    
    // Faróis
    Paint lightPaint = Paint()..color = Colors.yellow;
    canvas.drawCircle(
      Offset(carCenterX - carWidth / 2.5, carY - carHeight / 2.5),
      carWidth / 10,
      lightPaint,
    );
    canvas.drawCircle(
      Offset(carCenterX + carWidth / 2.5, carY - carHeight / 2.5),
      carWidth / 10,
      lightPaint,
    );
    
    // Game Over
    if (isGameOver) {
      Paint overlayPaint = Paint()..color = Colors.black.withOpacity(0.7);
      canvas.drawRect(Rect.fromLTWH(offsetX, offsetY, gameWidth, gameHeight), overlayPaint);
      
      final TextPainter textPainter = TextPainter(
        text: const TextSpan(
          text: 'GAME OVER',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(offsetX + gameWidth / 2 - textPainter.width / 2, offsetY + gameHeight / 2 - 30),
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}