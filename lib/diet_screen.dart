import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class Food {
  final String name;
  final int calories;
  final String mealType; // breakfast, lunch, dinner, snack

  Food({required this.name, required this.calories, required this.mealType});
}

class DietScreen extends StatefulWidget {
  @override
  _DietScreenState createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  int dailyCalorieGoal = 2000;
  int waterGoal = 8; // glasses per day
  int currentWaterIntake = 0;

  List<Food> foodList = [
    Food(name: 'Apple', calories: 95, mealType: 'snack'),
    Food(name: 'Banana', calories: 105, mealType: 'breakfast'),
    // Add more predefined foods if necessary
  ];

  List<Food> selectedFoods = [];
  Box? foodBox;

  @override
  void initState() {
    super.initState();
    _openHiveBox();
  }

  void _openHiveBox() async {
    foodBox = await Hive.openBox('dietBox');
    setState(() {
      selectedFoods = foodBox?.get('selectedFoods', defaultValue: []).map((e) => Food(name: e['name'], calories: e['calories'], mealType: e['mealType'])).toList() ?? [];
      currentWaterIntake = foodBox?.get('currentWaterIntake', defaultValue: 0);
    });
  }

  int _calculateTotalCalories() {
    return selectedFoods.fold(0, (total, food) => total + food.calories);
  }

  int _calculateMealCalories(String mealType) {
    return selectedFoods.where((food) => food.mealType == mealType).fold(0, (total, food) => total + food.calories);
  }

  void _addFood(Food food) {
    setState(() {
      selectedFoods.add(food);
    });
    foodBox?.put('selectedFoods', selectedFoods.map((e) => {'name': e.name, 'calories': e.calories, 'mealType': e.mealType}).toList());
  }

  void _removeFood(Food food) {
    setState(() {
      selectedFoods.remove(food);
    });
    foodBox?.put('selectedFoods', selectedFoods.map((e) => {'name': e.name, 'calories': e.calories, 'mealType': e.mealType}).toList());
  }

  void _updateWaterIntake(int glasses) {
    setState(() {
      currentWaterIntake += glasses;
    });
    foodBox?.put('currentWaterIntake', currentWaterIntake);
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
            _buildHeaderSection(),
            SizedBox(height: 20),
            _buildCalorieBreakdown(totalCalories, remainingCalories),
            SizedBox(height: 20),
            _buildWaterTracker(),
            SizedBox(height: 20),
            _buildMealRecommendations(),
            SizedBox(height: 20),
            _buildFoodPicker(),
            SizedBox(height: 20),
            _buildWeeklyTrends(),
          ],
        ),
      ),
      floatingActionButton: _buildAddMealButton(),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Daily Overview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text('Date: ${DateFormat.yMMMd().format(DateTime.now())}', style: TextStyle(fontSize: 16, color: Colors.grey)),
      ],
    );
  }

  Widget _buildCalorieBreakdown(int totalCalories, int remainingCalories) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCircularProgressBar('Eaten', totalCalories, Colors.green),
            _buildCircularProgressBar('Remaining', remainingCalories, Colors.blue),
            _buildCircularProgressBar('Goal', dailyCalorieGoal, Colors.purple),
          ],
        ),
      ],
    );
  }

  Widget _buildCircularProgressBar(String label, int value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 16, color: color)),
        CircularProgressIndicator(
          value: value / dailyCalorieGoal,
          strokeWidth: 8,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation(color),
        ),
        Text('$value kcal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildWaterTracker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Water Intake', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$currentWaterIntake of $waterGoal glasses', style: TextStyle(fontSize: 16)),
            ElevatedButton(
              onPressed: () => _updateWaterIntake(1),
              child: Text('Add Glass'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMealRecommendations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Meal Recommendations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ...['breakfast', 'lunch', 'dinner', 'snack'].map((meal) {
          int mealCalories = _calculateMealCalories(meal);
          String recommendation = mealCalories > dailyCalorieGoal / 3 ? 'Consider lighter options.' : 'Feel free to add more!';
          return ListTile(
            title: Text('$meal: $mealCalories kcal'),
            subtitle: Text(recommendation),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildFoodPicker() {
    return Expanded(
      child: ListView.builder(
        itemCount: foodList.length,
        itemBuilder: (context, index) {
          final food = foodList[index];
          return ListTile(
            title: Text(food.name),
            subtitle: Text('${food.calories} kcal'),
            trailing: IconButton(
              icon: Icon(selectedFoods.contains(food) ? Icons.remove_circle : Icons.add_circle),
              onPressed: () {
                selectedFoods.contains(food) ? _removeFood(food) : _addFood(food);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeeklyTrends() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Weekly Trends', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Container(
          height: 150,
          child: BarChart(
            BarChartData(
              barGroups: List.generate(7, (index) => BarChartGroupData(
                x: index,
                barRods: [BarChartRodData(toY: (dailyCalorieGoal - _calculateTotalCalories()) / dailyCalorieGoal)],
              )),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddMealButton() {
    return FloatingActionButton(
      onPressed: () {
        // Additional logic for adding new meals
      },
      child: Icon(Icons.add),
    );
  }
}
