import 'package:flutter/material.dart';

import 'screens/simulator_screen.dart';

void main() {
  runApp(const RectifierApp());
}

class RectifierApp extends StatelessWidget {
  const RectifierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Half-Wave Rectifier Simulator',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),

      home: const SimulatorScreen(),
    );
  }
}
