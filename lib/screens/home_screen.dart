import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chart_screen.dart';
import 'goal_screen.dart';
import 'plus_screen.dart';
import 'minus_screen.dart';
import 'PMLog_screen.dart';



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

String _getMonthName(int month) {
  const monthNames = [
    '1월', '2월', '3월', '4월', '5월', '6월',
    '7월', '8월', '9월', '10월', '11월', '12월'
  ];
  return monthNames[month - 2];
}
class _HomeScreenState extends State<HomeScreen> {
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
                  child: FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser?.uid)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator()); // 로딩 표시
                      }
                      if (snapshot.hasData && snapshot.data != null) {
                        // Safely handle missing data with default values
                        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                        final remainingBalance = data['account_balance'] ?? 0; // 잔액 가져오기, 없으면 0
                        final currentMonth = DateTime.now().month; // 현재 월 가져오기
                        final monthName = _getMonthName(currentMonth); // 월 이름 변환 함수 호출

                        return Column(
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${monthName} 남은 잔액\n', // 이번 달 이름 표시
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
                                    text: '$remainingBalance 원', // 남은 잔액 표시
                                    style: TextStyle(
                                      color: Color(0xFF297E1C), // 초록색 텍스트
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
                        );
                      }
                      return Text(
                        '오류 발생',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
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
                                  child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                    future: FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(FirebaseAuth.instance.currentUser?.uid)
                                        .get(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return CircularProgressIndicator();
                                      }
                                      if (snapshot.hasData && snapshot.data != null) {
                                        final data = snapshot.data!.data();
                                        final plusAccount = data?['plus_account'] ?? 0;
                                        return FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            '+$plusAccount 원',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                              height: 1,
                                              letterSpacing: -0.36,
                                            ),
                                          ),
                                        );
                                      }
                                      return Text(
                                        'Error',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
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
                                  child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                    future: FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(FirebaseAuth.instance.currentUser?.uid)
                                        .get(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return CircularProgressIndicator();
                                      }
                                      if (snapshot.hasData && snapshot.data != null) {
                                        final data = snapshot.data!.data();
                                        final minusAccount = data?['minus_account'] ?? 0;
                                        return FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            '-$minusAccount 원',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                              height: 1,
                                              letterSpacing: -0.36,
                                            ),
                                          ),
                                        );
                                      }
                                      return Text(
                                        'Error',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PMLogScreen(), // 이동할 화면
                              ),
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

        // /goal 경로일 때만 arguments 전달
        if (route == '/goal') {
          Navigator.pushNamed(
            context,
            '/goal',
            arguments: {
              'totalAmount': _totalPlusAmount - _totalMinusAmount,
            },
          );
        } else {
          Navigator.pushNamed(context, route); // 다른 경로로 이동
        }
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