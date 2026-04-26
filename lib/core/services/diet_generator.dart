import '../../models/diet_model.dart';
import '../../models/user_model.dart';

// ─────────────────────────────────────────────────────────────
//  FOOD ITEM
// ─────────────────────────────────────────────────────────────
class FoodItem {
  final String name;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final double costPerServing;
  final String servingSize;
  final List<String> tags; // 'veg','egg','nonveg' + 'breakfast','lunch','dinner','snack'
  final String emoji;

  const FoodItem({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.costPerServing,
    required this.servingSize,
    required this.tags,
    this.emoji = '🍽',
  });
}

// ─────────────────────────────────────────────────────────────
//  EXPANDED INDIAN FOOD DATABASE (50+ items)
// ─────────────────────────────────────────────────────────────
const List<FoodItem> _indianFoodDB = [

  // ── BREAKFAST ──────────────────────────────────────────────
  FoodItem(name: 'Oats with Milk', calories: 280, protein: 11, carbs: 45, fat: 5, costPerServing: 18, servingSize: '50g oats + 200ml milk', tags: ['veg', 'breakfast'], emoji: '🥣'),
  FoodItem(name: 'Poha', calories: 250, protein: 5, carbs: 48, fat: 4, costPerServing: 10, servingSize: '1 cup', tags: ['veg', 'breakfast'], emoji: '🍚'),
  FoodItem(name: 'Upma', calories: 230, protein: 6, carbs: 42, fat: 5, costPerServing: 12, servingSize: '1 cup', tags: ['veg', 'breakfast'], emoji: '🫕'),
  FoodItem(name: 'Idli (3 pcs) + Sambar', calories: 270, protein: 9, carbs: 50, fat: 3, costPerServing: 15, servingSize: '3 idlis', tags: ['veg', 'breakfast', 'lunch'], emoji: '🍚'),
  FoodItem(name: 'Moong Dal Chilla (2)', calories: 200, protein: 14, carbs: 28, fat: 4, costPerServing: 12, servingSize: '2 chillas', tags: ['veg', 'breakfast', 'snack'], emoji: '🥞'),
  FoodItem(name: 'Besan Chilla (2)', calories: 220, protein: 12, carbs: 30, fat: 5, costPerServing: 10, servingSize: '2 chillas', tags: ['veg', 'breakfast', 'snack'], emoji: '🥞'),
  FoodItem(name: 'Whole Eggs (2)', calories: 140, protein: 12, carbs: 1, fat: 10, costPerServing: 14, servingSize: '2 eggs', tags: ['egg', 'nonveg', 'breakfast', 'snack'], emoji: '🍳'),
  FoodItem(name: 'Egg White Omelette (3 whites)', calories: 52, protein: 11, carbs: 1, fat: 0.3, costPerServing: 10, servingSize: '3 whites', tags: ['egg', 'nonveg', 'breakfast'], emoji: '🍳'),
  FoodItem(name: 'Scrambled Eggs (2)', calories: 180, protein: 14, carbs: 1, fat: 13, costPerServing: 20, servingSize: '2 eggs + milk', tags: ['egg', 'nonveg', 'breakfast'], emoji: '🍳'),
  FoodItem(name: 'Greek Yogurt', calories: 130, protein: 17, carbs: 9, fat: 0, costPerServing: 30, servingSize: '200g', tags: ['veg', 'breakfast', 'snack'], emoji: '🥛'),
  FoodItem(name: 'Curd / Dahi', calories: 120, protein: 8, carbs: 12, fat: 3, costPerServing: 12, servingSize: '200g', tags: ['veg', 'breakfast', 'lunch', 'dinner'], emoji: '🥛'),
  FoodItem(name: 'Peanut Butter Toast', calories: 310, protein: 12, carbs: 38, fat: 14, costPerServing: 25, servingSize: '2 slices + 2 tbsp PB', tags: ['veg', 'breakfast', 'snack'], emoji: '🍞'),
  FoodItem(name: 'Banana + Milk', calories: 250, protein: 9, carbs: 44, fat: 5, costPerServing: 18, servingSize: '1 banana + 250ml milk', tags: ['veg', 'breakfast', 'snack'], emoji: '🍌'),
  FoodItem(name: 'Whey Protein Shake', calories: 120, protein: 24, carbs: 3, fat: 1, costPerServing: 60, servingSize: '1 scoop + water', tags: ['veg', 'egg', 'nonveg', 'breakfast', 'snack'], emoji: '🥤'),

  // ── LUNCH ─────────────────────────────────────────────────
  FoodItem(name: 'Chicken Breast + Rice', calories: 380, protein: 38, carbs: 46, fat: 5, costPerServing: 55, servingSize: '150g chicken + 1 cup rice', tags: ['nonveg', 'lunch', 'dinner'], emoji: '🍗'),
  FoodItem(name: 'Chicken Curry + Roti (2)', calories: 420, protein: 32, carbs: 45, fat: 12, costPerServing: 60, servingSize: '1 bowl + 2 rotis', tags: ['nonveg', 'lunch', 'dinner'], emoji: '🍛'),
  FoodItem(name: 'Fish (Rohu/Catla) Curry + Rice', calories: 390, protein: 34, carbs: 44, fat: 10, costPerServing: 55, servingSize: '150g fish + 1 cup rice', tags: ['nonveg', 'lunch', 'dinner'], emoji: '🐟'),
  FoodItem(name: 'Egg Curry + Rice', calories: 360, protein: 22, carbs: 46, fat: 14, costPerServing: 35, servingSize: '2 eggs + 1 cup rice', tags: ['egg', 'nonveg', 'lunch', 'dinner'], emoji: '🥚'),
  FoodItem(name: 'Paneer Sabzi + Roti (2)', calories: 420, protein: 22, carbs: 44, fat: 20, costPerServing: 55, servingSize: '150g paneer + 2 rotis', tags: ['veg', 'lunch', 'dinner'], emoji: '🧀'),
  FoodItem(name: 'Dal + Rice', calories: 360, protein: 16, carbs: 68, fat: 4, costPerServing: 22, servingSize: '1 cup dal + 1 cup rice', tags: ['veg', 'lunch', 'dinner'], emoji: '🫘'),
  FoodItem(name: 'Rajma + Rice', calories: 380, protein: 18, carbs: 66, fat: 5, costPerServing: 20, servingSize: '1 cup rajma + 1 cup rice', tags: ['veg', 'lunch', 'dinner'], emoji: '🫘'),
  FoodItem(name: 'Chole (Chickpea Curry) + Roti', calories: 390, protein: 16, carbs: 60, fat: 8, costPerServing: 25, servingSize: '1 cup + 2 rotis', tags: ['veg', 'lunch', 'dinner'], emoji: '🫘'),
  FoodItem(name: 'Soya Chunks Curry + Rice', calories: 340, protein: 28, carbs: 48, fat: 4, costPerServing: 20, servingSize: '50g dry soya + 1 cup rice', tags: ['veg', 'lunch', 'dinner'], emoji: '🫘'),
  FoodItem(name: 'Palak Paneer + Roti (2)', calories: 400, protein: 20, carbs: 42, fat: 18, costPerServing: 50, servingSize: '150g + 2 rotis', tags: ['veg', 'lunch', 'dinner'], emoji: '🥬'),
  FoodItem(name: 'Tuna Salad', calories: 220, protein: 28, carbs: 10, fat: 6, costPerServing: 55, servingSize: '1 can tuna + veggies', tags: ['nonveg', 'lunch'], emoji: '🥗'),
  FoodItem(name: 'Mixed Veg Sabzi + Roti (2)', calories: 280, protein: 9, carbs: 48, fat: 6, costPerServing: 20, servingSize: '1 bowl + 2 rotis', tags: ['veg', 'lunch', 'dinner'], emoji: '🥗'),

  // ── SNACKS ────────────────────────────────────────────────
  FoodItem(name: 'Handful Almonds + Walnuts', calories: 180, protein: 5, carbs: 6, fat: 16, costPerServing: 25, servingSize: '30g mixed nuts', tags: ['veg', 'snack'], emoji: '🥜'),
  FoodItem(name: 'Banana + Peanut Butter', calories: 240, protein: 7, carbs: 36, fat: 9, costPerServing: 22, servingSize: '1 banana + 1 tbsp PB', tags: ['veg', 'snack'], emoji: '🍌'),
  FoodItem(name: 'Boiled Eggs (2)', calories: 140, protein: 12, carbs: 1, fat: 10, costPerServing: 14, servingSize: '2 eggs', tags: ['egg', 'nonveg', 'snack'], emoji: '🥚'),
  FoodItem(name: 'Sprouts Chaat', calories: 130, protein: 8, carbs: 22, fat: 1, costPerServing: 10, servingSize: '1 cup', tags: ['veg', 'snack'], emoji: '🌱'),
  FoodItem(name: 'Makhana (Fox Nuts)', calories: 100, protein: 4, carbs: 20, fat: 0.5, costPerServing: 15, servingSize: '30g', tags: ['veg', 'snack'], emoji: '🫘'),
  FoodItem(name: 'Sweet Potato (Boiled)', calories: 130, protein: 3, carbs: 30, fat: 0, costPerServing: 12, servingSize: '150g', tags: ['veg', 'snack'], emoji: '🍠'),
  FoodItem(name: 'Roasted Chana', calories: 120, protein: 7, carbs: 20, fat: 2, costPerServing: 8, servingSize: '30g', tags: ['veg', 'snack'], emoji: '🫘'),
  FoodItem(name: 'Paneer Cubes', calories: 133, protein: 9, carbs: 2, fat: 10, costPerServing: 18, servingSize: '50g', tags: ['veg', 'snack'], emoji: '🧀'),
  FoodItem(name: 'Fruit Bowl (Seasonal)', calories: 120, protein: 2, carbs: 28, fat: 0.5, costPerServing: 20, servingSize: '1 bowl mixed fruit', tags: ['veg', 'snack'], emoji: '🍉'),
  FoodItem(name: 'Chicken Tikka Skewer', calories: 200, protein: 28, carbs: 4, fat: 8, costPerServing: 50, servingSize: '150g', tags: ['nonveg', 'snack'], emoji: '🍢'),

  // ── DINNER / LIGHT ────────────────────────────────────────
  FoodItem(name: 'Grilled Chicken + Salad', calories: 300, protein: 38, carbs: 12, fat: 10, costPerServing: 65, servingSize: '200g chicken + salad', tags: ['nonveg', 'dinner'], emoji: '🥗'),
  FoodItem(name: 'Dal Khichdi', calories: 320, protein: 14, carbs: 56, fat: 5, costPerServing: 18, servingSize: '1 large bowl', tags: ['veg', 'dinner'], emoji: '🍲'),
  FoodItem(name: 'Paneer Bhurji + Roti (2)', calories: 380, protein: 22, carbs: 40, fat: 16, costPerServing: 45, servingSize: '150g + 2 rotis', tags: ['veg', 'dinner'], emoji: '🧀'),
  FoodItem(name: 'Egg Bhurji (3 eggs) + Roti', calories: 360, protein: 22, carbs: 38, fat: 18, costPerServing: 35, servingSize: '3 eggs + 2 rotis', tags: ['egg', 'nonveg', 'dinner'], emoji: '🍳'),
  FoodItem(name: 'Vegetable Soup + Roti', calories: 230, protein: 8, carbs: 40, fat: 4, costPerServing: 18, servingSize: '1 bowl soup + 2 rotis', tags: ['veg', 'dinner'], emoji: '🍵'),
  FoodItem(name: 'Chicken Soup', calories: 180, protein: 22, carbs: 10, fat: 5, costPerServing: 40, servingSize: '1 bowl', tags: ['nonveg', 'dinner'], emoji: '🍵'),
];

