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
// This is a basic Flutter application that serves as the entry point for a 2D car game. It defines a `CarGameApp` widget that sets up the MaterialApp with a dark theme and specifies the `MenuScreen` as the home screen. The debug banner is also disabled for a cleaner look.