import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NicknameResetScreen extends StatefulWidget {
  const NicknameResetScreen({super.key});

  @override
  State<NicknameResetScreen> createState() => _NicknameResetScreenState();
}

class _NicknameResetScreenState extends State<NicknameResetScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  String _nicknameErrorMessage = "";

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _validateAndChangeNickname() async {
    setState(() {
      _nicknameErrorMessage = "";
    });

    if (_nicknameController.text.isEmpty) {
      setState(() {
        _nicknameErrorMessage = "닉네임을 입력해주세요.";
      });
      return;
    }

    if (_nicknameController.text.length < 3 || _nicknameController.text.length > 12) {
      setState(() {
        _nicknameErrorMessage = "닉네임은 3~12자 사이여야 합니다.";
      });
      return;
    }

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception("로그인된 사용자가 없습니다.");
      }

      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

      await docRef.update({
        'nickname': _nicknameController.text,
      });

      setState(() {
        _nicknameController.clear();
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('성공'),
          content: const Text('닉네임이 성공적으로 변경되었습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫기
                Navigator.pop(context); // 마이페이지로 이동
              },
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('오류'),
          content: Text('닉네임 변경 중 오류가 발생했습니다: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/background_chart.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
                  child: Column(
                    children: [
                      AppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        title: const Text(
                          'BudgetBunny',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF676966),
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
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
                        automaticallyImplyLeading: true,
                      ),
                      SizedBox(height: size.height * 0.02),
                      Text(
                        '닉네임 재설정',
                        style: TextStyle(
                          fontSize: size.width * 0.07,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Divider(
                        color: Colors.white,
                        thickness: 1.3,
                        indent: size.width * 0.05,
                        endIndent: size.width * 0.05,
                        height: size.height * 0.06,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '새 닉네임 입력',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: size.width * 0.045,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: size.height * 0.01),
                              TextField(
                                controller: _nicknameController,
                                decoration: InputDecoration(
                                  hintText: '새 닉네임',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              if (_nicknameErrorMessage.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(top: size.height * 0.01),
                                  child: Text(
                                    _nicknameErrorMessage,
                                    style: TextStyle(
                                      fontSize: size.width * 0.035,
                                      color: Colors.red,
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
              ),
              Positioned(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 0,
                right: 0,
                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF20DCC0),
                      padding: EdgeInsets.symmetric(
                        vertical: size.height * 0.02,
                        horizontal: size.width * 0.25,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _validateAndChangeNickname,
                    child: Text(
                      '닉네임 재설정',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size.width * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}