import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

// Add HealthGoal Hive model
@HiveType(typeId: 0)
class HealthGoal {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final double currentValue;
  @HiveField(2)
  final double targetValue;
  @HiveField(3)
  final String unit;
  @HiveField(4)
  final String frequency;
  @HiveField(5)
  final String icon;
  @HiveField(6)
  final int color;

  HealthGoal({
    required this.title,
    required this.currentValue,
    required this.targetValue,
    required this.unit,
    required this.frequency,
    required this.icon,
    required this.color,
  });
}

class GoalsScreen extends StatefulWidget {
  @override
  _GoalsScreenState createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  late Box goalBox;
  @override
  void initState() {
    super.initState();
    goalBox = Hive.box('goalBox'); // Open the Hive box
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('My Health Goals', style: TextStyle(color: Colors.black87)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.black87),
            onPressed: () => _showAddGoalDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCard(),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: goalBox.listenable(),
              builder: (context, Box box, _) {
                List<HealthGoal> goals = box.values.toList().cast<HealthGoal>();
                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: goals.length,
                  itemBuilder: (context, index) {
                    return _buildGoalCard(goals[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    int totalGoals = goalBox.length;
    int achievedGoals = goalBox.values.where((goal) =>
        (goal as HealthGoal).currentValue / (goal.targetValue) >= 0.9).length;

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Goals Summary',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '$achievedGoals of $totalGoals goals on track',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          CircularPercentIndicator(
            radius: 30.0,
            lineWidth: 8.0,
            percent: achievedGoals / totalGoals,
            center: Text(
              '${((achievedGoals / totalGoals) * 100).round()}%',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            progressColor: Colors.green,
            backgroundColor: Colors.green.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

 Widget _buildGoalCard(HealthGoal goal) {
  double progress = goal.currentValue / goal.targetValue;
  
  // Use predefined icons from the Icons class
  Icon icon = Icon(Icons.favorite, color: Color(goal.color));  // Example: replace with a predefined icon

  return Container(
    margin: EdgeInsets.only(bottom: 16),
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 10,
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(goal.color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: icon,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${goal.currentValue} / ${goal.targetValue} ${goal.unit}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.grey),
              onPressed: () => _showEditGoalDialog(context, goal),
            ),
          ],
        ),
        SizedBox(height: 16),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Color(goal.color).withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(Color(goal.color)),
          minHeight: 8,
        ),
      ],
    ),
  );
}


  void _showAddGoalDialog(BuildContext context) {
    // Implement add goal dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Goal'),
        content: Text('Goal creation form would go here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Add a sample goal to Hive
              goalBox.add(HealthGoal(
                title: 'New Goal',
                currentValue: 0,
                targetValue: 10,
                unit: 'units',
                frequency: 'Daily',
                icon: Icons.star.codePoint.toString(),
                color: Colors.blue.value,
              ));
              Navigator.pop(context);
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditGoalDialog(BuildContext context, HealthGoal goal) {
    // Implement edit goal dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Goal'),
        content: Text('Goal editing form would go here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}
