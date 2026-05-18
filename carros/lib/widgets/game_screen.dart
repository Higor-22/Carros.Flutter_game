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
  final Function(int) onGameEnd;

  const GameScreen({Key? key, 
    required this.playerName,
    required this.difficulty,
    required this.gameConfig,
    required this.carColor,
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
  Timer? shieldTimer;
  Timer? immuneTimer;
  Timer? doubleScoreTimer;

  @override
  void initState() {
    super.initState();
    startGame();
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

    // MOEDAS: Aparecem 2 moedas a cada 1000ms (1 segundo)
    int coinInterval = 1000; // 1 segundo entre cada grupo de moedas
    coinTimer = Timer.periodic(Duration(milliseconds: coinInterval), (timer) {
      if (!isGameOver) {
        addMultipleCoins(2); // Adiciona 2 moedas por vez
      }
    });
    
    // Buffs: aparecem a cada 7 segundos
    buffTimer = Timer.periodic(const Duration(seconds: 7), (timer) {
      if (!isGameOver) {
        addBuff();
      }
    });
  }

  void moveObjects() {
    for (var obstacle in obstacles) {
      obstacle['y'] += widget.gameConfig['speed'] / 50;
    }
    obstacles.removeWhere((obstacle) => obstacle['y'] > 1.0);
    
    for (var coin in coins) {
      coin['y'] += widget.gameConfig['speed'] / 50;
    }
    coins.removeWhere((coin) => coin['y'] > 1.0);
    
    for (var buff in buffs) {
      buff['y'] += widget.gameConfig['speed'] / 50;
    }
    buffs.removeWhere((buff) => buff['y'] > 1.0);
    
    if (doubleScore) {
      score += 2;
    } else {
      score++;
    }
  }

  void addObstacle() {
    obstacles.add({
      'x': (random.nextDouble() - 0.5) * 1.6,
      'y': -0.8,
    });
  }

  // Função que adiciona múltiplas moedas por vez
  void addMultipleCoins(int count) {
    for (int i = 0; i < count; i++) {
      double newX;
      bool positionValid;
      int attempts = 0;
      
      do {
        positionValid = true;
        newX = (random.nextDouble() - 0.5) * 1.6;
        
        // Verifica se não colide com obstáculos
        for (var obstacle in obstacles) {
          if ((obstacle['x'] - newX).abs() < 0.25 && obstacle['y'] > -0.4) {
            positionValid = false;
            break;
          }
        }
        
        // Verifica se não colide com outras moedas que serão adicionadas no mesmo grupo
        for (int j = 0; j < i; j++) {
          if (coins.length > j && (coins[j]['x'] - newX).abs() < 0.2) {
            positionValid = false;
            break;
          }
        }
        
        attempts++;
        if (attempts > 20) break;
      } while (!positionValid);
      
      coins.add({
        'x': newX,
        'y': -0.8,
      });
    }
  }

  void addBuff() {
    int buffIndex = random.nextInt(GameConstants.buffs.length);
    Map<String, dynamic> buff = GameConstants.buffs[buffIndex];
    
    double newX = (random.nextDouble() - 0.5) * 1.6;
    
    buffs.add({
      'x': newX,
      'y': -0.8,
      'type': buffIndex,
      'name': buff['name'],
      'effect': buff['effect'],
      'duration': buff['duration'],
      'color': buff['color'],
    });
  }

  void checkCollision() {
    if (isImmune || hasShield) return;
    
    for (var obstacle in obstacles) {
      if (obstacle['y'] >= GameConstants.obstacleCollisionYMin && 
          obstacle['y'] <= GameConstants.obstacleCollisionYMax &&
          (obstacle['x'] - carX).abs() < GameConstants.collisionThreshold) {
        gameOver();
        break;
      }
    }
  }

  void checkCoinCollection() {
    List<Map<String, dynamic>> coinsToRemove = [];
    
    for (var coin in coins) {
      if (coin['y'] >= GameConstants.coinCollisionYMin && 
          coin['y'] <= GameConstants.coinCollisionYMax &&
          (coin['x'] - carX).abs() < GameConstants.coinCollisionThreshold) {
        coinsToRemove.add(coin);
        
        if (doubleScore) {
          coinsCollected += 2;
        } else {
          coinsCollected++;
        }
      }
    }
    
    for (var coin in coinsToRemove) {
      coins.remove(coin);
    }
  }

  void checkBuffCollection() {
    List<Map<String, dynamic>> buffsToRemove = [];
    
    for (var buff in buffs) {
      if (buff['y'] >= GameConstants.buffCollisionYMin && 
          buff['y'] <= GameConstants.buffCollisionYMax &&
          (buff['x'] - carX).abs() < GameConstants.buffCollisionThreshold) {
        buffsToRemove.add(buff);
        applyBuff(buff);
      }
    }
    
    for (var buff in buffsToRemove) {
      buffs.remove(buff);
    }
  }

  void applyBuff(Map<String, dynamic> buff) {
    String effect = buff['effect'];
    int duration = buff['duration'];
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✨ ${buff['name']} ativado! ✨'),
        backgroundColor: buff['color'],
        duration: const Duration(seconds: 2),
      ),
    );
    
    switch(effect) {
      case 'shield':
        hasShield = true;
        shieldTimer?.cancel();
        shieldTimer = Timer(Duration(seconds: duration), () {
          hasShield = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('🛡️ Escudo acabou!'), backgroundColor: Colors.grey),
          );
        });
        break;
        
      case 'immune':
        isImmune = true;
        immuneTimer?.cancel();
        immuneTimer = Timer(Duration(seconds: duration), () {
          isImmune = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('💨 Imunidade acabou!'), backgroundColor: Colors.grey),
          );
        });
        break;
        
      case 'doubleScore':
        doubleScore = true;
        doubleScoreTimer?.cancel();
        doubleScoreTimer = Timer(Duration(seconds: duration), () {
          doubleScore = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('🔷 Pontos dobrados acabou!'), backgroundColor: Colors.grey),
          );
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
            Text('🏆 Pontuação: ${score ~/ 10}', 
                 style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('🪙 Moedas: $coinsCollected', 
                 style: const TextStyle(fontSize: 18, color: Colors.amber)),
            const SizedBox(height: 20),
            const Text('O que deseja fazer?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              widget.onGameEnd(coinsCollected);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('MENU PRINCIPAL'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onGameEnd(coinsCollected);
              Navigator.pop(context);
              setState(() {
                startGame();
              });
            },
            child: const Text('REINICIAR'),
          ),
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
          if (leftPressed) {
            carX = (carX - GameConstants.carMoveStep).clamp(GameConstants.carMinX, GameConstants.carMaxX);
          }
          if (rightPressed) {
            carX = (carX + GameConstants.carMoveStep).clamp(GameConstants.carMinX, GameConstants.carMaxX);
          }
        });
      }
    });
  }

  void stopKeyboardControl() {
    keyboardTimer?.cancel();
    leftPressed = false;
    rightPressed = false;
  }

  // ignore: deprecated_member_use
  void onKey(RawKeyEvent event) {
    if (isGameOver) return;
    
    // ignore: deprecated_member_use
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        leftPressed = true;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        rightPressed = true;
      }
    // ignore: deprecated_member_use
    } else if (event is RawKeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        leftPressed = false;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        rightPressed = false;
      }
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
    stopKeyboardControl();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        goBackToMenu();
        return false;
      },
      // ignore: deprecated_member_use
      child: RawKeyboardListener(
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
                  // Header SUPER COMPACTO
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    color: Colors.grey[900],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text('👤 ${widget.playerName}',
                                style: const TextStyle(color: Colors.white, fontSize: 9)),
                            const SizedBox(width: 8),
                            Text('🎮 ${widget.difficulty}',
                                style: TextStyle(color: widget.gameConfig['color'], fontSize: 9)),
                          ],
                        ),
                        Row(
                          children: [
                            if (hasShield) const Icon(Icons.shield, color: Colors.orange, size: 12),
                            if (isImmune) const Icon(Icons.bolt, color: Colors.purple, size: 12),
                            if (doubleScore) const Icon(Icons.star, color: Colors.amber, size: 12),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.monetization_on, size: 10, color: Colors.black),
                                  const SizedBox(width: 2),
                                  Text(
                                    '$coinsCollected',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '🏆 ${score ~/ 10}',
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            IconButton(
                              icon: const Icon(Icons.exit_to_app, color: Colors.white, size: 16),
                              onPressed: goBackToMenu,
                              tooltip: 'Voltar ao Menu',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Área do jogo
                  Expanded(
                    child: Focus(
                      autofocus: true,
                      child: CustomPaint(
                        painter: GamePainter(
                          carX: carX,
                          obstacles: obstacles,
                          coins: coins,
                          buffs: buffs,
                          isGameOver: isGameOver,
                          carColor: widget.carColor,
                          hasShield: hasShield,
                          isImmune: isImmune,
                          doubleScore: doubleScore,
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                  
                  // Controles
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    color: Colors.grey[900],
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_left, size: 30, color: Colors.white),
                              onPressed: isGameOver ? null : () {
                                setState(() {
                                  carX = (carX - 0.1).clamp(GameConstants.carMinX, GameConstants.carMaxX);
                                });
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const Text('←  →',
                                style: TextStyle(color: Colors.white70, fontSize: 8)),
                            IconButton(
                              icon: const Icon(Icons.arrow_right, size: 30, color: Colors.white),
                              onPressed: isGameOver ? null : () {
                                setState(() {
                                  carX = (carX + 0.1).clamp(GameConstants.carMinX, GameConstants.carMaxX);
                                });
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(2),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.keyboard, size: 10, color: Colors.white70),
                              SizedBox(width: 3),
                              Text(
                                '←  →',
                                style: TextStyle(color: Colors.white70, fontSize: 8),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}