// ─────────────────────────────────────────────────────────────
//  BMR + TDEE CALCULATOR
// ─────────────────────────────────────────────────────────────
class CalorieCalculator {
  static int dailyCalories(UserModel user) {
    double bmr;
    if (user.gender.toLowerCase() == 'female') {
      bmr = (10 * user.weight) + (6.25 * user.height) - (5 * user.age) - 161;
    } else {
      bmr = (10 * user.weight) + (6.25 * user.height) - (5 * user.age) + 5;
    }

    // Activity multiplier
    double tdee;
    switch (user.workoutLocation.toLowerCase()) {
      case 'gym':
        tdee = bmr * 1.55; // Moderately active
        break;
      case 'home':
        tdee = bmr * 1.375; // Lightly active
        break;
      default:
        tdee = bmr * 1.45;
    }

    switch (user.primaryGoal.toLowerCase()) {
      case 'bulking':
        return (tdee + 350).round();
      case 'cutting':
        return (tdee - 400).round();
      case 'weight loss':
        return (tdee - 500).round();
      case 'maintenance':
      default:
        return tdee.round();
    }
  }

  static int dailyProtein(UserModel user) {
    double multiplier;
    switch (user.primaryGoal.toLowerCase()) {
      case 'bulking':
        multiplier = 2.2;
        break;
      case 'cutting':
        multiplier = 2.5;
        break;
      case 'weight loss':
        multiplier = 2.0;
        break;
      default:
        multiplier = 1.8;
    }
    return (user.weight * multiplier).round();
  }
}

