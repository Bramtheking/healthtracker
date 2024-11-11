import 'package:flutter/material.dart';

void main() {
  runApp(DietTrackerApp());
}

class DietTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diet Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DietTrackerScreen(),
    );
  }
}

class DietTrackerScreen extends StatefulWidget {
  @override
  _DietTrackerScreenState createState() => _DietTrackerScreenState();
}

class _DietTrackerScreenState extends State<DietTrackerScreen> {
  int eatenCalories = 1200;
  int totalCalories = 2000;
  int remainingCalories = 800;
  int proteinEaten = 45;
  int proteinGoal = 60;
  int carbsEaten = 120;
  int carbsGoal = 250;
  int fatEaten = 35;
  int fatGoal = 70;
  
  List<String> meals = [];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diet Tracker'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Date and Total Calorie Information
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Diet Tracker',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Monday, November 11',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Column(
                      children: [
                        Text(
                          '$eatenCalories',
                          style: TextStyle(fontSize: 24, color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                        Text('Eaten', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    SizedBox(width: 20),
                    Column(
                      children: [
                        Text(
                          '$remainingCalories',
                          style: TextStyle(fontSize: 24, color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                        Text('Remaining', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            
            // Daily Progress Card
            Card(
              color: Colors.blue[50],
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Daily Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Chip(label: Text('On Track', style: TextStyle(color: Colors.green))),
                      ],
                    ),
                    SizedBox(height: 10),
                    buildProgressBar('Calories', eatenCalories, totalCalories),
                    buildNutrientCard('Protein', proteinEaten, proteinGoal),
                    buildNutrientCard('Carbs', carbsEaten, carbsGoal),
                    buildNutrientCard('Fat', fatEaten, fatGoal),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            
            // Quick Add Meal Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildMealButton('🍳 Breakfast'),
                buildMealButton('🥗 Lunch'),
                buildMealButton('🍽️ Dinner'),
                buildMealButton('🫐 Snack'),
              ],
            ),
            SizedBox(height: 20),
            
            // Today's Summary Card
            Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Today\'s Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ...meals.map((meal) => buildMealSummary(meal)).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to build progress bar
  Widget buildProgressBar(String label, int eaten, int goal) {
    double progress = eaten / goal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: $eaten/$goal', style: TextStyle(color: Colors.grey)),
        SizedBox(height: 5),
        LinearProgressIndicator(
          value: progress > 1 ? 1 : progress,
          backgroundColor: Colors.grey[200],
          color: Colors.green,
        ),
      ],
    );
  }

  // Function to build nutrient card
  Widget buildNutrientCard(String nutrient, int eaten, int goal) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(nutrient, style: TextStyle(color: Colors.grey)),
            Text('$eaten/$goal', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // Function to add a meal to the list
  Widget buildMealButton(String meal) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          meals.add(meal);
        });
      },
      child: Text(meal, style: TextStyle(fontSize: 16)),
    );
  }

  // Function to display added meal in summary
  Widget buildMealSummary(String meal) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(meal, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Chip(label: Text('320 kcal')), // This can be dynamically updated
          ],
        ),
      ),
    );
  }
}
