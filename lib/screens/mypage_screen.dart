import 'package:flutter/material.dart';
import 'passwordreset_screen.dart'; // 비밀번호 재설정 화면 import

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 화면 크기 가져오기
    final size = MediaQuery
        .of(context)
        .size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_chart.png'), // 배경 이미지
            fit: BoxFit.cover, // 화면 크기에 맞게 배경 이미지 적용
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 상단 AppBar와 타이틀
              _buildAppBar(context, size),
              SizedBox(height: size.height * 0.02),
              // 마이페이지 타이틀
              Text(
                '마이페이지',
                style: TextStyle(
                  fontSize: size.width * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // 타이틀 글씨 색상 흰색
                ),
              ),
              Divider(
                color: Colors.white,
                thickness: 1.3,
                indent: size.width * 0.05,
                endIndent: size.width * 0.05,
                height: size.height * 0.05,
              ),
              SizedBox(height: size.height * 0.02),
              // 프로필 아이콘 대체
              _buildProfileIcon(size),
              SizedBox(height: size.height * 0.03),
              // 닉네임, 아이디, 비밀번호 변경 섹션
              _buildInfoRow(size, '닉네임', '', '닉네임 재설정'),
              SizedBox(height: size.height * 0.03),
              _buildInfoRow(size, '아이디', '', '아이디 재설정'),
              SizedBox(height: size.height * 0.03),
              // 비밀번호 재설정 버튼
              _buildPasswordResetRow(context, size),
              SizedBox(height: size.height * 0.05),
              // 하단 마스코트 이미지
              _buildMascot(size),
              // 하단 추가 이미지
              _buildUnderImage(size),
            ],
          ),
        ),
      ),
    );
  }

  // 상단 AppBar
  Widget _buildAppBar(BuildContext context, Size size) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'BudgetBunny',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: const Color(0xFF676966),
          fontSize: size.width * 0.06,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w400,
          shadows: const [
            Shadow(
              offset: Offset(0, 3.5),
              blurRadius: 5.0,
              color: Colors.black38,
            ),
          ],
        ),
      ),
      centerTitle: true,
      automaticallyImplyLeading: false,
      actions: [
        PopupMenuButton<String>(
          icon: Icon(Icons.menu, color: const Color(0xFF676966)),
          onSelected: (String choice) {
            if (choice == '홈 화면') {
              Navigator.pushNamed(context, '/home'); // 홈 화면으로 이동
            } else if (choice == '로그아웃') {
              showDialog(
                context: context,
                builder: (BuildContext context) =>
                    AlertDialog(
                      title: const Text('로그아웃'),
                      content: const Text('정말 로그아웃하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context), // 팝업 닫기
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/', (
                                route) => false); // 로그아웃 후 메인으로 이동
                          },
                          child: const Text('확인'),
                        ),
                      ],
                    ),
              );
            }
          },
          itemBuilder: (BuildContext context) {
            return {'홈 화면', '로그아웃'}.map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              );
            }).toList();
          },
        ),
      ],
    );
  }

  Widget _buildProfileIcon(Size size) {
    return Container(
      width: size.width * 0.5,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0),
      ),
      child: Center(
        child: Image.asset(
          'assets/icons/profile.png',
          width: size.width * 0.5,
          height: size.width * 0.23,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  // 정보 행 위젯
  Widget _buildInfoRow(Size size, String label, String value,
      String buttonText) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: size.width * 0.045,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
              child: TextField(
                decoration: InputDecoration(
                  hintText: value,
                  hintStyle: TextStyle(
                      color: Colors.black45, fontSize: size.width * 0.04),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(size.width * 0.02),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                      vertical: size.height * 0.015),
                ),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF20DCC0),
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(size.width * 0.02),
              ),
            ),
            onPressed: () {
              // 버튼 클릭 동작
            },
            child: Text(
              buttonText,
              style: TextStyle(
                fontSize: size.width * 0.04,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordResetRow(BuildContext context, Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.045),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
              child: const SizedBox(),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF20DCC0),
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.025),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(size.width * 0.02),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PasswordResetScreen(),
                ),
              );
            },
            child: Text(
              '비밀번호 재설정',
              style: TextStyle(
                fontSize: size.width * 0.04,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMascot(Size size,
      {double widthFactor = 1, double heightFactor = 0.5, double bottomSpacing = 0}) {
    return Padding(
      padding: EdgeInsets.only(bottom: size.height * bottomSpacing), // 아래 간격 추가
      child: Column(
        children: [
          Image.asset(
            'assets/images/budget_bunny.png',
            width: size.width * widthFactor,
            height: size.width * heightFactor,
          ),
        ],
      ),
    );
  }

  Widget _buildUnderImage(Size size,
      {double widthFactor = 1.0, double heightFactor = 0.19, double topSpacing = 0}) {
    return Padding(
      padding: EdgeInsets.only(top: size.height * topSpacing), // 위 간격 추가
      child: Image.asset(
        'assets/images/mypage_under.png',
        width: size.width * widthFactor,
        height: size.height * heightFactor,
        fit: BoxFit.contain,
      ),
    );
  }
}