// ─────────────────────────────────────────────────────────────
//  DIET GENERATOR
// ─────────────────────────────────────────────────────────────
class DietGenerator {
  static DietPlanModel generate(UserModel user) {
    final targetCalories = user.isProfileComplete
        ? CalorieCalculator.dailyCalories(user)
        : 2200;
    final targetProtein = user.isProfileComplete
        ? CalorieCalculator.dailyProtein(user)
        : 160;
    final targetCarbs = ((targetCalories * 0.45) / 4).round();
    final targetFat = ((targetCalories * 0.25) / 9).round();
    final dailyBudget = user.monthlyBudget > 0 ? user.monthlyBudget / 30 : 150;

    final allowedTags = _getAllowedTags(user.dietPreference);

    final meals = _buildMeals(
      dailyBudget: dailyBudget,
      targetProtein: targetProtein.toDouble(),
      targetCalories: targetCalories.toDouble(),
      allowedTags: allowedTags,
    );

    return DietPlanModel(
      id: 'plan_${user.id}',
      targetCalories: targetCalories,
      targetProtein: targetProtein,
      targetCarbs: targetCarbs,
      targetFat: targetFat,
      dailyBudget: dailyBudget,
      meals: meals,
    );
  }

  static List<String> _getAllowedTags(String pref) {
    switch (pref.toLowerCase()) {
      case 'non-vegetarian':
        return ['veg', 'egg', 'nonveg'];
      case 'eggetarian':
        return ['veg', 'egg'];
      default:
        return ['veg'];
    }
  }

