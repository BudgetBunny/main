import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile/screens/login_screen.dart';
import 'firebase_options.dart';
import 'screens/chart_screen.dart';
import 'screens/home_screen.dart';
import 'screens/goal_screen.dart';
import 'screens/mypage_screen.dart';
import 'screens/passwordreset_screen.dart';
import 'screens/plus_screen.dart';
import 'screens/minus_screen.dart';
import 'screens/first_screen.dart'; // FirstScreen import 추가

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/first', // 첫 화면을 FirstScreen으로 설정
      routes: {
        '/first': (context) => FirstScreen(), // FirstScreen 추가
        '/': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/chart': (context) => ChartScreen(),
        '/goal': (context) => GoalScreen(),
        '/mypage': (context) => MyPageScreen(),
        '/passwordreset': (context) => PasswordResetScreen(),
        '/plus': (context) => PlusScreen(),
        '/minus': (context) => MinusScreen(),
      },
    );
  }
}
