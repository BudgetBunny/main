import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 사용을 위한 import
import 'package:firebase_auth/firebase_auth.dart'; // 사용자 인증

class MinusScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 배경 이미지
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/minusInput.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // 중앙에 텍스트 입력 필드 배치
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min, // 자식 위젯 높이만큼만 공간 사용
                children: [
                  Text(
                    '지출 금액',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20), // 텍스트와 입력 필드 간 간격
                  TextField(
                    controller: _controller, // 입력한 값을 가져오기 위해 컨트롤러 사용
                    keyboardType: TextInputType.number, // 숫자 입력 전용 키보드
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white, // 입력 필드 배경색
                      hintText: '금액 입력',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none, // 테두리 제거
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20,
                      ),
                    ),
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  SizedBox(height: 30), // 입력 필드와 버튼 간 간격
                  ElevatedButton(
                    onPressed: () async {
                      String enteredAmount = _controller.text; // 입력한 값 가져오기
                      if (enteredAmount.isEmpty) {
                        _showErrorDialog(context, '입력 오류', '금액을 입력해주세요!');
                      } else if (int.tryParse(enteredAmount) == null) {
                        _showErrorDialog(context, '입력 오류', '금액은 숫자만 입력할 수 있습니다.');
                      } else {
                        // Firestore에 업데이트
                        await _subtractExpense(context, int.parse(enteredAmount));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15), // 버튼 크기 조정
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.red, // 버튼 색상
                    ),
                    child: Text(
                      '지출하기',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

// Firestore에서 금액 차감
  Future<void> _subtractExpense(BuildContext context, int expenseAmount) async {
    try {
      // 현재 사용자 가져오기
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorDialog(context, '오류', '로그인된 사용자가 없습니다.');
        return;
      }

      // Firestore에서 사용자 문서 참조
      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

      // 트랜잭션으로 account_balance 및 minus_account 업데이트
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists || snapshot.data() == null) {
          _showErrorDialog(context, '오류', '잔액 정보가 없습니다.');
          return;
        }

        // 현재 잔액 및 기존 minus_account 값 가져오기
        int currentBalance = snapshot['account_balance'] ?? 0;
        int currentMinusAccount = snapshot['minus_account'] ?? 0;

        if (currentBalance < expenseAmount) {
          // 잔액 부족 에러 처리
          _showErrorDialog(context, '잔액 부족', '잔액이 부족합니다. 현재 잔액: $currentBalance원');
          return;
        }

        // 잔액 차감 및 minus_account 값 누적 업데이트
        transaction.update(docRef, {
          'account_balance': currentBalance - expenseAmount, // 총 금액 업데이트
          'minus_account': currentMinusAccount + expenseAmount, // 기존 지출 금액에 새 금액 추가
        });
      });

      // 성공 후 컨트롤러 초기화 및 홈 화면으로 이동
      _controller.clear();
      Navigator.pushReplacementNamed(context, '/home'); // 홈 화면으로 이동
    } catch (e) {
      // 오류 처리
      _showErrorDialog(context, '오류', '지출을 처리하는 중 문제가 발생했습니다: $e');
    }
  }

  // 오류 메시지 표시
  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }
}