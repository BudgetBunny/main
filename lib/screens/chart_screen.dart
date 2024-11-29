import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'goal_screen.dart';



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => ChartScreen(),
        '/chart': (context) => ChartScreen(),
        '/home': (context) => HomeScreen(),
        '/goal': (context) => GoalScreen(),
      },
    );
  }
}
class ChartScreen extends StatefulWidget {
  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _selectedTab = '통계';

  Map<DateTime, Map<String, double>> transactions = {};

  @override
  void initState() {
    super.initState();
    _loadTransactions();  // 앱 시작 시 거래 데이터 불러오기
  }

  Future<void> _loadTransactions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final transactionsQuerySnapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: user.uid)
        .get();

    final Map<DateTime, Map<String, double>> tempTransactions = {};

    for (var doc in transactionsQuerySnapshot.docs) {
      final data = doc.data();
      final timestamp = (data['timestamp'] as Timestamp).toDate();
      final amount = data['amount']?.toDouble() ?? 0.0;
      final type = data['type'];

      if (type == 'deposit' || type == 'withdrawal') {
        final date = DateTime(timestamp.year, timestamp.month, timestamp.day);
        if (!tempTransactions.containsKey(date)) {
          tempTransactions[date] = {'deposit': 0.0, 'withdrawal': 0.0};
        }
        if (type == 'deposit') {
          tempTransactions[date]!['deposit'] = (tempTransactions[date]!['deposit'] ?? 0.0) + amount;
        } else if (type == 'withdrawal') {
          tempTransactions[date]!['withdrawal'] = (tempTransactions[date]!['withdrawal'] ?? 0.0) + amount;
        }
      }
    }

    setState(() {
      transactions = tempTransactions;  // 거래 데이터를 상태에 업데이트
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background_chart.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
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
                        Navigator.pushNamed(context, '/mypage'); // 마이페이지로 이동
                      } else if (choice == '로그아웃') {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: Text('로그아웃'),
                            content: Text('정말 로그아웃하시겠습니까?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context), // 다이얼로그 닫기
                                child: Text('취소'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, '/', (route) => false); // 로그아웃 후 메인 화면으로 이동
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
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTabItem('통계', '/chart'),
                    _buildTabItem('입출금', '/home'), // 입출금 화면으로 연결
                    _buildTabItem('관리', '/goal'),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // 캘린더
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Color(0xFFD7F0E7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TableCalendar(
                  firstDay: DateTime(2020, 1, 1),
                  lastDay: DateTime(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    defaultTextStyle: TextStyle(color: Colors.black),
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, date, focusedDay) {
                      var transaction = transactions[_stripTime(date)];
                      String deposit = transaction != null
                          ? '+${transaction['deposit']?.toInt() ?? 0}'
                          : '';
                      String withdrawal  = transaction != null
                          ? '-${transaction['withdrawal']?.toInt() ?? 0}'
                          : '';

                      return Column(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 13),
                              Text(
                                date.day.toString(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              if (deposit.isNotEmpty)
                                Text(
                                  deposit,
                                  style: TextStyle(fontSize: 8, color: Colors.blue),
                                ),
                              if (withdrawal .isNotEmpty)
                                Text(
                                  withdrawal ,
                                  style: TextStyle(fontSize: 8, color: Colors.red),
                                ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
              // LineChart 그래프
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Container(
                  height: 300,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      minX: 1,
                      maxX: 12,
                      minY: 0,
                      maxY: 100,
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            FlSpot(1, 50),
                            FlSpot(2, 60),
                            FlSpot(3, 60),
                            FlSpot(4, 50),
                            FlSpot(5, 55),
                            FlSpot(6, 60),
                            FlSpot(7, 45),
                            FlSpot(8, 75),
                            FlSpot(9, 50),
                            FlSpot(10, 55),
                            FlSpot(11, 45),
                            FlSpot(12, 50),
                          ],
                          isCurved: true,
                          color: Colors.blue,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(show: false),
                        ),
                        LineChartBarData(
                          spots: [
                            FlSpot(1, 40),
                            FlSpot(2, 45),
                            FlSpot(3, 55),
                            FlSpot(4, 35),
                            FlSpot(5, 40),
                            FlSpot(6, 40),
                            FlSpot(7, 60),
                            FlSpot(8, 50),
                            FlSpot(9, 65),
                            FlSpot(10, 40),
                            FlSpot(11, 45),
                            FlSpot(12, 55),
                          ],
                          isCurved: true,
                          color: Colors.red,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(show: false),
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
    );
  }

  DateTime _stripTime(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Widget _buildTabItem(String label, String route) {
    bool isSelected = _selectedTab == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = label;
        });
        Navigator.pushNamed(context, route); // 클릭 시 화면 이동
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