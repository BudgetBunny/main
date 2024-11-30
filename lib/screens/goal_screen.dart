import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GoalScreen extends StatefulWidget {
  @override
  _GoalScreenState createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  String _backgroundImage = 'assets/images/background_chart.png'; // 초기 배경 이미지
  final TextEditingController _goalAmountController = TextEditingController();
  final FocusNode _goalFocusNode = FocusNode();
  String _selectedTab = '관리';
  int _minusAmount = 0;
  int? _goalAmount; // Firestore에서 가져온 목표 금액
  bool _isResettingGoal = false; // 목표 금액 재설정 상태 여부

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchDataAndUpdateBackground();
  }

  Future<void> _fetchDataAndUpdateBackground() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final data = userDoc.data();

      if (data != null) {
        setState(() {
          _minusAmount = data['minus_account'] ?? 0;
          _goalAmount = data['goal_amount'];

          // 목표 금액이 있을 경우 성공/실패 여부를 판단
          if (_goalAmount != null) {
            if (_minusAmount > _goalAmount!) {
              _backgroundImage = 'assets/images/goalFailed.png'; // 목표 초과 -> 실패
            } else {
              _backgroundImage = 'assets/images/goalSuccess.png'; // 목표 이하 -> 성공
            }
          }
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> _setGoalAmount(int goalAmount) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) return;

    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'goal_amount': goalAmount,
    }, SetOptions(merge: true));

    setState(() {
      _isResettingGoal = false; // 설정 완료 후 재설정 상태 해제
    });

    // 목표 금액 설정 후 성공/실패 여부를 검사
    _fetchDataAndUpdateBackground();
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
                    _buildTabItem('입출금', '/home'),
                    _buildTabItem('관리', '/goal'),
                  ],
                ),
              ),
              SizedBox(height: 40),
              if (_isResettingGoal)
                _buildGoalResetUI()
              else
                _buildGoalManagementUI(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalResetUI() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
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
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            flex:1,
            child: ElevatedButton(
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

                    if (enteredGoalAmount % 10000 != 0) {
                      _showErrorDialog('목표 금액은 10000원 단위입니다.');
                    } else {
                      _setGoalAmount(enteredGoalAmount.toInt());
                      FocusScope.of(context).unfocus();
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: Color(0xff87C5AA),
              ),
              child: Text(
                '설정',
                style: TextStyle(fontSize: 22, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalManagementUI() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16.0), // 내부 여백
            decoration: BoxDecoration(
              color: Colors.white, // 배경색
              borderRadius: BorderRadius.circular(15), // 둥근 모서리
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // 그림자의 방향
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // 내부 콘텐츠 정렬
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isResettingGoal = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff87C5AA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      '목표 금액 재설정',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '목표 소비 금액',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${_goalAmount ?? 0}원',
                        style: TextStyle(fontSize: 24, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: Text(
              _goalAmount == null
                  ? '목표 금액이 설정되지 않았습니다.'
                  : (_minusAmount > _goalAmount!
                  ? '초과 금액 : ${(_minusAmount - _goalAmount!)}원'
                  : '남은 금액 : ${_goalAmount! - _minusAmount}원'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: (_goalAmount != null && _minusAmount > _goalAmount!)
                    ? Color(0xffD35656) // 목표 금액 초과 -> 붉은색
                    : Color(0xff2A7F1D), // 목표 금액 이하 -> 초록색
                fontSize: 21,
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                height: 1.2,
                letterSpacing: -0.42,
              ),
            ),
          ),
          SizedBox(height: 20),
          // 진행 정도 막대 그래프
          if (_goalAmount != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Stack(
                children: [
                  // 배경 막대
                  Container(
                    height: 40,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  // 진행 상태에 맞춰 채워진 초록색 막대
                  FractionallySizedBox(
                    widthFactor: (_goalAmount! > 0)
                        ? (_minusAmount / _goalAmount!).clamp(0, 1)
                        : 0,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: (_minusAmount > _goalAmount!)
                            ? Color(0xffD35656) // 목표 금액 초과 -> 붉은색
                            : Color(0xff7DDAB5), // 목표 금액 이하 -> 초록색
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Align(
                        alignment: Alignment.centerRight, // 오른쪽 정렬
                        child: Padding(
                          padding: EdgeInsets.only(right: 8.0), // 오른쪽 여백
                          child: Text(
                            '$_minusAmount원',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 5),
          // 목표 금액 텍스트 (0원 ~ 목표 금액)
          if (_goalAmount != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '0',
                    style: TextStyle(
                      fontSize: 16,
                      color: (_minusAmount > _goalAmount!) ? Colors.white : Colors.black, // 목표 초과 시 하얀색
                    ),
                  ),
                  Text(
                    '${_goalAmount!}',
                    style: TextStyle(
                      fontSize: 16,
                      color: (_minusAmount > _goalAmount!) ? Colors.white : Colors.black, // 목표 초과 시 하얀색
                    ),
                  ),
                ],
              ),
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
        Navigator.pushNamed(context, route);
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
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
