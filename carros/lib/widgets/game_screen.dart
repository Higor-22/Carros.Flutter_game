import 'package:carros/widgets/game_constants.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter/services.dart';
import '../widgets/game_painter.dart';

class GameScreen extends StatefulWidget {
  final String playerName;
  final String difficulty;
  final Map<String, dynamic> gameConfig;
  final Color carColor;
  final String carImagePath;
  final Function(int) onGameEnd;

  const GameScreen({Key? key, 
    required this.playerName,
    required this.difficulty,
    required this.gameConfig,
    required this.carColor,
    required this.carImagePath,
    required this.onGameEnd,
  }) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  double carX = 0.0;
  List<Map<String, dynamic>> obstacles = [];
  List<Map<String, dynamic>> coins = [];
  List<Map<String, dynamic>> buffs = [];
  int score = 0;
  int coinsCollected = 0;
  bool isGameOver = false;
  Timer? gameTimer;
  Timer? obstacleTimer;
  Timer? coinTimer;
  Timer? buffTimer;
  Random random = Random();
  
  bool leftPressed = false;
  bool rightPressed = false;
  Timer? keyboardTimer;
  
  bool hasShield = false;
  bool isImmune = false;
  bool doubleScore = false;
  bool hasSpeed = false;
  bool hasMagnet = false;
  Timer? shieldTimer;
  Timer? immuneTimer;
  Timer? doubleScoreTimer;
  Timer? speedTimer;
  Timer? magnetTimer;

