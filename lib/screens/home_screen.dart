import 'package:flutter/material.dart';
import 'chart_screen.dart';
import 'goal_screen.dart';
import 'plus_screen.dart';
import 'minus_screen.dart';


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
        '/plus': (context) => PlusScreen(),
        '/minus': (context) => MinusScreen(),
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
  int _totalPlusAmount = 0;
  int _totalMinusAmount = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
                    PopupMenuButton<String>(
                      icon: Icon(Icons.menu, color: Color(0xFF676966)),
                      onSelected: (String choice) {
                        if (choice == '마이페이지') {
                          Navigator.pushNamed(context, '/mypage');
                        } else if (choice == '로그아웃') {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: Text('로그아웃'),
                              content: Text('정말 로그아웃하시겠습니까?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('취소'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamedAndRemoveUntil(
                                        context, '/', (route) => false);
                                  },
                                  child: Text('확인'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return {'마이페이지', '로그아웃'}.map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice),
                          );
                        }).toList();
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 17.0),
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
                    padding: const EdgeInsets.only(top: 10.0),
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
                              text: '${_totalPlusAmount - _totalMinusAmount} 원',
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
                                  onPressed: () async {
                                    final plusResult = await Navigator.pushNamed(context, '/plus');
                                    if (plusResult != null) {
                                      setState(() {
                                        _totalPlusAmount += int.tryParse(plusResult as String) ?? 0;
                                      });
                                    }
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shape: CircleBorder(),
                                    padding: EdgeInsets.all(10),
                                  ),
                                  child: FittedBox( // 텍스트가 넘치지 않도록 자동으로 크기 조정
                                    fit: BoxFit.scaleDown, // 텍스트 크기를 자동으로 줄여줌
                                    child: Text(
                                      '+$_totalPlusAmount 원', // 총 입금 금액 표시
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                        height: 1, // 텍스트의 높이
                                        letterSpacing: -0.36,
                                      ),
                                    ),
                                  ),
                                ),
                              )
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
                                  onPressed: () async {
                                    final minusResult = await Navigator.pushNamed(context, '/minus');
                                    if (minusResult != null) {
                                      setState(() {
                                        _totalMinusAmount += int.tryParse(minusResult as String) ?? 0;
                                      });
                                    }
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shape: CircleBorder(),
                                    padding: EdgeInsets.all(10),
                                  ),
                                  child: FittedBox( // 텍스트가 넘치지 않도록 자동으로 크기 조정
                                    fit: BoxFit.scaleDown, // 텍스트 크기를 자동으로 줄여줌
                                    child: Text(
                                      '-$_totalMinusAmount 원', // 총 입금 금액 표시
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                        height: 1, // 텍스트의 높이
                                        letterSpacing: -0.36,
                                      ),
                                    ),
                                  ),
                                ),
                              )
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