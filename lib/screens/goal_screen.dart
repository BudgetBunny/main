import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ScrollController _scrollController = ScrollController();
  String _selectedTab = '입출금';
  int _count = 0; // 카운트 변수
  String _backgroundImage = 'assets/images/goalSuccess.png'; // 초기 배경 이미지

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            // 배경 이미지
            Positioned.fill(
              child: Image.asset(
                _backgroundImage,
                fit: BoxFit.cover,
              ),
            ),
            // 주요 UI
            Column(
              children: [
                SizedBox(height: 6.0),
                // 투명 AppBar
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Text(
                    'BudgetBunny',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF676966),
                      fontSize: 22,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      height: 0.06,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 3.5), // 그림자의 x, y 위치
                          blurRadius: 5.0,          // 그림자의 흐림 정도
                          color: Colors.black38,    // 그림자의 색상
                        ),
                      ],
                    ),
                  ),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      icon: Icon(Icons.menu, color: Color(0xFF676966)),
                      onPressed: () {},
                    ),
                  ],
                ),
                // Tab 메뉴
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTabItem('통계'),
                      _buildTabItem('입출금'),
                      _buildTabItem('관리'),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                '현재 카운트: $_count',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _incrementCounter,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.yellow,
                                ),
                                child: Text(
                                  '카운트 증가',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: _decrementCounter,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.yellow,
                                ),
                                child: Text(
                                  '카운트 감소',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String label) {
    bool isSelected = _selectedTab == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = label;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 3.0,
              color: isSelected ? Colors.white : Colors.transparent,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _incrementCounter() {
    setState(() {
      _count++;
      if (_count > 5) {
        _backgroundImage = 'assets/images/goalFailed.png'; // 배경 이미지 변경
      }
    });
  }
  void _decrementCounter() {
    setState(() {
      _count--;
      if (_count <=5) {
        _backgroundImage = 'assets/images/goalSuccess.png'; // 배경 이미지 변경
      }
    });
  }
}