  @override
  void initState() {
    super.initState();
    startGame();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startKeyboardControl();
    });
  }

  void startGame() {
    score = 0;
    coinsCollected = 0;
    obstacles.clear();
    coins.clear();
    buffs.clear();
    carX = 0.0;
    isGameOver = false;
    hasShield = false;
    isImmune = false;
    doubleScore = false;
    hasSpeed = false;
    hasMagnet = false;

    gameTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!isGameOver) {
        moveObjects();
        checkCollision();
        checkCoinCollection();
        checkBuffCollection();
        setState(() {});
      }
    });

    int obstacleInterval = 800 ~/ widget.gameConfig['obstacles'];
    obstacleTimer = Timer.periodic(Duration(milliseconds: obstacleInterval), (timer) {
      if (!isGameOver) {
        addObstacle();
      }
    });

    int coinInterval = 1000;
    coinTimer = Timer.periodic(Duration(milliseconds: coinInterval), (timer) {
      if (!isGameOver) {
        addMultipleCoins(2);
      }
    });
    
    buffTimer = Timer.periodic(const Duration(seconds: 7), (timer) {
      if (!isGameOver) {
        addBuff();
      }
    });
  }

  void moveObjects() {
    double currentSpeed = widget.gameConfig['speed'] / 50;
    if (hasSpeed) currentSpeed *= 1.5;

    if (hasMagnet) {
      for (var coin in coins) {
        double diff = carX - (coin['x'] as double);
        double attraction = (diff.abs() > 0.5) ? 0.25 : 0.15;
        coin['x'] = (coin['x'] as double) + diff * attraction;
        coin['x'] = (coin['x'] as double).clamp(-0.9, 0.9);
      }
    }

    for (var o in obstacles) { o['y'] = (o['y'] as double) + currentSpeed; }
    obstacles.removeWhere((o) => o['y'] > 1.0);
    for (var c in coins) { c['y'] = (c['y'] as double) + currentSpeed; }
    coins.removeWhere((c) => c['y'] > 1.0);
    for (var b in buffs) { b['y'] = (b['y'] as double) + currentSpeed; }
    buffs.removeWhere((b) => b['y'] > 1.0);

    score += doubleScore ? 2 : 1;
  }

  void addObstacle() {
    obstacles.add({'x': (random.nextDouble() - 0.5) * 1.6, 'y': -0.8});
  }

  void addMultipleCoins(int count) {
    for (int i = 0; i < count; i++) {
      double newX;
      bool ok;
      int attempts = 0;
      do {
        ok = true;
        newX = (random.nextDouble() - 0.5) * 1.6;
        for (var o in obstacles) {
          if (((o['x'] as double) - newX).abs() < 0.25 && (o['y'] as double) > -0.4) { ok = false; break; }
        }
        attempts++;
        if (attempts > 20) break;
      } while (!ok);
      coins.add({'x': newX, 'y': -0.8});
    }
  }

  void addBuff() {
    int idx = random.nextInt(GameConstants.buffs.length);
    var buff = GameConstants.buffs[idx];
    buffs.add({
      'x': (random.nextDouble() - 0.5) * 1.6,
      'y': -0.8,
      'type': idx,
      'name': buff['name'],
      'effect': buff['effect'],
      'duration': buff['duration'],
      'color': buff['color'],
    });
  }

  void checkCollision() {
    if (isImmune || hasShield) return;
    for (var o in obstacles) {
      if (o['y'] >= GameConstants.obstacleCollisionYMin &&
          o['y'] <= GameConstants.obstacleCollisionYMax &&
          (o['x'] - carX).abs() < GameConstants.collisionThreshold) {
        gameOver();
        break;
      }
    }
  }

  void checkCoinCollection() {
    List<Map<String, dynamic>> toRemove = [];
    for (var c in coins) {
      if (c['y'] >= GameConstants.coinCollisionYMin &&
          c['y'] <= GameConstants.coinCollisionYMax &&
          (c['x'] - carX).abs() < GameConstants.coinCollisionThreshold) {
        toRemove.add(c);
        coinsCollected += doubleScore ? 2 : 1;
      }
    }
    for (var c in toRemove) { coins.remove(c); }
  }

  void checkBuffCollection() {
    List<Map<String, dynamic>> toRemove = [];
    for (var b in buffs) {
      if (b['y'] >= GameConstants.buffCollisionYMin &&
          b['y'] <= GameConstants.buffCollisionYMax &&
          (b['x'] - carX).abs() < GameConstants.buffCollisionThreshold) {
        toRemove.add(b);
        applyBuff(b);
      }
    }
    for (var b in toRemove) { buffs.remove(b); }
  }

  void applyBuff(Map<String, dynamic> buff) {
    String effect = buff['effect'];
    int duration = buff['duration'];
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('✨ ${buff['name']} ativado! ✨'),
      backgroundColor: buff['color'],
      duration: const Duration(seconds: 2),
    ));

    switch (effect) {
      case 'speed':
        hasSpeed = true;
        speedTimer = Timer(Duration(seconds: duration), () {
          hasSpeed = false;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚡ Velocidade acabou!')));
        });
        break;
      case 'shield':
        hasShield = true;
        shieldTimer = Timer(Duration(seconds: duration), () {
          hasShield = false;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🛡️ Escudo acabou!')));
        });
        break;
      case 'immune':
        isImmune = true;
        immuneTimer = Timer(Duration(seconds: duration), () {
          isImmune = false;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('💨 Imunidade acabou!')));
        });
        break;
      case 'doubleScore':
        doubleScore = true;
        doubleScoreTimer = Timer(Duration(seconds: duration), () {
          doubleScore = false;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🔷 Pontos dobrados acabou!')));
        });
        break;
      case 'magnet':
        hasMagnet = true;
        magnetTimer = Timer(Duration(seconds: duration), () {
          hasMagnet = false;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🧲 Ímã acabou!')));
        });
        break;
    }
  }

  void gameOver() {
    isGameOver = true;
    gameTimer?.cancel();
    obstacleTimer?.cancel();
    coinTimer?.cancel();
    buffTimer?.cancel();
    stopKeyboardControl();
    showGameOverDialog();
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over! 🎮'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Jogador: ${widget.playerName}'),
            Text('Dificuldade: ${widget.difficulty}'),
            const SizedBox(height: 10),
            Text('🏆 Pontuação: ${score ~/ 10}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('🪙 Moedas: $coinsCollected', style: const TextStyle(fontSize: 18, color: Colors.amber)),
            const SizedBox(height: 20),
            const Text('O que deseja fazer?'),
          ],
        ),
        actions: [
          TextButton(onPressed: () { widget.onGameEnd(coinsCollected); Navigator.pop(context); Navigator.pop(context); }, child: const Text('MENU PRINCIPAL')),
          ElevatedButton(onPressed: () { widget.onGameEnd(coinsCollected); Navigator.pop(context); setState(() { startGame(); }); }, child: const Text('REINICIAR')),
        ],
      ),
    );
  }

  void goBackToMenu() {
    gameTimer?.cancel();
    obstacleTimer?.cancel();
    coinTimer?.cancel();
    buffTimer?.cancel();
    stopKeyboardControl();
    widget.onGameEnd(coinsCollected);
    Navigator.pop(context);
  }

  void startKeyboardControl() {
    keyboardTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!isGameOver) {
        setState(() {
          if (leftPressed) carX = (carX - GameConstants.carMoveStep).clamp(GameConstants.carMinX, GameConstants.carMaxX);
          if (rightPressed) carX = (carX + GameConstants.carMoveStep).clamp(GameConstants.carMinX, GameConstants.carMaxX);
        });
      }
    });
  }

  void stopKeyboardControl() {
    keyboardTimer?.cancel();
    leftPressed = false;
    rightPressed = false;
  }

  void onKey(RawKeyEvent event) {
    if (isGameOver) return;
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft || event.logicalKey == LogicalKeyboardKey.keyA) leftPressed = true;
      if (event.logicalKey == LogicalKeyboardKey.arrowRight || event.logicalKey == LogicalKeyboardKey.keyD) rightPressed = true;
    } else if (event is RawKeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft || event.logicalKey == LogicalKeyboardKey.keyA) leftPressed = false;
      if (event.logicalKey == LogicalKeyboardKey.arrowRight || event.logicalKey == LogicalKeyboardKey.keyD) rightPressed = false;
    }
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    obstacleTimer?.cancel();
    coinTimer?.cancel();
    buffTimer?.cancel();
    shieldTimer?.cancel();
    immuneTimer?.cancel();
    doubleScoreTimer?.cancel();
    speedTimer?.cancel();
    magnetTimer?.cancel();
    stopKeyboardControl();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: onKey,
      autofocus: true,
      child: Scaffold(
        body: GestureDetector(
          onHorizontalDragUpdate: (details) {
            if (!isGameOver) {
              setState(() {
                double delta = details.delta.dx / 100;
                carX = (carX + delta).clamp(GameConstants.carMinX, GameConstants.carMaxX);
              });
            }
          },
          child: Container(
            color: Colors.black,
            child: Column(
              children: [
                // HEADER
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  color: Colors.grey[900],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('👤 ${widget.playerName}', style: const TextStyle(color: Colors.white, fontSize: 9)),
                      Row(
                        children: [
                          if (hasSpeed) const Icon(Icons.speed, color: Colors.cyan, size: 12),
                          if (hasShield) const Icon(Icons.shield, color: Colors.orange, size: 12),
                          if (isImmune) const Icon(Icons.bolt, color: Colors.purple, size: 12),
                          if (doubleScore) const Icon(Icons.star, color: Colors.amber, size: 12),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(10)),
                            child: Text('🪙 $coinsCollected', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black)),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(10)),
                            child: Text('🏆 ${score ~/ 10}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.exit_to_app, color: Colors.white, size: 16),
                            onPressed: goBackToMenu,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // ÁREA DO JOGO
                Expanded(
                  child: CustomPaint(
                    painter: GamePainter(
                      carX: carX,
                      obstacles: obstacles,
                      coins: coins,
                      buffs: buffs,
                      isGameOver: isGameOver,
                      carColor: widget.carColor,
                      carImagePath: widget.carImagePath,  // ← PASSA O CAMINHO DA IMAGEM
                      hasShield: hasShield,
                      isImmune: isImmune,
                      doubleScore: doubleScore,
                      hasSpeed: hasSpeed,
                      hasMagnet: hasMagnet,
                    ),
                    size: Size.infinite,
                  ),
                ),
                // CONTROLES
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  color: Colors.grey[900],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_left, size: 35, color: Colors.white),
                        onPressed: isGameOver ? null : () => setState(() => carX = (carX - 0.1).clamp(GameConstants.carMinX, GameConstants.carMaxX)),
                      ),
                      const Text('←  →', style: TextStyle(color: Colors.white70, fontSize: 10)),
                      IconButton(
                        icon: const Icon(Icons.arrow_right, size: 35, color: Colors.white),
                        onPressed: isGameOver ? null : () => setState(() => carX = (carX + 0.1).clamp(GameConstants.carMinX, GameConstants.carMaxX)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}