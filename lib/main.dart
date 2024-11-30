import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase Core 패키지 import
import 'package:mobile/screens/login_screen.dart';
import 'firebase_options.dart'; // Firebase 옵션 파일 import
import 'screens/chart_screen.dart';
import 'screens/home_screen.dart';
import 'screens/goal_screen.dart';
import 'screens/mypage_screen.dart';
import 'screens/passwordreset_screen.dart';
import 'screens/plus_screen.dart';
import 'screens/minus_screen.dart';

void main() async {
  // Flutter 엔진 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp();

  // 앱 실행
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/chart': (context) => ChartScreen(),
        '/goal': (context) => GoalScreen(),
        '/mypage': (context) => MyPageScreen(),
        '/passwordreset': (context) => PasswordResetScreen(), // 비밀번호 재설정 추가
        '/plus': (context) => PlusScreen(),
        '/minus': (context) => MinusScreen(),
      },
    );
  }
}