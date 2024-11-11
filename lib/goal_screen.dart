import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class GoalsScreen extends StatefulWidget {
  @override
  _GoalsScreenState createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  late Box goalBox;

  @override
  void initState() {
    super.initState();
    openBox();
  }

  Future<void> openBox() async {
    goalBox = await Hive.openBox('goalsBox');
    setState(() {});
  }

  void _setGoal(String key, dynamic value) {
    goalBox.put(key, value);
    setState(() {});
  }

  Widget _buildGoalTile(String title, String key, IconData icon) {
    var goalValue = goalBox.get(key, defaultValue: 0);

    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('Goal: $goalValue'),
      trailing: ElevatedButton(
        onPressed: () {
          _showGoalDialog(title, key, goalValue);
        },
        child: Text('Set'),
      ),
    );
  }

  void _showGoalDialog(String title, String key, int currentValue) {
    TextEditingController controller = TextEditingController(text: currentValue.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Set Goal for $title"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Enter target",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                int newGoal = int.tryParse(controller.text) ?? 0;
                _setGoal(key, newGoal);
                Navigator.of(context).pop();
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Goals'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              // Placeholder for future feature: Goal History
            },
          )
        ],
      ),
      body: goalBox.isOpen
          ? ListView(
              padding: EdgeInsets.all(16),
              children: [
                _buildGoalTile("Steps", "stepsGoal", Icons.directions_walk),
                _buildGoalTile("Sleep (hrs)", "sleepGoal", Icons.nightlight_round),
                _buildGoalTile("Calories Burned", "caloriesGoal", Icons.local_fire_department),
                _buildGoalTile("Water Intake (ml)", "waterGoal", Icons.local_drink),
                _buildGoalTile("Heart Rate", "heartRateGoal", Icons.favorite),
              ],
            )
          : Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Placeholder for future feature: Add New Goal
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
