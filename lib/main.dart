import 'package:flutter/material.dart';
import 'screens/chart_screen.dart';
import 'screens/home_screen.dart';
import 'screens/goal_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/home': (context) => HomeScreen(),
        '/chart': (context) => ChartScreen(),
        '/goal': (context) => GoalScreen(),
      },
    );
  }
}
