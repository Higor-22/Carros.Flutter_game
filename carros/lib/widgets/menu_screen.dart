import 'package:carros/widgets/game_constants.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'game_screen.dart';
import 'shop_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _difficulty = 'Fácil';
  int _totalCoins = 0;
  int _selectedCarIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadGameData();
  }

  void _loadGameData() {
    if (GameConstants.cars.isNotEmpty && !GameConstants.cars[0]['owned']) {
      GameConstants.cars[0]['owned'] = true;
    }
    if (_selectedCarIndex >= GameConstants.cars.length) {
      _selectedCarIndex = 0;
    }
  }

  void _updateCoins(int coins) {
    setState(() {
      _totalCoins += coins;
    });
  }

  void _startGame() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite seu nome!')),
      );
      return;
    }
    
    if (!GameConstants.cars[_selectedCarIndex]['owned']) {
      setState(() {
        _selectedCarIndex = 0;
      });
    }
    
    // PEGA O CAMINHO DA IMAGEM DO CARRO SELECIONADO
    String imagePath = GameConstants.cars[_selectedCarIndex]['image'] ?? 'assets/sprite/Carte-carro-1.png';
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(
          playerName: _nameController.text,
          difficulty: _difficulty,
          gameConfig: GameConstants.difficulties[_difficulty]!,
          carColor: GameConstants.cars[_selectedCarIndex]['color'] as Color,
          carImagePath: imagePath,  // PASSA O CAMINHO DA IMAGEM
          onGameEnd: (coins) {
            _updateCoins(coins);
          },
        ),
      ),
    );
  }

  void _openShop() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShopScreen(
          totalCoins: _totalCoins,
          selectedCarIndex: _selectedCarIndex,
        ),
      ),
    );
    
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        if (result['coinsSpent'] != null && result['coinsSpent'] > 0) {
          _totalCoins -= result['coinsSpent'] as int;
        }
        if (result['selectedCarIndex'] != null) {
          _selectedCarIndex = result['selectedCarIndex'] as int;
        }
      });
      
      String selectedCarName = GameConstants.cars[_selectedCarIndex]['name'] as String;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🚗 Agora usando: $selectedCarName'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _quitGame() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair do Jogo'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              exit(0);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('SAIR'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int carIndex = _selectedCarIndex < GameConstants.cars.length ? _selectedCarIndex : 0;
    final Map<String, dynamic> selectedCar = GameConstants.cars[carIndex];
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade900, Colors.black],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.exit_to_app, color: Colors.white, size: 30),
                      onPressed: _quitGame,
                      tooltip: 'Sair do Jogo',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                const Icon(Icons.sports_motorsports, size: 80, color: Colors.white),
                const SizedBox(height: 20),
                const Text(
                  'CAR GAME 2D',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: selectedCar['color'] as Color,
                        child: Text(
                          (selectedCar['name'] as String).split(' ')[0],
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        selectedCar['name'] as String,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 50),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Seu Nome',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    prefixIcon: Icon(Icons.person, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Dificuldade:',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                const SizedBox(height: 10),
                ...GameConstants.difficulties.keys.map((difficulty) {
                  return RadioListTile<String>(
                    title: Text(
                      difficulty,
                      style: const TextStyle(color: Colors.white),
                    ),
                    value: difficulty,
                    groupValue: _difficulty,
                    onChanged: (value) {
                      setState(() {
                        _difficulty = value!;
                      });
                    },
                    activeColor: GameConstants.difficulties[difficulty]!['color'] as Color,
                  );
                }),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _openShop,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart),
                            SizedBox(width: 10),
                            Text('LOJA'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _startGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_arrow),
                            SizedBox(width: 10),
                            Text('JOGAR'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}