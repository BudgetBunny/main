import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth import
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
  bool _isLoading = false; // 로딩 상태 추가

  // Firebase Auth 인스턴스
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _validateAndSubmit() async {
    setState(() {
      _nicknameErrorMessage = "";
      _idErrorMessage = "";
      _passwordErrorMessage = "";
    });

    // 닉네임 검사
    if (_nicknameController.text.isEmpty) {
      setState(() {
        _nicknameErrorMessage = "닉네임을 입력해주세요.";
      });
      return;
    }

    // 이메일 형식 검사
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(_idController.text)) {
      setState(() {
        _idErrorMessage = "아이디는 이메일 형식이어야 합니다.";
      });
      return;
    }

    // 비밀번호 검사
    if (_passwordController.text.length < 8 ||
        _passwordController.text.length > 16 ||
        !_passwordController.text.contains(RegExp(r'[A-Za-z]'))) {
      setState(() {
        _passwordErrorMessage = "비밀번호는 8~16자의 영문 대/소문자.";
      });
      return;
    }

    // Firebase에 회원가입 처리
    try {
      setState(() {
        _isLoading = true; // 로딩 상태 시작
      });

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _idController.text,
        password: _passwordController.text,
      );

      // Firestore에 닉네임 저장
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'nickname': _nicknameController.text,
        'email': _idController.text,
      });

      // 사용자 추가 데이터 (닉네임 등) Firebase Firestore나 Realtime Database에 저장 가능

      setState(() {
        _isLoading = false; // 로딩 상태 종료
      });

      _showSignUpCompleteDialog();
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false; // 로딩 상태 종료
      });

      String errorMessage;
      if (e.code == 'email-already-in-use') {
        errorMessage = "이미 사용 중인 이메일입니다.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "유효하지 않은 이메일 형식입니다.";
      } else if (e.code == 'weak-password') {
        errorMessage = "비밀번호가 너무 약합니다.";
      } else {
        errorMessage = "회원가입 중 오류가 발생했습니다.";
      }

      _showErrorDialog(errorMessage);
    }
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // 다이얼로그 닫기
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
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
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

  Widget _buildTextFieldWithError(
      BuildContext context, {
        required String label,
        required TextEditingController controller,
        required String errorMessage,
        bool obscureText = false,
      }) {
    final size = MediaQuery.of(context).size;

    final fieldWidth = size.width * 0.8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            padding: EdgeInsets.only(top: 5),
            child: Text(
              errorMessage,
              style: TextStyle(
                color: Colors.red,
                fontSize: size.width * 0.036,
              ),
            ),
          ),
        SizedBox(height: size.height * 0.01),
        SizedBox(
          width: fieldWidth,
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