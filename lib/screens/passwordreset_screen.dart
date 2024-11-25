import 'package:flutter/material.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final TextEditingController _passwordController = TextEditingController();
  String _passwordErrorMessage = "";

  void _validatePassword() {
    setState(() {
      if (_passwordController.text.length < 8 ||
          _passwordController.text.length > 16 ||
          !_passwordController.text.contains(RegExp(r'[A-Za-z]'))) {
        _passwordErrorMessage = "비밀번호는 8~16자의 영문 대/소문자.";
      } else {
        _passwordErrorMessage = "";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_chart.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // 상단 AppBar와 타이틀
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                'BudgetBunny',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF676966),
                  fontSize: 22,
                  fontFamily: 'Roboto',
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
            // 마이페이지 타이틀
            Text(
              '마이페이지',
              style: TextStyle(
                fontSize: size.width * 0.06,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Divider(
              color: Colors.white,
              thickness: 1.3,
              indent: size.width * 0.05,
              endIndent: size.width * 0.05,
              height: size.height * 0.04,
            ),
            SizedBox(height: size.height * 0.04),
            // 비밀번호 재설정 입력 필드
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
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
                      controller: _passwordController,
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
                    if (_passwordErrorMessage.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: size.height * 0.01),
                        child: Text(
                          _passwordErrorMessage,
                          style: TextStyle(
                            fontSize: size.width * 0.035,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    SizedBox(height: size.height * 0.05),
                    // 비밀번호 재설정 버튼
                    Center(
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
                        onPressed: _validatePassword,
                        child: Text(
                          '비밀번호 재설정',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * 0.045,
                            fontWeight: FontWeight.bold,
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
      ),
    );
  }
}