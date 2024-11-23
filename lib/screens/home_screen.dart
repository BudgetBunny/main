import 'package:flutter/material.dart';
import 'chart_screen.dart';
import 'goal_screen.dart';



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/chart': (context) => ChartScreen(), // chart 화면으로 이동
        '/home': (context) => HomeScreen(), // 입출금 화면으로 이동
        '/goal': (context) => GoalScreen(), // 목표 관리 화면으로 이동
      },
    );
  }
}
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  String _selectedTab = '입출금';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            // 배경 이미지
            Positioned.fill(
              child: Image.asset(
                'assets/images/homeScreen.png',
                fit: BoxFit.fitHeight,
              ),
            ),
            // 주요 UI
            Column(
              children: [
                SizedBox(height: 6.0),
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
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: Icon(Icons.menu, color: Color(0xFF676966)),
                      onPressed: () {},
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTabItem('통계', '/chart'),
                      _buildTabItem('입출금', '/home'), // 입출금 화면으로 연결
                      _buildTabItem('관리', '/goal'),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 7.0),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '이번달 목표 금액 ',
                            style: TextStyle(
                              color: Color(0xFF297E1C),
                              fontSize: 18,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              height: 3,
                              letterSpacing: -0.36,
                            ),
                          ),
                          TextSpan(
                            text: '500,000 ',
                            style: TextStyle(
                              color: Color(0xFF586556),
                              fontSize: 20,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              height: 0.07,
                              letterSpacing: -0.40,
                            ),
                          ),
                          TextSpan(
                            text: '원',
                            style: TextStyle(
                              color: Color(0xFF586556),
                              fontSize: 18,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              height: 0.09,
                              letterSpacing: -0.36,
                            ),
                          ),
                          TextSpan(
                            text: ' 까지\n',
                            style: TextStyle(
                              color: Color(0xFF297E1C),
                              fontSize: 18,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              height: 0.09,
                              letterSpacing: -0.36,
                            ),
                          ),
                          TextSpan(
                            text: '40,000 ',
                            style: TextStyle(
                              color: Color(0xFF297E1C),
                              fontSize: 19,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              height: 0.08,
                              letterSpacing: -0.38,
                            ),
                          ),
                          TextSpan(
                            text: '원 남았어요!',
                            style: TextStyle(
                              color: Color(0xFF297E1C),
                              fontSize: 19,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              height: 0.08,
                              letterSpacing: -0.38,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 70.0),
                  child: Column(
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '10월 총 소비\n',
                              style: TextStyle(
                                color: Color(0xFF676866),
                                fontSize: 20,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w400,
                                height: 4.5,
                                letterSpacing: -0.40,
                              ),
                            ),
                            TextSpan(
                              text: '-405000 원',
                              style: TextStyle(
                                color: Color(0xFF676866),
                                fontSize: 26,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w400,
                                height: 0.04,
                                letterSpacing: -0.52,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 80.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              SizedBox(
                                width: 84,
                                height: 25,
                                child: Text(
                                  '총 입금금액',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF676966),
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    height: 0.06,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 120,
                                height: 100,
                                child: TextButton(
                                  onPressed: () {
                                    print('입금금액 버튼 눌림');
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shape: CircleBorder(),
                                    padding: EdgeInsets.all(20),
                                  ),
                                  child: Text(
                                    '+450000',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                      height: 0.06,
                                      letterSpacing: -0.36,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 42),
                          Column(
                            children: [
                              SizedBox(
                                width: 83,
                                height: 25,
                                child: Text(
                                  '총 지출금액',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF676966),
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    height: 0.06,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 120,
                                height: 100,
                                child: TextButton(
                                  onPressed: () {
                                    print('지출금액 버튼 눌림');
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shape: CircleBorder(),
                                    padding: EdgeInsets.all(20),
                                  ),
                                  child: Text(
                                    '-855000',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                      height: 0.06,
                                      letterSpacing: -0.36,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Spacer(), // 화면 하단으로 버튼 배치
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0), // 하단 간격 조정
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '입출금 내역 확인',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF717476),
                          fontSize: 23,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 0,
                          letterSpacing: -1.15,
                        ),
                      ),
                      SizedBox(height: 10), // 텍스트와 버튼 간의 간격
                      Container(
                        width: 60,
                        height: 60,
                        padding: EdgeInsets.all(10), // 이미지 크기를 키우기 위한 패딩
                        clipBehavior: Clip.antiAlias,
                        decoration: ShapeDecoration(
                          shape: CircleBorder(),
                          color: Colors.transparent, // 배경색 (버튼 배경)
                        ),
                        child: InkWell(
                          onTap: () {
                            // 스크롤 애니메이션 실행
                            _scrollController.animateTo(
                              500, // 원하는 스크롤 위치
                              duration: Duration(seconds: 1), // 스크롤 속도
                              curve: Curves.ease, // 스크롤 애니메이션 커브
                            );
                          },
                          child: Image.asset(
                            'assets/icons/downBT.png', // 이미지 파일 경로
                            fit: BoxFit.cover, // 이미지가 버튼 크기에 맞게 꽉 차도록 설정
                          ),
                        ),
                      )


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

  // 탭 버튼 생성 함수
  Widget _buildTabItem(String label, String route) {
    bool isSelected = _selectedTab == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = label;
        });
        Navigator.pushNamed(context, route); // 클릭 시 화면 이동
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
}
