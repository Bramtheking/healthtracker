import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:fl_chart/fl_chart.dart'; // For charts
// For charts
// Food data class to store food name and calories
class Food {
  final String name;
  final int calories;

  Food({required this.name, required this.calories});
}

class DietScreen extends StatefulWidget {
  @override
  _DietScreenState createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  int dailyCalorieGoal = 2000;  // Set a daily calorie goal
  List<Food> foodList = [
    Food(name: 'Apple', calories: 95),
    Food(name: 'Banana', calories: 105),
    Food(name: 'Carrot', calories: 41),
    Food(name: 'Chicken Breast', calories: 165),
    Food(name: 'Egg', calories: 78),
    Food(name: 'Broccoli', calories: 55),
    Food(name: 'Rice (1 cup)', calories: 200),
    Food(name: 'Avocado', calories: 234),
    Food(name: 'Salmon', calories: 206),
    Food(name: 'Almonds (1 oz)', calories: 160),
    Food(name: 'Greek Yogurt', calories: 100),
    Food(name: 'Orange', calories: 62),
    Food(name: 'Spinach', calories: 23),
    Food(name: 'Sweet Potato', calories: 103),
    Food(name: 'Tomato', calories: 22),
    Food(name: 'Oats (1 cup)', calories: 154),
    Food(name: 'Cucumber', calories: 16),
    Food(name: 'Cheese (1 slice)', calories: 113),
    Food(name: 'Turkey Breast', calories: 135),
    Food(name: 'Peanut Butter (1 tbsp)', calories: 94),
  ];

  List<Food> selectedFoods = [];  // List of selected foods
  Box? foodBox;

  @override
  void initState() {
    super.initState();
    _openHiveBox();
  }

  void _openHiveBox() async {
    foodBox = await Hive.openBox('foodBox');
    setState(() {
      selectedFoods = foodBox?.values.map((e) => Food(name: e['name'], calories: e['calories'])).toList() ?? [];
    });
  }

  // Calculate total calories of selected foods
  int _calculateTotalCalories() {
    return selectedFoods.fold(0, (total, food) => total + food.calories);
  }

  // Add a food item to the selected list
  void _addFood(Food food) {
    setState(() {
      selectedFoods.add(food);
    });
    foodBox?.put('selectedFoods', selectedFoods.map((e) => {'name': e.name, 'calories': e.calories}).toList());
  }

  // Remove a food item from the selected list
  void _removeFood(Food food) {
    setState(() {
      selectedFoods.remove(food);
    });
    foodBox?.put('selectedFoods', selectedFoods.map((e) => {'name': e.name, 'calories': e.calories}).toList());
  }

  @override
  Widget build(BuildContext context) {
    int totalCalories = _calculateTotalCalories();
    int remainingCalories = dailyCalorieGoal - totalCalories;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Diet'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section with date and daily overview
            _buildHeaderSection(),

            SizedBox(height: 20),

            // Calorie Breakdown
            _buildCalorieBreakdown(totalCalories, remainingCalories),

            SizedBox(height: 20),

            // Recent Meals Section
            _buildRecentMealsSection(),

            SizedBox(height: 20),

            // Nutrient Breakdown
            _buildNutrientBreakdown(),

            SizedBox(height: 20),

            // Food Picker
            _buildFoodPicker(),

            SizedBox(height: 20),

            // Floating Action Button to add a meal
            _buildAddMealButton(),
          ],
        ),
      ),
    );
  }

  // Header Section
  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Overview',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Date: ${DateTime.now().toLocal().toString().split(' ')[0]}',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  // Calorie Breakdown Section
  Widget _buildCalorieBreakdown(int totalCalories, int remainingCalories) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCircularProgressBar('Eaten', totalCalories, Colors.green),
            _buildCircularProgressBar('Remaining', remainingCalories, Colors.blue),
            _buildCircularProgressBar('Goal', dailyCalorieGoal, Colors.purple),
          ],
        ),
      ],
    );
  }

  // Circular Progress Bar Widget for calorie tracking
  Widget _buildCircularProgressBar(String label, int value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 16, color: color)),
        SizedBox(height: 4),
        CircularProgressIndicator(
          value: value / dailyCalorieGoal,
          strokeWidth: 8,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation(color),
        ),
        SizedBox(height: 8),
        Text('$value kcal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  // Recent Meals Section (Horizontal scrollable)
  Widget _buildRecentMealsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Meals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Container(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: selectedFoods.length,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.only(right: 10),
                child: Container(
                  width: 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fastfood, size: 50, color: Colors.orange),
                      Text(selectedFoods[index].name),
                      Text('${selectedFoods[index].calories} kcal'),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Nutrient Breakdown Section (Macronutrients and Micronutrients)
 Widget _buildNutrientBreakdown() {
  return Column(
    children: [
      Text('Macronutrients Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      SizedBox(height: 10),
      Container(
        height: 150,
        child: PieChart(
          PieChartData(
            sections: [
              PieChartSectionData(
                color: Colors.green,
                value: 45,
                title: 'Carbs',
                radius: 50,
              ),
              PieChartSectionData(
                color: Colors.blue,
                value: 30,
                title: 'Proteins',
                radius: 50,
              ),
              PieChartSectionData(
                color: Colors.orange,
                value: 25,
                title: 'Fats',
                radius: 50,
              ),
            ],
          ),
        ),
      ),
    ],
  );
}


  // Food Picker Section
  Widget _buildFoodPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pick Your Meal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: foodList.length,
            itemBuilder: (context, index) {
              final food = foodList[index];
              return ListTile(
                title: Text(food.name),
                subtitle: Text('${food.calories} kcal'),
                trailing: IconButton(
                  icon: Icon(
                    selectedFoods.contains(food) ? Icons.remove_circle : Icons.add_circle,
                    color: selectedFoods.contains(food) ? Colors.red : Colors.green,
                  ),
                  onPressed: () {
                    if (selectedFoods.contains(food)) {
                      _removeFood(food);
                    } else {
                      _addFood(food);
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Add Meal Floating Action Button
  Widget _buildAddMealButton() {
    return FloatingActionButton(
      onPressed: () {
        // Implement function to add a new meal or food item
      },
      backgroundColor: Colors.green,
      child: Icon(Icons.add),
    );
  }
}
