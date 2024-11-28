import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlusScreen extends StatelessWidget {
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
                image: AssetImage('assets/images/plusInput.png'),
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
                    '입금 금액',
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
                        // 빈 값일 경우 AlertDialog로 에러 메시지 표시
                        _showErrorDialog(context, '금액을 입력해주세요!');
                        return;
                      }
                      int? amount = int.tryParse(enteredAmount);
                      if (amount == null || amount <= 0) {
                        // 숫자가 아니거나 0 이하일 경우 에러 메시지 표시
                        _showErrorDialog(context, '금액은 양의 숫자만 입력할 수 있습니다.');
                        return;
                      }

                      // Firebase에 금액 추가
                      try {
                        await _addAmountToFirestore(amount);
                        Navigator.pop(context, enteredAmount); // 입력 값을 전달하며 이전 화면으로 돌아감
                      } catch (e) {
                        _showErrorDialog(context, '데이터베이스 업데이트 중 오류가 발생했습니다.');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15), // 버튼 크기 조정
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.green, // 버튼 색상
                    ),
                    child: Text(
                      '입금하기',
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

  Future<void> _addAmountToFirestore(int amount) async {
    // 현재 사용자 가져오기
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("사용자가 로그인되어 있지 않습니다.");

    // Firestore 참조
    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

    // 트랜잭션으로 잔액 및 입금 금액 업데이트
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userDoc);

      if (!snapshot.exists) {
        // 문서가 없는 경우 새 문서 생성
        transaction.set(userDoc, {
          'account_balance': amount, // 총 금액 초기화
          'plus_account': amount, // 첫 입금 금액 저장
        });
      } else {
        // 기존 잔액과 입금 금액 가져오기
        final currentBalance = snapshot.data()?['account_balance'] ?? 0;
        final currentPlusAccount = snapshot.data()?['plus_account'] ?? 0;

        transaction.update(userDoc, {
          'account_balance': currentBalance + amount, // 총 금액 업데이트
          'plus_account': currentPlusAccount + amount, // 기존 입금 금액에 새 금액 추가
        });
      }
    });
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('입력 오류'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }
}