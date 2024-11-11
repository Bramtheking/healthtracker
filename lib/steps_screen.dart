import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StepsScreen extends StatefulWidget {
  @override
  _StepsScreenState createState() => _StepsScreenState();
}

class _StepsScreenState extends State<StepsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final int dailyGoal = 10000;
  Box? stepsBox; // Make stepsBox nullable to allow for uninitialized state

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initHive();
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    stepsBox = await Hive.openBox('stepsBox');
    setState(() {}); // Trigger a rebuild after stepsBox is initialized
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addSteps(int steps) {
    stepsBox?.add({
      'steps': steps,
      'timestamp': DateTime.now().toString(),
    });
    setState(() {});
  }

  List<int> getWeeklySteps() {
    if (stepsBox == null) return [];
    return List<int>.from(stepsBox!.values.map((entry) => entry['steps'])).take(7).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (stepsBox == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Step Tracking')),
        body: Center(child: CircularProgressIndicator()), // Show loading indicator while initializing Hive
      );
    }

    List<int> weeklySteps = getWeeklySteps();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Step Tracking', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Today'),
            Tab(text: 'Week'),
            Tab(text: 'Month'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayView(weeklySteps.isNotEmpty ? weeklySteps.last : 0),
          _buildWeekView(weeklySteps),
          _buildMonthView(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
        onPressed: () {
          _showAddStepsDialog();
        },
      ),
    );
  }

  Widget _buildTodayView(int currentSteps) {
    final progress = (currentSteps / dailyGoal).clamp(0.0, 1.0);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepsSummaryCard(currentSteps),
          SizedBox(height: 20),
          _buildProgressCard(progress),
        ],
      ),
    );
  }

  Widget _buildStepsSummaryCard(int steps) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Steps Today',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 8),
                    Text(
                      steps.toString(),
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
                Icon(Icons.directions_walk, size: 48, color: Colors.green),
              ],
            ),
            SizedBox(height: 16),
            LinearProgressIndicator(
              value: steps / dailyGoal,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            SizedBox(height: 8),
            Text(
              '${((steps / dailyGoal) * 100).toStringAsFixed(1)}% of daily goal',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(double progress) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Goal Progress',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProgressIndicator('Steps', progress, Colors.green),
                _buildProgressIndicator('Distance', progress * 0.9, Colors.blue),
                _buildProgressIndicator('Calories', progress * 0.8, Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(String label, double value, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 80,
              width: 80,
              child: CircularProgressIndicator(
                value: value,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeWidth: 8,
              ),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildWeekView(List<int> weeklySteps) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: AspectRatio(
                aspectRatio: 1.7,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 12000,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                            return Text(
                              days[value.toInt() % 7],
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: weeklySteps.asMap().entries.map((entry) {
                      return BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value.toDouble(),
                            color: Colors.green,
                            width: 22,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthView() {
    return Center(child: Text('Monthly view coming soon...'));
  }

  void _showAddStepsDialog() {
    final _stepsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Steps Manually'),
        content: TextField(
          controller: _stepsController,
          decoration: InputDecoration(labelText: 'Number of Steps', border: OutlineInputBorder()),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final steps = int.tryParse(_stepsController.text);
              if (steps != null) {
                _addSteps(steps);
                Navigator.pop(context);
              }
            },
            child: Text('Save'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
        ],
      ),
    );
  }
}
