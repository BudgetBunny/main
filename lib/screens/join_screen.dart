import 'package:flutter/material.dart';
import 'login_screen.dart'; // 로그인 화면 import

class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _nicknameErrorMessage = "";
  String _idErrorMessage = "";
  String _passwordErrorMessage = "";

  void _validateAndSubmit() {
    setState(() {
      _nicknameErrorMessage = "";
      _idErrorMessage = "";
      _passwordErrorMessage = "";

      // 닉네임 필드 검사
      if (_nicknameController.text.isEmpty) {
        _nicknameErrorMessage = "닉네임을 입력해주세요.";
      }

      // 이메일 형식 검사
      _idErrorMessage = RegExp(
          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
          .hasMatch(_idController.text)
          ? ""
          : "아이디는 이메일 형식이어야 합니다.";

      // 비밀번호 길이 및 문자 포함 검사
      if (_passwordController.text.length < 8 ||
          _passwordController.text.length > 16 ||
          !_passwordController.text.contains(RegExp(r'[A-Za-z]'))) {
        _passwordErrorMessage = "비밀번호는 8~16자의 영문 대/소문자.";
      }

      // 모든 입력이 유효하면 회원가입 완료 메시지 출력 후 로그인 화면으로 이동
      if (_nicknameErrorMessage.isEmpty &&
          _idErrorMessage.isEmpty &&
          _passwordErrorMessage.isEmpty) {
        _showSignUpCompleteDialog();
      }
    });
  }

  void _showSignUpCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('회원가입 완료!'),
        content: const Text('회원가입이 성공적으로 완료되었습니다.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 다이얼로그 닫기
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              ); // 로그인 화면으로 이동
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: size.height * 0.12,
            right: size.width * 0.12,
            child: Image.asset(
              'assets/images/join.png',
              width: size.width * 0.9,
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '회원가입',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: size.width * 0.115,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: size.height * 0.05),
                  _buildTextFieldWithError(
                    context,
                    label: '닉네임',
                    controller: _nicknameController,
                    errorMessage: _nicknameErrorMessage,
                  ),
                  SizedBox(height: size.height * 0.03),
                  _buildTextFieldWithError(
                    context,
                    label: '아이디',
                    controller: _idController,
                    errorMessage: _idErrorMessage,
                  ),
                  SizedBox(height: size.height * 0.03),
                  _buildTextFieldWithError(
                    context,
                    label: '비밀번호',
                    controller: _passwordController,
                    obscureText: true,
                    errorMessage: _passwordErrorMessage,
                  ),
                  SizedBox(height: size.height * 0.05),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF20DBBF),
                        padding: EdgeInsets.symmetric(
                            vertical: size.height * 0.02),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      onPressed: _validateAndSubmit,
                      child: Text(
                        '회원가입 완료',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width * 0.05,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

  Widget _buildTextFieldWithError(BuildContext context, {
    required String label,
    required TextEditingController controller,
    required String errorMessage,
    bool obscureText = false,
  }) {
    final size = MediaQuery.of(context).size;

    // 닉네임 입력 필드만 가로폭 조정
    final isNicknameField = label == '닉네임';
    final fieldWidth = isNicknameField ? size.width * 0.5 : size.width * 0.7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.black,
                fontSize: size.width * 0.04,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(left: size.width * 0.03),
                child: Text(
                  errorMessage,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: size.width * 0.036,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: size.height * 0.01),
        SizedBox(
          width: fieldWidth, // 필드 너비를 조건에 따라 설정
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                vertical: size.height * 0.02,
                horizontal: size.width * 0.03,
              ),
            ),
          ),
        ),
      ],
    );
  }
}