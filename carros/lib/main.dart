import 'package:carros/widgets/menu_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(const CarGameApp());

class CarGameApp extends StatelessWidget {
  const CarGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Game 2D',
      theme: ThemeData.dark(),
      home: const MenuScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}