import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class DietScreenProvider extends ChangeNotifier {
  int _calories = 2000;
  int _protein = 80;
  int _carbs = 250;
  int _fat = 65;
  int _water = 2000;
  int _fiber = 25;
  int _sodium = 2300;
  int _calcium = 1000;
  int _iron = 18;
  int _vitaminC = 75;
  double _targetCalories = 2000;
  DateTime _lastMealTime = DateTime.now().subtract(Duration(hours: 2));

  int get calories => _calories;
  int get protein => _protein;
  int get carbs => _carbs;
  int get fat => _fat;
  int get water => _water;
  int get fiber => _fiber;
  int get sodium => _sodium;
  int get calcium => _calcium;
  int get iron => _iron;
  int get vitaminC => _vitaminC;
  double get targetCalories => _targetCalories;
  DateTime get lastMealTime => _lastMealTime;

  void incrementCalories(int amount) {
    _calories += amount;
    notifyListeners();
  }

  void decrementCalories(int amount) {
    _calories = max(_calories - amount, 0);
    notifyListeners();
  }

  void setTargetCalories(double value) {
    _targetCalories = value;
    notifyListeners();
  }

  void logMeal(int calories) {
    _calories += calories;
    _lastMealTime = DateTime.now();
    notifyListeners();
  }

  void incrementProtein(int amount) {
    _protein += amount;
    notifyListeners();
  }

  void decrementProtein(int amount) {
    _protein = max(_protein - amount, 0);
    notifyListeners();
  }

  void incrementCarbs(int amount) {
    _carbs += amount;
    notifyListeners();
  }

  void decrementCarbs(int amount) {
    _carbs = max(_carbs - amount, 0);
    notifyListeners();
  }

  void incrementFat(int amount) {
    _fat += amount;
    notifyListeners();
  }

  void decrementFat(int amount) {
    _fat = max(_fat - amount, 0);
    notifyListeners();
  }

  void incrementWater(int amount) {
    _water += amount;
    notifyListeners();
  }

  void decrementWater(int amount) {
    _water = max(_water - amount, 0);
    notifyListeners();
  }

  void incrementFiber(int amount) {
    _fiber += amount;
    notifyListeners();
  }

  void decrementFiber(int amount) {
    _fiber = max(_fiber - amount, 0);
    notifyListeners();
  }

  void incrementSodium(int amount) {
    _sodium += amount;
    notifyListeners();
  }

  void decrementSodium(int amount) {
    _sodium = max(_sodium - amount, 0);
    notifyListeners();
  }

  void incrementCalcium(int amount) {
    _calcium += amount;
    notifyListeners();
  }

  void decrementCalcium(int amount) {
    _calcium = max(_calcium - amount, 0);
    notifyListeners();
  }

  void incrementIron(int amount) {
    _iron += amount;
    notifyListeners();
  }

  void decrementIron(int amount) {
    _iron = max(_iron - amount, 0);
    notifyListeners();
  }

  void incrementVitaminC(int amount) {
    _vitaminC += amount;
    notifyListeners();
  }

  void decrementVitaminC(int amount) {
    _vitaminC = max(_vitaminC - amount, 0);
    notifyListeners();
  }
}

class DietScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DietScreenProvider(),
      child: Consumer<DietScreenProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Daily Diet'),
            ),
            body: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDietItem(
                    label: 'Calories',
                    value: provider.calories,
                    onIncrement: () => provider.incrementCalories(100),
                    onDecrement: () => provider.decrementCalories(100),
                  ),
                  SizedBox(height: 16.0),
                  _buildDietItem(
                    label: 'Protein (g)',
                    value: provider.protein,
                    onIncrement: () => provider.incrementProtein(5),
                    onDecrement: () => provider.decrementProtein(5),
                  ),
                  SizedBox(height: 16.0),
                  _buildDietItem(
                    label: 'Carbs (g)',
                    value: provider.carbs,
                    onIncrement: () => provider.incrementCarbs(10),
                    onDecrement: () => provider.decrementCarbs(10),
                  ),
                  SizedBox(height: 16.0),
                  _buildDietItem(
                    label: 'Fat (g)',
                    value: provider.fat,
                    onIncrement: () => provider.incrementFat(5),
                    onDecrement: () => provider.decrementFat(5),
                  ),
                  SizedBox(height: 16.0),
                  _buildDietItem(
                    label: 'Water (ml)',
                    value: provider.water,
                    onIncrement: () => provider.incrementWater(100),
                    onDecrement: () => provider.decrementWater(100),
                  ),
                  SizedBox(height: 16.0),
                  _buildDietItem(
                    label: 'Fiber (g)',
                    value: provider.fiber,
                    onIncrement: () => provider.incrementFiber(5),
                    onDecrement: () => provider.decrementFiber(5),
                  ),
                  SizedBox(height: 16.0),
                  _buildDietItem(
                    label: 'Sodium (mg)',
                    value: provider.sodium,
                    onIncrement: () => provider.incrementSodium(100),
                    onDecrement: () => provider.decrementSodium(100),
                  ),
                  SizedBox(height: 16.0),
                  _buildDietItem(
                    label: 'Calcium (mg)',
                    value: provider.calcium,
                    onIncrement: () => provider.incrementCalcium(100),
                    onDecrement: () => provider.decrementCalcium(100),
                  ),
                  SizedBox(height: 16.0),
                  _buildDietItem(
                    label: 'Iron (mg)',
                    value: provider.iron,
                    onIncrement: () => provider.incrementIron(2),
                    onDecrement: () => provider.decrementIron(2),
                  ),
                  SizedBox(height: 16.0),
                  _buildDietItem(
                    label: 'Vitamin C (mg)',
                    value: provider.vitaminC,
                    onIncrement: () => provider.incrementVitaminC(10),
                    onDecrement: () => provider.decrementVitaminC(10),
                  ),
                  SizedBox(height: 16.0),
                  _buildCalorieCalculator(provider),
                  Expanded(child: SizedBox.shrink()),
                  _buildSummary(provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDietItem({
    required String label,
    required int value,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              IconButton(
  icon: Icon(LucideIcons.minus),
  onPressed: onDecrement,
),
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
  icon: Icon(LucideIcons.plus),
  onPressed: onIncrement,
),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieCalculator(DietScreenProvider provider) {
    final controller = TextEditingController();

    return Card(
      elevation: 2.0,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calorie Calculator',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter calories',
                suffixIcon: IconButton(
                   icon: Icon(LucideIcons.check),
                  onPressed: () {
                    int calories = int.tryParse(controller.text) ?? 0;
                    provider.logMeal(calories);
                    controller.clear();
                  },
                ),
              ),
              controller: controller,
            ),
            SizedBox(height: 8.0),
            Text(
              'Last meal: ${DateFormat('hh:mm a').format(provider.lastMealTime)}',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 8.0),
            if (provider.calories > provider.targetCalories)
              Text(
                'Calories over target',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.red,
                ),
              )
            else if (provider.calories < provider.targetCalories)
              Text(
                'Calories under target',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.green,
                ),
              )
            else
              Text(
                'Calories on target',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.blue,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(DietScreenProvider provider) {
    return Card(
      elevation: 2.0,
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            _buildSummaryItem(
              label: 'Calories',
              value: '${provider.calories}',
            ),
            _buildSummaryItem(
              label: 'Protein (g)',
              value: '${provider.protein}',
            ),
            _buildSummaryItem(
              label: 'Carbs (g)',
              value: '${provider.carbs}',
            ),
            _buildSummaryItem(
              label: 'Fat (g)',
              value: '${provider.fat}',
            ),
            _buildSummaryItem(
              label: 'Water (ml)',
              value: '${provider.water}',
            ),
            _buildSummaryItem(
              label: 'Fiber (g)',
              value: '${provider.fiber}',
            ),
            _buildSummaryItem(
              label: 'Sodium (mg)',
              value: '${provider.sodium}',
            ),
            _buildSummaryItem(
              label: 'Calcium (mg)',
              value: '${provider.calcium}',
            ),
            _buildSummaryItem(
              label: 'Iron (mg)',
              value: '${provider.iron}',
            ),
            _buildSummaryItem(
              label: 'Vitamin C (mg)',
              value: '${provider.vitaminC}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }
}