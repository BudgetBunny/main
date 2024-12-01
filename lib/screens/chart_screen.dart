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

  Map<int, double> monthlyDeposits = {};
  Map<int, double> monthlyWithdrawals = {};
  Map<DateTime, Map<String, double>> transactions = {};

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final transactionsQuerySnapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: user.uid)
        .get();

    Map<int, double> deposits = {};
    Map<int, double> withdrawals = {};
    final Map<DateTime, Map<String, double>> tempTransactions = {};

    for (var doc in transactionsQuerySnapshot.docs) {
      final data = doc.data();
      final timestamp = (data['timestamp'] as Timestamp).toDate();
      final amount = data['amount']?.toDouble() ?? 0.0;
      final type = data['type'];
      final month = timestamp.month;
      final date = DateTime(timestamp.year, timestamp.month, timestamp.day);

      if (type == 'deposit') {
        deposits[month] = (deposits[month] ?? 0) + amount;
        if (!tempTransactions.containsKey(date)) {
          tempTransactions[date] = {'deposit': 0.0, 'withdrawal': 0.0};
        }
        tempTransactions[date]!['deposit'] =
            (tempTransactions[date]!['deposit'] ?? 0.0) + amount;
      } else if (type == 'withdrawal') {
        withdrawals[month] = (withdrawals[month] ?? 0) + amount;
        if (!tempTransactions.containsKey(date)) {
          tempTransactions[date] = {'deposit': 0.0, 'withdrawal': 0.0};
        }
        tempTransactions[date]!['withdrawal'] =
            (tempTransactions[date]!['withdrawal'] ?? 0.0) + amount;
      }
    }

    setState(() {
      monthlyDeposits = deposits;
      monthlyWithdrawals = withdrawals;
      transactions = tempTransactions;
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
                                      context, '/', (route) => false);
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
                    _buildTabItem('입출금', '/home'),
                    _buildTabItem('관리', '/goal'),
                  ],
                ),
              ),
              SizedBox(height: 20),
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
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, date, _) {
                      final transaction = transactions[_stripTime(date)];
                      final deposit = transaction?['deposit']?.toInt() ?? 0;
                      final withdrawal = transaction?['withdrawal']?.toInt() ?? 0;

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            date.day.toString(),
                            style: TextStyle(fontSize: 11),
                          ),
                          if (deposit > 0)
                            Text('+${deposit}', style: TextStyle(fontSize: 8, color: Colors.blue)),
                          if (withdrawal > 0)
                            Text('-${withdrawal}', style: TextStyle(fontSize: 8, color: Colors.red)),
                        ],
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                child: Container(
                  height: 350,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        // maxY 값을 deposits와 withdrawals의 최대값 중 큰 값에 적절한 여유를 두고 설정
                        maxY: [
                          if (monthlyDeposits.isNotEmpty) monthlyDeposits.values.reduce((a, b) => a > b ? a : b),
                          if (monthlyWithdrawals.isNotEmpty) monthlyWithdrawals.values.reduce((a, b) => a > b ? a : b),
                        ].reduce((a, b) => a > b ? a : b) * 1.2, // 20% 여유 추가
                        barGroups: List.generate(12, (index) {
                          final month = index + 1;
                          return BarChartGroupData(
                            x: month,
                            barRods: [
                              BarChartRodData(
                                toY: monthlyDeposits[month] ?? 0,
                                gradient: LinearGradient(
                                  colors: [Colors.blue, Colors.lightBlueAccent],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                width: 7,
                                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                              ),
                              BarChartRodData(
                                toY: monthlyWithdrawals[month] ?? 0,
                                gradient: LinearGradient(
                                  colors: [Colors.red, Colors.orangeAccent],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                width: 7,
                                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                              ),
                            ],
                          );
                        }),
                        titlesData: FlTitlesData(
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false), // 오른쪽 단위 표시 제거
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false), // 위쪽 단위 표시 제거
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                              getTitlesWidget: (value, meta) {
                                // 투명 글자 처리
                                final maxY = [
                                  if (monthlyDeposits.isNotEmpty) monthlyDeposits.values.reduce((a, b) => a > b ? a : b),
                                  if (monthlyWithdrawals.isNotEmpty) monthlyWithdrawals.values.reduce((a, b) => a > b ? a : b),
                                ].reduce((a, b) => a > b ? a : b) * 1.2;

                                if (value == maxY) {
                                  return Text(
                                    '${(value / 10000).toInt()}만원',
                                    style: TextStyle(fontSize: 10, color: Colors.transparent), // 투명 처리
                                  );
                                } else if (value % 10000 == 0) {
                                  return Text(
                                    '${(value / 10000).toInt()}만원', // 정상 표시
                                    style: TextStyle(fontSize: 10),
                                  );
                                }
                                return SizedBox.shrink();
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final months = [
                                  '1월',
                                  '2월',
                                  '3월',
                                  '4월',
                                  '5월',
                                  '6월',
                                  '7월',
                                  '8월',
                                  '9월',
                                  '10월',
                                  '11월',
                                  '12월'
                                ];
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: Text(
                                    months[value.toInt() - 1],
                                    style: TextStyle(fontSize: 10),
                                  ),
                                );
                              },
                              reservedSize: 30,
                            ),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawHorizontalLine: true,
                          horizontalInterval: 10000, // 1만원 단위로 설정
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.white.withOpacity(0.3),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  )

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
    final isSelected = _selectedTab == label;
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