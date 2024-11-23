import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
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
                  IconButton(
                    icon: Icon(Icons.menu, color: Color(0xFF676966)),
                    onPressed: () {},
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
