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
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.serving,
    required this.cost,
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
    required this.calories,
    required this.proteinGrams,
    this.carbsGrams = 0,
    this.fatGrams = 0,
    this.cost = 0,
  });

  // Keep backward-compat items getter for HomeScreen
  String get items => foodItems.map((f) => f.name).join(', ');
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
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
    this.dailyBudget = 0,
    this.meals = const [],
  });
}
