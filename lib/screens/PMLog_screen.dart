import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chart_screen.dart';
import 'home_screen.dart';
import 'goal_screen.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/goal': (context) => GoalScreen(),
        '/chart': (context) => ChartScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}

class PMLogScreen extends StatefulWidget {
  @override
  _PMLogState createState() => _PMLogState();
}

class _PMLogState extends State<PMLogScreen> {
  String _backgroundImage = 'assets/images/background_log.png'; // 초기 배경 이미지
  List<Map<String, dynamic>> _transactions = [];
  String _selectedFilter = '전체'; // 필터 기본값
  String _selectedTab = '입출금'; // 탭 기본값

  @override
  void initState() {
    super.initState();
    _fetchTransactions(); // 화면이 처음 렌더링 될 때 데이터를 불러옴
  }

  Future<void> _fetchTransactions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final transactionsCollection = FirebaseFirestore.instance.collection('transactions');

    // 필터에 따라 쿼리 변경
    Query query = transactionsCollection.where('userId', isEqualTo: user.uid);

    if (_selectedFilter == '입금') {
      query = query.where('type', isEqualTo: 'deposit');
    } else if (_selectedFilter == '출금') {
      query = query.where('type', isEqualTo: 'withdrawal');
    } else if (_selectedFilter == '전체') {
      query = query.where('type', whereIn: ['deposit', 'withdrawal']);
    }


    final querySnapshot = await query.orderBy('timestamp', descending: true).get();

    setState(() {
      _transactions = querySnapshot.docs.map((doc) {
        final Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data == null) {
          return {}; // 데이터가 null인 경우 빈 Map 반환
        }

        return {
          'amount': data['amount'] ?? 0, // null이면 0
          'type': data['type'] ?? 'unknown', // null이면 unknown
          'timestamp': (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(), // null이면 현재 시간
        };
      }).toList().cast<Map<String, dynamic>>();
    });
  }

  // 전체, 입금, 출금 필터링된 데이터 반환
  List<Map<String, dynamic>> get _filteredTransactions {
    if (_selectedFilter == '전체') {
      return _transactions; // 전체 표시
    } else if (_selectedFilter == '입금') {
      return _transactions.where((transaction) => transaction['type'] == 'deposit').toList();
    } else if (_selectedFilter == '출금') {
      return _transactions.where((transaction) => transaction['type'] == 'withdrawal').toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 배경 이미지
          Positioned.fill(
            child: Image.asset(
              _backgroundImage,
              fit: BoxFit.cover,
            ),
          ),
          // 주요 UI
          Column(
            children: [
              // 투명 AppBar
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(
                  'BudgetBunny',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF676966),
                    fontSize: 22,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    height: 0.06,
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
                automaticallyImplyLeading: false,
                actions: [
                  PopupMenuButton<String>(
                    icon: Icon(Icons.menu, color: Color(0xFF676966)),
                    onSelected: (String choice) {
                      if (choice == '마이페이지') {
                        Navigator.pushNamed(context, '/mypage');
                      } else if (choice == '로그아웃') {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: Text('로그아웃'),
                            content: Text('정말 로그아웃하시겠습니까?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('취소'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, '/', (route) => false); // 로그아웃
                                },
                                child: Text('확인'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return {'마이페이지', '로그아웃'}.map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        );
                      }).toList();
                    },
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 17.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTabItem('통계', '/chart'),
                    _buildTabItem('입출금', '/home'),
                    _buildTabItem('관리', '/goal'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: _buildFilterButton('전체'),
                    ),
                    SizedBox(width: 10.0),
                    _buildFilterButton('입금'),
                    SizedBox(width: 10.0),
                    _buildFilterButton('출금'),
                  ],
                ),
              ),
              Expanded(
                child: _filteredTransactions.isEmpty
                    ? Center(
                  child: Text(
                    '내역이 없습니다.',
                    style: TextStyle(color: Colors.white),
                  ),
                )
                    : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: ListView(
                    children: _filteredTransactions.map((transaction) {
                      return _buildTransactionCard(transaction);
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String filter) {
    bool isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
        _fetchTransactions(); // 필터 기능
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.blueGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.green,
            width: 2,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Text(
          filter,
          style: TextStyle(
            color: isSelected ? Colors.green : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final typeLabel = transaction['type'] == 'deposit' ? '입금' : '출금';
    final typeColor = transaction['type'] == 'deposit' ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.all(10.0),
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$typeLabel 금액: ₩${transaction['amount']}',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: typeColor,
              ),
            ),
            Text(
              '날짜: ${transaction['timestamp'].toString()}',
              style: TextStyle(fontSize: 14.0),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildTabItem(String label, String route) {
    bool isSelected = _selectedTab == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = label;
        });
        Navigator.pushNamed(context, route);
      },

      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 3.0,
              color: isSelected ? Colors.white : Colors.transparent,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

}
