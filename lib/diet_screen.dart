import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
part 'diet_screen.g.dart'; // Add this to generate adapters
// Models
@HiveType(typeId: 0)
class Food extends HiveObject {
  @HiveField(0)
  String name;
  
  @HiveField(1)
  int calories;
  
  @HiveField(2)
  double protein;
  
  @HiveField(3)
  double carbs;
  
  @HiveField(4)
  double fats;
  
  @HiveField(5)
  String category; // protein, carb, vitamin, etc.

  Food({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.category,
  });
}

@HiveType(typeId: 1)
class Meal extends HiveObject {
  @HiveField(0)
  String type; // breakfast, lunch, dinner, snack
  
  @HiveField(1)
  DateTime timestamp;
  
  @HiveField(2)
  List<Food> foods;
  
  @HiveField(3)
  int totalCalories;
  
  @HiveField(4)
  double totalProtein;
  
  @HiveField(5)
  double totalCarbs;
  
  @HiveField(6)
  double totalFats;

  Meal({
    required this.type,
    required this.timestamp,
    required this.foods,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFats,
  });
}

// Main Screen
class ModernDietScreen extends StatefulWidget {
  @override
  _ModernDietScreenState createState() => _ModernDietScreenState();
}

class _ModernDietScreenState extends State<ModernDietScreen> {
  late Box<Food> foodBox;
  late Box<Meal> mealBox;
  late Box<Map> settingsBox;
  
  final int defaultCalorieGoal = 2000;
  final double defaultProteinGoal = 60;
  final double defaultCarbsGoal = 250;
  final double defaultFatsGoal = 70;

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(FoodAdapter());
    Hive.registerAdapter(MealAdapter());
    
    foodBox = await Hive.openBox<Food>('foods');
    mealBox = await Hive.openBox<Meal>('meals');
    settingsBox = await Hive.openBox('settings');
    
    if (foodBox.isEmpty) {
      await _initializeFoodDatabase();
    }
  }

  Future<void> _initializeFoodDatabase() async {
    // Add some common foods
    final commonFoods = [
      Food(
        name: 'Chicken Breast',
        calories: 165,
        protein: 31,
        carbs: 0,
        fats: 3.6,
        category: 'protein',
      ),
      Food(
        name: 'Brown Rice',
        calories: 216,
        protein: 5,
        carbs: 45,
        fats: 1.8,
        category: 'carb',
      ),
      // Add more common foods...
    ];
    
    for (var food in commonFoods) {
      await foodBox.add(food);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDailySummaryCard(),
                  SizedBox(height: 16),
                  _buildNutritionProgressCard(),
                  SizedBox(height: 16),
                  _buildQuickAddSection(),
                  SizedBox(height: 16),
                  _buildTodaysMealsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMealDialog,
        label: Text('Add Meal'),
        icon: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildAppBar() {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, MMMM d');
    final timeFormat = DateFormat('HH:mm');

    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Diet Tracker'),
            Text(
              '${dateFormat.format(now)} • ${timeFormat.format(now)}',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: _showSettingsDialog,
        ),
      ],
    );
  }

