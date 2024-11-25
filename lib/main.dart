import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase Core 패키지 import
import 'package:mobile/screens/login_screen.dart';
import 'firebase_options.dart'; // Firebase 옵션 파일 import
import 'screens/chart_screen.dart';
import 'screens/home_screen.dart';
import 'screens/goal_screen.dart';

void main() async {
  // Flutter 엔진 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 앱 실행
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/chart': (context) => ChartScreen(),
        '/goal': (context) => GoalScreen(),
      },
    );
  }
}
