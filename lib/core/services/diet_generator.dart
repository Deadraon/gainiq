import '../../models/diet_model.dart';
import '../../models/user_model.dart';
import 'food_database.dart';

export 'food_database.dart' show FoodItem;

// ─────────────────────────────────────────────────────────────
//  BMR + TDEE CALCULATOR
// ─────────────────────────────────────────────────────────────
class CalorieCalculator {
  static int dailyCalories(UserModel user) {
    // Mifflin-St Jeor BMR
    double bmr;
    if (user.gender.toLowerCase() == 'female') {
      bmr = (10 * user.weight) + (6.25 * user.height) - (5 * user.age) - 161;
    } else {
      bmr = (10 * user.weight) + (6.25 * user.height) - (5 * user.age) + 5;
    }

    // Activity multiplier based on workout location
    double activityMultiplier;
    switch (user.workoutLocation.toLowerCase()) {
      case 'gym':
        activityMultiplier = 1.55;
        break;
      case 'home':
        activityMultiplier = 1.375;
        break;
      case 'outdoor':
        activityMultiplier = 1.5;
        break;
      default:
        activityMultiplier = 1.45;
    }
    double tdee = bmr * activityMultiplier;

    // Goal-based calorie adjustment
    switch (user.primaryGoal.toLowerCase()) {
      case 'bulking':
        return (tdee + 400).round();
      case 'cutting':
        return (tdee - 400).round();
      case 'weight loss':
        return (tdee - 500).round();
      case 'lean muscle':
        return (tdee + 200).round();
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
      case 'lean muscle':
        multiplier = 2.3;
        break;
      default:
        multiplier = 1.8;
    }
    return (user.weight * multiplier).round();
  }

