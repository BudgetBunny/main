import 'package:flutter/material.dart';
import 'chart_screen.dart';
import 'home_screen.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => GoalScreen(),
        '/goal': (context) => GoalScreen(),
        '/chart': (context) => ChartScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}

class GoalScreen extends StatefulWidget {
  @override
  _GoalScreenState createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  String _backgroundImage = 'assets/images/background_chart.png'; // 초기 배경 이미지

  // 목표 금액을 위한 controller와 focusNode
  final TextEditingController _goalAmountController = TextEditingController();
  final FocusNode _goalFocusNode = FocusNode();
  String _selectedTab = '관리';
  int _totalAmount = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Navigator에서 전달된 데이터를 받아옴
    final arguments = ModalRoute.of(context)?.settings.arguments as Map?;
    if (arguments != null) {
      setState(() {
        _totalAmount = arguments['totalAmount'] ?? 0;
      });
    }
  }

  @override
  void dispose() {
    _goalAmountController.dispose();
    _goalFocusNode.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('입력 오류'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                        offset: Offset(0, 3.5),
                        blurRadius: 5.0,
                        color: Colors.black38,
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
                        Navigator.pushNamed(context, '/mypage'); // 마이페이지로 이동
                      } else if (choice == '로그아웃') {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: Text('로그아웃'),
                            content: Text('정말 로그아웃하시겠습니까?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context), // 다이얼로그 닫기
                                child: Text('취소'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, '/', (route) => false); // 로그아웃 후 메인 화면으로 이동
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
              SizedBox(height: 40,),
              // 목표 금액 입력 필드 및 확인 버튼
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _goalAmountController,
                        focusNode: _goalFocusNode,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "목표 금액 설정",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 20,
                          ),
                        ),
                        style: TextStyle(fontSize: 30, color: Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        String goalAmount = _goalAmountController.text.trim();
                        if (goalAmount.isEmpty) {
                          _showErrorDialog('목표 금액을 입력해주세요.');
                        } else {
                          final numericValue = num.tryParse(goalAmount);
                          if (numericValue == null) {
                            _showErrorDialog('금액은 숫자만 입력 가능합니다.');
                          } else {
                            double enteredGoalAmount = numericValue.toDouble();

                            // 만원 단위 체크 (10000으로 나누어 떨어지는지 확인)
                            if (enteredGoalAmount % 10000 != 0) {
                              _showErrorDialog('목표 금액은 10000원 단위입니다.');
                            } else {
                              double difference = enteredGoalAmount - _totalAmount;
                              if (difference >= 0) {
                                setState(() {
                                  _backgroundImage = 'assets/images/goalSuccess.png';
                                });
                              } else {
                                setState(() {
                                  _backgroundImage = 'assets/images/goalFailed.png';
                                });
                              }
                              // 키보드를 내리기 위해 포커스를 해제합니다.
                              FocusScope.of(context).unfocus();
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: Colors.green,
                      ),
                      child: Text(
                        '확인',
                        style: TextStyle(fontSize: 30, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
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
