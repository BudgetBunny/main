import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

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
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _validateAndSubmit() async {
    setState(() {
      _nicknameErrorMessage = "";
      _idErrorMessage = "";
      _passwordErrorMessage = "";
    });

    bool hasError = false;

    // Nickname validation
    if (_nicknameController.text.isEmpty) {
      setState(() {
        _nicknameErrorMessage = "닉네임을 입력해주세요.";
      });
      hasError = true;
    } else if (
    _nicknameController.text.length > 10) {
      setState(() {
        _nicknameErrorMessage = "닉네임은 10자 이하로 입력해주세요.";
      });
      hasError = true;
    }

    // Email format validation
    if (_idController.text.isEmpty) {
      setState(() {
        _idErrorMessage = "아이디를 입력해주세요.";
      });
      hasError = true;
    } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(_idController.text)) {
      setState(() {
        _idErrorMessage = "아이디는 이메일 형식이어야 합니다.";
      });
      hasError = true;
    }

    // Password validation
    if (_passwordController.text.isEmpty) {
      setState(() {
        _passwordErrorMessage = "비밀번호를 입력해주세요.";
      });
      hasError = true;
    } else if (_passwordController.text.length < 8 ||
        _passwordController.text.length > 16 ||
        !_passwordController.text.contains(RegExp(r'[A-Za-z]'))) {
      setState(() {
        _passwordErrorMessage = "비밀번호는 8~16자의 영문 대/소문자를 포함해야 합니다.";
      });
      hasError = true;
    }

    // Stop if there are validation errors
    if (hasError) return;

    try {
      setState(() {
        _isLoading = true;
      });

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _idController.text,
        password: _passwordController.text,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'nickname': _nicknameController.text,
        'email': _idController.text,
      });

      setState(() {
        _isLoading = false;
      });

      _showSignUpCompleteDialog();
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
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
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
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
            onPressed: () => Navigator.pop(context),
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
                    fieldWidth: size.width * 0.5,
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
        double? fieldWidth,
      }) {
    final size = MediaQuery.of(context).size;

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
          width: fieldWidth ?? size.width * 0.8,
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