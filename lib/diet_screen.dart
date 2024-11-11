import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  _DietScreenState createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  final List<String> mealTypes = ["Breakfast", "Lunch", "Supper", "Extra Meal"];
  late Box<dynamic> foodBox;

  int totalDailyCalories = 0;
  int totalWeeklyCalories = 0;

  final List<Map<String, dynamic>> foodList = [
    {'name': 'Oatmeal', 'calories': 150, 'category': 'Breakfast'},
    {'name': 'Grilled Chicken', 'calories': 250, 'category': 'Lunch'},
    {'name': 'Steamed Fish', 'calories': 200, 'category': 'Supper'},
    {'name': 'Apple', 'calories': 95, 'category': 'Extra Meal'},
    {'name': 'Banana', 'calories': 110, 'category': 'Breakfast'},
    {'name': 'Oatmeal', 'calories': 150, 'category': 'Breakfast'},
  {'name': 'Grilled Chicken', 'calories': 250, 'category': 'Lunch'},
  {'name': 'Steamed Fish', 'calories': 200, 'category': 'Supper'},
  {'name': 'Apple', 'calories': 95, 'category': 'Extra Meal'},
  {'name': 'Banana', 'calories': 110, 'category': 'Breakfast'},
  {'name': 'Scrambled Eggs', 'calories': 180, 'category': 'Breakfast'},
  {'name': 'Avocado Toast', 'calories': 220, 'category': 'Breakfast'},
  {'name': 'Salmon Fillet', 'calories': 350, 'category': 'Lunch'},
  {'name': 'Grilled Shrimp', 'calories': 280, 'category': 'Lunch'},
  {'name': 'Sweet Potato', 'calories': 120, 'category': 'Lunch'},
  {'name': 'Greek Yogurt', 'calories': 100, 'category': 'Extra Meal'},
  {'name': 'Cottage Cheese', 'calories': 120, 'category': 'Extra Meal'},
  {'name': 'Spinach Salad', 'calories': 70, 'category': 'Supper'},
  {'name': 'Roasted Chicken', 'calories': 290, 'category': 'Lunch'},
  {'name': 'Quinoa', 'calories': 180, 'category': 'Lunch'},
  {'name': 'Chia Pudding', 'calories': 150, 'category': 'Breakfast'},
  {'name': 'Peanut Butter Sandwich', 'calories': 300, 'category': 'Lunch'},
  {'name': 'Broccoli', 'calories': 50, 'category': 'Supper'},
  {'name': 'Turkey Breast', 'calories': 200, 'category': 'Supper'},
  {'name': 'Rice and Beans', 'calories': 250, 'category': 'Lunch'},
  ];

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  void _openBox() async {
    foodBox = await Hive.openBox('foodBox');
    setState(() {
      totalDailyCalories = _calculateTotalCalories();
    });
  }

  int _calculateTotalCalories() {
    return foodBox.values.fold(0, (sum, food) {
     return sum + (food['calories'] as int);
    });
  }

  String getCalorieRecommendation() {
    if (totalDailyCalories < 1500) {
      return "Increase your calorie intake!";
    } else if (totalDailyCalories > 2500) {
      return "Reduce your calorie intake!";
    } else {
      return "Keep up the good work!";
    }
  }

  String getMotivationalMessage() {
    return "Remember to stay hydrated!";
  }

  void addFoodItem(Map<String, dynamic> foodItem) {
    foodBox.add(foodItem);
    setState(() {
      totalDailyCalories = _calculateTotalCalories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diet Tracker'),
        backgroundColor: Colors.greenAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Motivational Message
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                getMotivationalMessage(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            // Calorie Recommendation
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                getCalorieRecommendation(),
                style: TextStyle(fontSize: 18, color: Colors.green),
              ),
            ),

            // List of Foods
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: mealTypes.map((mealType) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mealType,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: foodList
                            .where((food) => food['category'] == mealType)
                            .toList()
                            .length,
                        itemBuilder: (context, index) {
                          var food = foodList
                              .where((food) => food['category'] == mealType)
                              .toList()[index];
                          return ListTile(
                            title: Text(food['name']),
                            subtitle: Text('${food['calories']} calories'),
                            trailing: IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () => addFoodItem(food),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),

            // Total Calories for the Day
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Total Calories Today: $totalDailyCalories kcal',
                style: TextStyle(fontSize: 18),
              ),
            ),

            // Weekly Total Calories Placeholder
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Total Calories This Week: $totalWeeklyCalories kcal',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