  // Macro split ratios per goal
  static Map<String, double> macroRatios(String goal) {
    switch (goal.toLowerCase()) {
      case 'bulking':
        return {'carbs': 0.50, 'protein': 0.25, 'fat': 0.25};
      case 'cutting':
      case 'weight loss':
        return {'carbs': 0.35, 'protein': 0.40, 'fat': 0.25};
      case 'lean muscle':
        return {'carbs': 0.45, 'protein': 0.30, 'fat': 0.25};
      default:
        return {'carbs': 0.45, 'protein': 0.25, 'fat': 0.30};
    }
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

    final ratios = CalorieCalculator.macroRatios(user.primaryGoal);
    final targetCarbs = ((targetCalories * ratios['carbs']!) / 4).round();
    final targetFat = ((targetCalories * ratios['fat']!) / 9).round();

    // Daily budget: use actual monthly budget or fall back to ₹150/day
    final double dailyBudget =
        user.monthlyBudget > 0 ? (user.monthlyBudget / 30) : 150.0;

    // Build allowed diet tags strictly per preference
    final allowedDietTags = _getAllowedDietTags(user.dietPreference);

    // Filter allergens
    final allergies = user.allergies.toLowerCase();

    // Build meals
    final meals = _buildMeals(
      user: user,
      dailyBudget: dailyBudget,
      targetCalories: targetCalories.toDouble(),
      targetProtein: targetProtein.toDouble(),
      targetCarbs: targetCarbs.toDouble(),
      targetFat: targetFat.toDouble(),
      allowedDietTags: allowedDietTags,
      allergies: allergies,
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

  // ── STRICT diet tag filtering ──────────────────────────────
  static List<String> _getAllowedDietTags(String pref) {
    switch (pref.toLowerCase()) {
      case 'non-vegetarian':
      case 'nonvegetarian':
      case 'non vegetarian':
        return ['veg', 'egg', 'nonveg'];
      case 'eggetarian':
      case 'eggeterian':
      case 'egg':
        return ['veg', 'egg'];
      case 'vegetarian':
      case 'veg':
      default:
        return ['veg']; // ONLY veg items for vegetarians
    }
  }

  // ── MEAL SLOT definitions with budget & protein split ──────
  static List<Map<String, dynamic>> _mealSlots(String goal, String timing) {
    // Adjust meal timing if user works out in morning
    final isMorningWorkout = timing.toLowerCase().contains('morning');
    return [
      {
        'id': 'breakfast',
        'title': 'Breakfast',
        'time': isMorningWorkout ? '7:00 AM' : '8:00 AM',
        'emoji': '☀️',
        'budgetPct': 0.22,
        'proteinPct': 0.25,
        'caloriePct': 0.25,
      },
      {
        'id': 'lunch',
        'title': 'Lunch',
        'time': '1:00 PM',
        'emoji': '🌤',
        'budgetPct': goal == 'bulking' ? 0.35 : 0.30,
        'proteinPct': goal == 'bulking' ? 0.35 : 0.30,
        'caloriePct': goal == 'bulking' ? 0.35 : 0.30,
      },
      {
        'id': 'snack',
        'title': isMorningWorkout ? 'Post-Workout Snack' : 'Pre-Workout Snack',
        'time': isMorningWorkout ? '10:30 AM' : '5:00 PM',
        'emoji': '⚡',
        'budgetPct': 0.15,
        'proteinPct': 0.15,
        'caloriePct': 0.15,
      },
      {
        'id': 'dinner',
        'title': 'Dinner',
        'time': '8:30 PM',
        'emoji': '🌙',
        'budgetPct': 0.28,
        'proteinPct': 0.30,
        'caloriePct': 0.30,
      },
    ];
  }

  static List<MealModel> _buildMeals({
    required UserModel user,
    required double dailyBudget,
    required double targetCalories,
    required double targetProtein,
    required double targetCarbs,
    required double targetFat,
    required List<String> allowedDietTags,
    required String allergies,
  }) {
    // Filter the database: ONLY foods whose diet tag matches
    final allowed = indianFoodDB.where((f) {
      // Must have at least one diet tag that is in allowedDietTags
      final hasDietTag =
          f.tags.any((t) => allowedDietTags.contains(t));
      // Must not contain allergen
      final hasAllergen = allergies.isNotEmpty &&
          f.allergen != null &&
          allergies.contains(f.allergen!.toLowerCase());
      return hasDietTag && !hasAllergen;
    }).toList();

    final slots = _mealSlots(user.primaryGoal, user.workoutTiming);

    return slots.map((slot) {
      final id = slot['id'] as String;
      return _buildMeal(
        id: id,
        title: slot['title'] as String,
        time: slot['time'] as String,
        emoji: slot['emoji'] as String,
        budget: dailyBudget * (slot['budgetPct'] as double),
        proteinTarget: targetProtein * (slot['proteinPct'] as double),
        calorieTarget: targetCalories * (slot['caloriePct'] as double),
        mealTag: id,
        allowedFoods: allowed,
        goal: user.primaryGoal,
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
    required double calorieTarget,
    required String mealTag,
    required List<FoodItem> allowedFoods,
    required String goal,
  }) {
    // Foods that belong to this meal slot
    var candidates = allowedFoods
        .where((f) => f.tags.contains(mealTag))
        .toList();

    if (candidates.isEmpty) {
      return MealModel(id: id, title: title, time: time, emoji: emoji);
    }

    // Scoring: prioritise differently by goal
    candidates.sort((a, b) {
      double scoreA, scoreB;
      final isLoss = goal.toLowerCase().contains('loss') ||
          goal.toLowerCase().contains('cut');
      if (isLoss) {
        // For cutting: maximise protein/calorie density, respect budget
        scoreA = (a.protein / (a.calories + 1)) * (100 / (a.costPerServing + 1));
        scoreB = (b.protein / (b.calories + 1)) * (100 / (b.costPerServing + 1));
      } else {
        // For bulking/maintenance: maximise protein/rupee
        scoreA = a.protein / (a.costPerServing + 1);
        scoreB = b.protein / (b.costPerServing + 1);
      }
      return scoreB.compareTo(scoreA);
    });

    final selected = <FoodItem>[];
    double usedBudget = 0;
    double usedProtein = 0;
    double usedCalories = 0;
    double usedCarbs = 0;
    double usedFat = 0;

    // Select items greedily within budget, targeting protein & calories
    for (final food in candidates) {
      if (selected.length >= 3) break; // max 3 items per meal
      final budgetOk = usedBudget + food.costPerServing <= budget + 10;
      if (budgetOk) {
        selected.add(food);
        usedBudget += food.costPerServing;
        usedProtein += food.protein;
        usedCalories += food.calories;
        usedCarbs += food.carbs;
        usedFat += food.fat;
        // Stop once protein & calorie targets met with at least 1 item
        if (selected.length >= 1 &&
            usedProtein >= proteinTarget &&
            usedCalories >= calorieTarget * 0.85) break;
      }
    }

    // Fallback: pick best item if budget too tight
    if (selected.isEmpty) {
      selected.add(candidates.first);
      usedBudget = candidates.first.costPerServing;
      usedProtein = candidates.first.protein;
      usedCalories = candidates.first.calories.toDouble();
      usedCarbs = candidates.first.carbs;
      usedFat = candidates.first.fat;
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
      calories: usedCalories.round(),
      proteinGrams: usedProtein.round(),
      carbsGrams: usedCarbs.round(),
      fatGrams: usedFat.round(),
      cost: usedBudget,
    );
  }
}