  static List<MealModel> _buildMeals({
    required double dailyBudget,
    required double targetProtein,
    required double targetCalories,
    required List<String> allowedTags,
  }) {
    final allowed = _indianFoodDB
        .where((f) => f.tags.any((t) => allowedTags.contains(t)))
        .toList();

    // Budget splits
    final budgets = {'breakfast': 0.22, 'lunch': 0.35, 'snack': 0.12, 'dinner': 0.31};
    final proteinSplits = {'breakfast': 0.25, 'lunch': 0.35, 'snack': 0.10, 'dinner': 0.30};

    final mealDefs = [
      {'id': 'breakfast', 'title': 'Breakfast', 'time': '8:00 AM', 'emoji': '☀️'},
      {'id': 'lunch', 'title': 'Lunch', 'time': '1:30 PM', 'emoji': '🌤'},
      {'id': 'snack', 'title': 'Pre-Workout Snack', 'time': '5:00 PM', 'emoji': '⚡'},
      {'id': 'dinner', 'title': 'Dinner', 'time': '8:30 PM', 'emoji': '🌙'},
    ];

    return mealDefs.map((def) {
      final id = def['id']!;
      return _buildMeal(
        id: id,
        title: def['title']!,
        time: def['time']!,
        emoji: def['emoji']!,
        budget: dailyBudget * (budgets[id] ?? 0.25),
        proteinTarget: targetProtein * (proteinSplits[id] ?? 0.25),
        mealTag: id,
        allowedFoods: allowed,
      );
    }).toList();
  }

  static MealModel _buildMeal({
    required String id,
    required String title,
    required String time,
    required String emoji,
    required double budget,
    required double proteinTarget,
    required String mealTag,
    required List<FoodItem> allowedFoods,
  }) {
    // Filter to this meal slot
    var candidates = allowedFoods.where((f) => f.tags.contains(mealTag)).toList();

    // Sort by protein/rupee value descending
    candidates.sort((a, b) =>
        (b.protein / b.costPerServing).compareTo(a.protein / a.costPerServing));

    final selected = <FoodItem>[];
    double usedBudget = 0;
    double usedProtein = 0;
    int totalCals = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (final food in candidates) {
      if (usedBudget + food.costPerServing <= budget + 8) {
        selected.add(food);
        usedBudget += food.costPerServing;
        usedProtein += food.protein;
        totalCals += food.calories;
        totalCarbs += food.carbs;
        totalFat += food.fat;
        if (usedProtein >= proteinTarget && selected.length >= 2) break;
      }
    }

    if (selected.isEmpty && candidates.isNotEmpty) {
      selected.add(candidates.first);
      totalCals += candidates.first.calories;
      usedProtein += candidates.first.protein;
      totalCarbs += candidates.first.carbs;
      totalFat += candidates.first.fat;
    }

    return MealModel(
      id: id,
      title: title,
      time: time,
      emoji: emoji,
      foodItems: selected
          .map((f) => FoodItemDetail(
                name: f.name,
                calories: f.calories,
                protein: f.protein,
                carbs: f.carbs,
                fat: f.fat,
                serving: f.servingSize,
                cost: f.costPerServing,
              ))
          .toList(),
      calories: totalCals,
      proteinGrams: usedProtein.round(),
      carbsGrams: totalCarbs.round(),
      fatGrams: totalFat.round(),
      cost: usedBudget,
    );
  }
}
