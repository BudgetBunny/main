import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // TextInputFormatter 사용을 위한 import

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
                    onPressed: () {
                      String enteredAmount = _controller.text; // 입력한 값 가져오기
                      if (enteredAmount.isEmpty) {
                        // 빈 값일 경우 AlertDialog로 에러 메시지 표시
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('입력 오류'),
                              content: Text('금액을 입력해주세요!'),
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
                      } else if (int.tryParse(enteredAmount) == null) {
                        // 숫자가 아닐 경우 AlertDialog로 에러 메시지 표시
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('입력 오류'),
                              content: Text('금액은 숫자만 입력할 수 있습니다.'),
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
                      } else {
                        Navigator.pop(context, enteredAmount); // 입력 값을 전달하며 이전 화면으로 돌아감
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
}
