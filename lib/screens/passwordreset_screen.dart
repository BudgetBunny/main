import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  String _currentPasswordErrorMessage = "";
  String _newPasswordErrorMessage = "";

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _validateAndChangePassword() async {
    setState(() {
      _currentPasswordErrorMessage = "";
      _newPasswordErrorMessage = "";
    });

    if (_currentPasswordController.text.isEmpty) {
      setState(() {
        _currentPasswordErrorMessage = "현재 비밀번호를 입력해주세요.";
      });
      return;
    }

    if (_newPasswordController.text.length < 8 ||
        _newPasswordController.text.length > 16 ||
        !_newPasswordController.text.contains(RegExp(r'[A-Za-z]'))) {
      setState(() {
        _newPasswordErrorMessage = "비밀번호는 8~16자의 영문 대/소문자와 숫자를 포함해야 합니다.";
      });
      return;
    }

    try {
      final user = _auth.currentUser!;
      final email = user.email!;

      final credential = EmailAuthProvider.credential(
        email: email,
        password: _currentPasswordController.text,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(_newPasswordController.text);

      setState(() {
        _currentPasswordController.clear();
        _newPasswordController.clear();
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('성공'),
          content: const Text('비밀번호가 성공적으로 변경되었습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        setState(() {
          _currentPasswordErrorMessage = "현재 비밀번호가 잘못되었습니다.";
        });
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('오류'),
            content: Text('오류가 발생했습니다: ${e.message}'),
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
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false, // 키보드로 인한 레이아웃 변화 방지
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
                        '비밀번호 재설정',
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
                                '현재 비밀번호 입력',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: size.width * 0.045,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: size.height * 0.01),
                              TextField(
                                controller: _currentPasswordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: '현재 비밀번호',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              if (_currentPasswordErrorMessage.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(top: size.height * 0.01),
                                  child: Text(
                                    _currentPasswordErrorMessage,
                                    style: TextStyle(
                                      fontSize: size.width * 0.035,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              SizedBox(height: size.height * 0.03),
                              Text(
                                '새 비밀번호 입력',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: size.width * 0.045,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: size.height * 0.01),
                              TextField(
                                controller: _newPasswordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: '새 비밀번호',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              if (_newPasswordErrorMessage.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(top: size.height * 0.01),
                                  child: Text(
                                    _newPasswordErrorMessage,
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
                bottom: MediaQuery.of(context).viewInsets.bottom + 20, // 키보드 높이 반영
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
                    onPressed: _validateAndChangePassword,
                    child: Text(
                      '비밀번호 재설정',
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