import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MinusScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/minusInput.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '출금 금액',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: '금액 입력',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    ),
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      String enteredAmount = _controller.text;
                      if (enteredAmount.isEmpty) {
                        _showErrorDialog(context, '금액을 입력해주세요!');
                        return;
                      }
                      int? amount = int.tryParse(enteredAmount);
                      if (amount == null || amount <= 0) {
                        _showErrorDialog(context, '금액은 양의 숫자만 입력할 수 있습니다.');
                        return;
                      }

                      try {
                        await _addTransaction(amount, "withdrawal");
                        Navigator.pop(context, enteredAmount);
                      } catch (e) {
                        _showErrorDialog(context, '데이터베이스 업데이트 중 오류가 발생했습니다.');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.red,
                    ),
                    child: Text('출금하기', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addTransaction(int amount, String type) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("사용자가 로그인되어 있지 않습니다.");

    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userDoc);

      if (!snapshot.exists) {
        throw Exception("사용자의 데이터가 존재하지 않습니다.");
      } else {
        final data = snapshot.data()!;
        final currentBalance = data['account_balance'] ?? 0;
        final currentMinusAccount = data['minus_account'] ?? 0;
        if (currentBalance < amount) {
          throw Exception("잔액이 부족합니다.");
        }

        transaction.update(userDoc, {
          'account_balance': currentBalance - amount, // 총 금액 차감
          'minus_account': currentMinusAccount + amount, // 기존 지출 금액에 새 금액 추가
        });
      }

      final transactionsCollection =
      FirebaseFirestore.instance.collection('transactions');
      await transactionsCollection.add({
        'userId': user.uid,
        'amount': amount,
        'type': type,
        'timestamp': FieldValue.serverTimestamp(),
      });
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
                Navigator.of(context).pop();
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }
}
