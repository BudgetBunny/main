import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth import
import 'join_screen.dart'; // 회원가입 화면 import

void main() {
  runApp(const LoginApp());
}

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = "";

  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth 인스턴스

  void _login() async {
    String id = _idController.text.trim();
    String password = _passwordController.text.trim();

    if (id.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = "아이디와 비밀번호를 입력해주세요.";
      });
    } else {
      setState(() {
        _errorMessage = "";
      });

      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: id,
          password: password,
        );
        // 로그인 성공
        _showSuccessDialog(userCredential.user?.email ?? "사용자");
      } on FirebaseAuthException catch (e) {
        // Firebase 인증 에러 처리
        if (e.code == 'user-not-found') {
          setState(() {
            _errorMessage = "존재하지 않는 사용자입니다.";
          });
        } else if (e.code == 'wrong-password') {
          setState(() {
            _errorMessage = "비밀번호가 틀렸습니다.";
          });
        } else {
          setState(() {
            _errorMessage = "로그인 중 오류가 발생했습니다: ${e.message}";
          });
        }
      }
    }
  }

  void _showSuccessDialog(String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그인 성공'),
        content: Text('환영합니다, $userId님!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 팝업 닫기
              // 홈 화면으로 이동 (이곳에 실제 홈 화면을 연결해야 함)
              Navigator.pushReplacementNamed(context, '/home');
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _goToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const JoinScreen()), // 회원가입 페이지로 이동
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
            top: size.height * -0.25,
            right: size.width * -0.85,
            child: Image.asset(
              'assets/images/background_curve.png',
              width: size.width * 1.2,
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.145),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '로그인',
                    style: TextStyle(
                      fontSize: size.width * 0.115,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: size.height * 0.05),
                  _buildLabel('아이디', size),
                  _buildTextField(size, controller: _idController, obscureText: false),
                  SizedBox(height: size.height * 0.03),
                  _buildLabel('비밀번호', size),
                  _buildTextField(size, controller: _passwordController, obscureText: true),
                  // 간격 추가
                  SizedBox(height: size.height * 0.06),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                      child: Center(
                        child: Text(
                          _errorMessage,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: size.width * 0.035,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF20DCC0),
                        padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _login,
                      child: Text(
                        '로그인',
                        style: TextStyle(
                          fontSize: size.width * 0.05,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.05),
                  Center(
                    child: GestureDetector(
                      onTap: _goToSignUp,
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: '처음 오셨나요?\n',
                          style: TextStyle(
                            fontSize: size.width * 0.035,
                            color: Colors.grey,
                          ),
                          children: [
                            TextSpan(
                              text: '회원가입',
                              style: TextStyle(
                                fontSize: size.width * 0.04,
                                color: Colors.purple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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

  Widget _buildLabel(String label, Size size) {
    return Text(
      label,
      style: TextStyle(
        fontSize: size.width * 0.04,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTextField(
      Size size, {
        required TextEditingController controller,
        required bool obscureText,
      }) {
    return SizedBox(
      width: size.width * 0.8,
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
    );
  }
}