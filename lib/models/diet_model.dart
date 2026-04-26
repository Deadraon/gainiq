class FoodItemDetail {
  final String name;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final String serving;
  final double cost;

  const FoodItemDetail({
    required this.name,
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.serving = '',
    this.cost = 0,
  });
}

class MealModel {
  final String id;
  final String title;
  final String time;
  final String emoji;
  final List<FoodItemDetail> foodItems;
  final int calories;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;
  final double cost;

  MealModel({
    required this.id,
    required this.title,
    required this.time,
    this.emoji = '🍽',
    this.foodItems = const [],
    this.calories = 0,
    this.proteinGrams = 0,
    this.carbsGrams = 0,
    this.fatGrams = 0,
    this.cost = 0,
  });

  // Backward-compat getter for HomeScreen meal schedule
  String get items =>
      foodItems.isNotEmpty ? foodItems.map((f) => f.name).join(', ') : '';
}

class DietPlanModel {
  final String id;
  final int targetCalories;
  final int targetProtein;
  final int targetCarbs;
  final int targetFat;
  final double dailyBudget;
  final List<MealModel> meals;

  DietPlanModel({
    required this.id,
    this.targetCalories = 2000,
    this.targetProtein = 150,
    this.targetCarbs = 200,
    this.targetFat = 65,
    this.dailyBudget = 0,
    this.meals = const [],
  });
}