Widget _buildDailySummaryCard() {
  final totalCalories = _calculateTodaysTotalCalories();
  final calorieGoal = _getCalorieGoal(); // Ensure it's not null
  final remainingCalories = calorieGoal - totalCalories;

  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Summary',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                'Eaten',
                '$totalCalories',
                'kcal',
                Colors.green,
              ),
              _buildSummaryItem(
                'Remaining',
                '$remainingCalories',
                'kcal',
                Colors.blue,
              ),
              _buildSummaryItem(
                'Goal',
                '$calorieGoal',
                'kcal',
                Colors.purple,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}



  Widget _buildSummaryItem(
    String label,
    String value,
    String unit,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionProgressCard() {
    final totalNutrients = _calculateTodaysTotalNutrients();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nutrition Progress',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            _buildNutrientProgress(
              'Protein',
              totalNutrients['protein']!,
              defaultProteinGoal,
              Colors.red,
            ),
            SizedBox(height: 8),
            _buildNutrientProgress(
              'Carbs',
              totalNutrients['carbs']!,
              defaultCarbsGoal,
              Colors.green,
            ),
            SizedBox(height: 8),
            _buildNutrientProgress(
              'Fats',
              totalNutrients['fats']!,
              defaultFatsGoal,
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientProgress(
    String label,
    double value,
    double goal,
    Color color,
  ) {
    final percentage = (value / goal).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('${value.toStringAsFixed(1)}/${goal.toStringAsFixed(1)}g'),
          ],
        ),
        SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildQuickAddSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Add',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildQuickAddCard('🍳', 'Breakfast'),
              _buildQuickAddCard('🥗', 'Lunch'),
              _buildQuickAddCard('🍽️', 'Dinner'),
              _buildQuickAddCard('🫐', 'Snack'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAddCard(String emoji, String mealType) {
    return Card(
      child: InkWell(
        onTap: () => _showQuickAddDialog(mealType),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                emoji,
                style: TextStyle(fontSize: 32),
              ),
              SizedBox(height: 8),
              Text(mealType),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodaysMealsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Meals",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: 8),
        ValueListenableBuilder(
          valueListenable: mealBox.listenable(),
          builder: (context, Box<Meal> box, _) {
            final meals = _getTodaysMeals();
            
            if (meals.isEmpty) {
              return Center(
                child: Text(
                  'No meals logged today',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: meals.length,
              itemBuilder: (context, index) {
                final meal = meals[index];
                return _buildMealCard(meal);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildMealCard(Meal meal) {
    final timeFormat = DateFormat('HH:mm');

    return Card(
      child: ListTile(
        leading: _getMealTypeIcon(meal.type),
        title: Text(meal.type),
        subtitle: Text(
          '${meal.foods.map((f) => f.name).join(', ')}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${meal.totalCalories} kcal',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Text(
              timeFormat.format(meal.timestamp),
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        onTap: () => _showMealDetails(meal),
      ),
    );
  }

  Icon _getMealTypeIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icon(Icons.breakfast_dining);
      case 'lunch':
        return Icon(Icons.lunch_dining);
      case 'dinner':
        return Icon(Icons.dinner_dining);
      default:
        return Icon(Icons.fastfood);
    }
  }

  void _showAddMealDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddMealSheet(
        foodBox: foodBox,
        onSave: _saveMeal,
      ),
    );
  }

  void _showQuickAddDialog(String mealType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => QuickAddSheet(
        mealType: mealType,
        foodBox: foodBox,
        onSave: _saveMeal,
      ),
    );
  }

  void _showMealDetails(Meal meal) {
    showModalBottomSheet(
      context: context,
      builder: (context) => MealDetailsSheet(meal: meal),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => SettingsDialog(
        settingsBox: settingsBox,
        onSave: () => setState(() {}),
      ),
    );
  }

  void _saveMeal(Meal meal) {
    mealBox.add(meal);
    setState(() {});
  }

int _getCalorieGoal() {
  // Ensure the return type is explicitly an int, not Object
  return (settingsBox.get('calorieGoal') ?? defaultCalorieGoal) as int;
}





  int _calculateTodaysTotalCalories() {
    return _getTodaysMeals().fold(0, (sum, meal) => sum + meal.totalCalories);
  }

  Map<String, double> _calculateTodaysTotalNutrients() {
    final meals = _getTodaysMeals();
    return {
      'protein': meals.fold(0.0, (sum, meal) => sum + meal.totalProtein),
      'carbs': meals.fold(0.0, (sum, meal) => sum + meal.totalCarbs),
      'fats': meals.fold(0.0, (sum, meal) => sum + meal.totalFats),
    };
  }

  List<Meal> _getTodaysMeals() {
    final now = DateTime.now();
    return mealBox.values.where((meal) =>
        meal.timestamp.year == now.year &&
        meal.timestamp.month== now.month &&
        meal.timestamp.day == now.day).toList();
  }
}

// Additional widgets for sheets and dialogs

class AddMealSheet extends StatefulWidget {
  final Box<Food> foodBox;
  final Function(Meal) onSave;

  AddMealSheet({required this.foodBox, required this.onSave});

  @override
  _AddMealSheetState createState() => _AddMealSheetState();
}

class _AddMealSheetState extends State<AddMealSheet> {
  final _formKey = GlobalKey<FormState>();
  String _mealType = 'Breakfast';
  List<Food> _selectedFoods = [];
  DateTime _timestamp = DateTime.now();

  int get _totalCalories =>
      _selectedFoods.fold(0, (sum, food) => sum + food.calories);
  double get _totalProtein =>
      _selectedFoods.fold(0.0, (sum, food) => sum + food.protein);
  double get _totalCarbs =>
      _selectedFoods.fold(0.0, (sum, food) => sum + food.carbs);
  double get _totalFats =>
      _selectedFoods.fold(0.0, (sum, food) => sum + food.fats);

  void _save() {
    if (_selectedFoods.isNotEmpty) {
      final meal = Meal(
        type: _mealType,
        timestamp: _timestamp,
        foods: _selectedFoods,
        totalCalories: _totalCalories,
        totalProtein: _totalProtein,
        totalCarbs: _totalCarbs,
        totalFats: _totalFats,
      );
      widget.onSave(meal);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _mealType,
              items: ['Breakfast', 'Lunch', 'Dinner', 'Snack']
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _mealType = value!),
              decoration: InputDecoration(labelText: 'Meal Type'),
            ),
            ValueListenableBuilder(
              valueListenable: widget.foodBox.listenable(),
              builder: (context, Box<Food> box, _) {
                final foods = box.values.toList();
                return Wrap(
                  spacing: 8.0,
                  children: foods.map((food) {
                    return ChoiceChip(
                      label: Text(food.name),
                      selected: _selectedFoods.contains(food),
                      onSelected: (isSelected) {
                        setState(() {
                          isSelected
                              ? _selectedFoods.add(food)
                              : _selectedFoods.remove(food);
                        });
                      },
                    );
                  }).toList(),
                );
              },
            ),
            ElevatedButton(
              onPressed: _save,
              child: Text('Save Meal'),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickAddSheet extends StatelessWidget {
  final String mealType;
  final Box<Food> foodBox;
  final Function(Meal) onSave;

  QuickAddSheet({
    required this.mealType,
    required this.foodBox,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return AddMealSheet(
      foodBox: foodBox,
      onSave: (meal) => onSave(
        Meal(
          type: mealType,
          timestamp: now,
          foods: meal.foods,
          totalCalories: meal.totalCalories,
          totalProtein: meal.totalProtein,
          totalCarbs: meal.totalCarbs,
          totalFats: meal.totalFats,
        ),
      ),
    );
  }
}

class MealDetailsSheet extends StatelessWidget {
  final Meal meal;

  MealDetailsSheet({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            meal.type,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(DateFormat('HH:mm').format(meal.timestamp)),
          SizedBox(height: 8),
          Column(
            children: meal.foods.map((food) {
              return ListTile(
                title: Text(food.name),
                subtitle: Text(
                  '${food.calories} kcal, ${food.protein}g Protein, ${food.carbs}g Carbs, ${food.fats}g Fats',
                ),
              );
            }).toList(),
          ),
          Divider(),
          Text('Total: ${meal.totalCalories} kcal'),
        ],
      ),
    );
  }
}

class SettingsDialog extends StatefulWidget {
  final Box<Map> settingsBox;
  final VoidCallback onSave;

  SettingsDialog({required this.settingsBox, required this.onSave});

  @override
  _SettingsDialogState createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late TextEditingController calorieController;
  late TextEditingController proteinController;
  late TextEditingController carbsController;
  late TextEditingController fatsController;

  @override
  void initState() {
    super.initState();
    calorieController = TextEditingController(
      text: widget.settingsBox.get('calorieGoal')?.toString() ?? '2000',
    );
    proteinController = TextEditingController(
      text: widget.settingsBox.get('proteinGoal')?.toString() ?? '60',
    );
    carbsController = TextEditingController(
      text: widget.settingsBox.get('carbsGoal')?.toString() ?? '250',
    );
    fatsController = TextEditingController(
      text: widget.settingsBox.get('fatsGoal')?.toString() ?? '70',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Settings'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            _buildGoalField('Calorie Goal', calorieController),
            _buildGoalField('Protein Goal', proteinController),
            _buildGoalField('Carbs Goal', carbsController),
            _buildGoalField('Fats Goal', fatsController),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveSettings,
          child: Text('Save'),
        ),
      ],
    );
  }

  Widget _buildGoalField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        keyboardType: TextInputType.number,
      ),
    );
  }

  void _saveSettings() {
    widget.settingsBox.put('calorieGoal', int.parse(calorieController.text) as Map);
    widget.settingsBox.put('proteinGoal', double.parse(proteinController.text) as Map);
    widget.settingsBox.put('carbsGoal', double.parse(carbsController.text) as Map);
    widget.settingsBox.put('fatsGoal', double.parse(fatsController.text) as Map);
    widget.onSave();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    calorieController.dispose();
    proteinController.dispose();
    carbsController.dispose();
    fatsController.dispose();
    super.dispose();
  }
}