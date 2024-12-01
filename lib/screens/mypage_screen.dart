import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'passwordreset_screen.dart'; // 비밀번호 재설정 화면 import
import 'nicknamereset_screen.dart'; // 닉네임 재설정 화면 import

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width, // 화면의 너비
        height: size.height, // 화면의 높이
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/mypage.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildAppBar(context, size),
              SizedBox(height: size.height * 0.02),
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
                height: size.height * 0.05,
              ),
              SizedBox(height: size.height * 0.02),
              _buildProfileIcon(size),
              SizedBox(height: size.height * 0.03),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  if (snapshot.hasError) {
                    return Text('오류: ${snapshot.error}');
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Text('정보를 불러오는 중 오류가 발생했습니다.');
                  }

                  var userData = snapshot.data!;
                  String nickname = userData['nickname'] ?? '닉네임 없음';
                  String email = userData['email'] ?? '이메일 없음';

                  return Column(
                    children: [
                      _buildInfoRow(context, size, '아이디', email),
                      SizedBox(height: size.height * 0.03),
                      _buildInfoRow(context, size, '닉네임', nickname, showResetButtons: true),
                      SizedBox(height: size.height * 0.01),
                      _buildDeleteAccountButton(context, size), // 탈퇴 버튼 추가
                      SizedBox(height: size.height * 0.05),
                    ],
                  );
                },
              ),

            ],
          ),
        ),
      ),
    );
  }

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
              Navigator.pushNamed(context, '/home');
            } else if (choice == '로그아웃') {
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('로그아웃'),
                  content: const Text('정말 로그아웃하시겠습니까?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/', (route) => false);
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

  Widget _buildInfoRow(BuildContext context, Size size, String label, String value,
      {bool showResetButtons = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: value,
                      hintStyle: TextStyle(
                        color: Colors.black45,
                        fontSize: size.width * 0.04,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(size.width * 0.02),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: size.height * 0.015,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (showResetButtons) ...[
            SizedBox(height: size.height * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF20DCC0),
                      padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(size.width * 0.02),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NicknameResetScreen(),
                        ),
                      );
                    },
                    child: Text(
                      '닉네임 재설정',
                      style: TextStyle(
                        fontSize: size.width * 0.04,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: size.width * 0.03),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF20DCC0),
                      padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
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
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context, Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end, // Row 전체 오른쪽 정렬
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xffEB3232),
            padding: EdgeInsets.all(7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(size.width * 0.02),
            ),
          ),
          onPressed: () {
            _showDeleteAccountDialog(context);
          },
          child: Text(
            '탈퇴하기',
            style: TextStyle(
              fontSize: size.width * 0.04,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(width: 20),
      ],

    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('계정 삭제'),
          content: const Text('정말 계정을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 팝업 닫기
              },
              child: const Text('뒤로'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // 계정 삭제 로직
                  await FirebaseAuth.instance.currentUser?.delete();

                  // 계정 삭제 성공 시 첫 화면으로 이동
                  Navigator.pushReplacementNamed(context, '/first');
                } catch (error) {
                  // 계정 삭제 실패 시 에러 처리
                  Navigator.pop(context); // 팝업 닫기
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('계정 삭제에 실패했습니다: $error')),
                  );
                }
              },
              child: const Text('삭제하기'),
            ),
          ],
        );
      },
    );
  }


  Future<void> _deleteAccount(BuildContext context) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      await FirebaseAuth.instance.currentUser!.delete();
      Navigator.pushNamedAndRemoveUntil(context, '/first', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('계정을 삭제하는 중 오류가 발생했습니다: $e')),
      );
    }
  }




}