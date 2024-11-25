import 'package:flutter/material.dart';
import 'screens/chart_screen.dart';
import 'screens/home_screen.dart';
import 'screens/goal_screen.dart';
import 'screens/mypage_screen.dart';
import 'screens/passwordreset_screen.dart'; // 비밀번호 재설정 화면 import

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/home': (context) => HomeScreen(),
        '/chart': (context) => ChartScreen(),
        '/goal': (context) => GoalScreen(),
        '/mypage': (context) => MyPageScreen(),
        '/passwordreset': (context) => PasswordResetScreen(), // 비밀번호 재설정 추가
      },
    );
  }
}