import 'package:carros/widgets/game_constants.dart';
import 'package:flutter/material.dart';

class ShopScreen extends StatefulWidget {
  final int totalCoins;
  final int selectedCarIndex;

  const ShopScreen({
    Key? key,
    required this.totalCoins,
    required this.selectedCarIndex,
  }) : super(key: key);

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  late List<Map<String, dynamic>> cars;
  late int currentCoins;
  late int currentSelectedCar;

  @override
  void initState() {
    super.initState();
    // Copiar a lista de carros do GameConstants
    cars = [];
    for (int i = 0; i < GameConstants.cars.length; i++) {
      cars.add({
        'name': GameConstants.cars[i]['name'],
        'price': GameConstants.cars[i]['price'],
        'color': GameConstants.cars[i]['color'],
        'owned': GameConstants.cars[i]['owned'],
      });
    }
    currentCoins = widget.totalCoins;
    currentSelectedCar = widget.selectedCarIndex;
  }

  void _buyCar(int index) {
    final car = cars[index];
    final int price = car['price'] as int;
    
    if (car['owned'] == false && currentCoins >= price) {
      setState(() {
        // Compra o carro
        cars[index]['owned'] = true;
        currentCoins -= price;
        currentSelectedCar = index;
        
        // Atualiza o GameConstants global
        GameConstants.cars[index]['owned'] = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Você comprou ${car['name']}!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (car['owned'] == true) {
      setState(() {
        // Selecionar carro já comprado
        currentSelectedCar = index;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${car['name']} selecionado!'),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Moedas insuficientes! Precisa de $price moedas'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _confirmAndReturn() {
    // Retorna os dados para o menu
    Navigator.pop(context, {
      'coinsSpent': widget.totalCoins - currentCoins,
      'selectedCarIndex': currentSelectedCar,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loja de Carros 🚗'),
        backgroundColor: Colors.blue.shade900,
        actions: [
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, size: 20, color: Colors.black),
                const SizedBox(width: 5),
                Text(
                  '$currentCoins',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade900, Colors.black],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: cars.length,
                itemBuilder: (context, index) {
                  final car = cars[index];
                  final bool isOwned = car['owned'] as bool;
                  final bool isSelected = currentSelectedCar == index;
                  final int price = car['price'] as int;
                  final bool canBuy = currentCoins >= price && !isOwned;
                  
                  return Card(
                    elevation: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    color: isSelected ? Colors.blue.shade800 : Colors.grey.shade800,
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundColor: car['color'] as Color,
                        child: Text(
                          (car['name'] as String).split(' ')[0],
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      title: Text(
                        car['name'] as String,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: isOwned 
                          ? const Text('COMPRADO ✓', style: TextStyle(color: Colors.green))
                          : Text('💰 $price moedas', style: const TextStyle(color: Colors.amber)),
                      trailing: ElevatedButton(
                        onPressed: () => _buyCar(index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isOwned 
                              ? (isSelected ? Colors.green : Colors.blue)
                              : (canBuy ? Colors.amber : Colors.grey),
                          foregroundColor: isOwned ? Colors.white : Colors.black,
                        ),
                        child: Text(isOwned 
                            ? (isSelected ? '✓ USANDO' : 'USAR')
                            : (canBuy ? 'COMPRAR' : '$price 🪙')),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Botão voltar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                boxShadow: [
                  const BoxShadow(
                    color: Colors.black,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _confirmAndReturn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle),
                    SizedBox(width: 10),
                    Text('VOLTAR AO MENU'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}