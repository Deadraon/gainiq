import 'dart:math';
import '../../models/diet_model.dart';
import '../../models/user_model.dart';
import 'food_database.dart';

export 'food_database.dart' show FoodItem;

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
//  SMART DIET GENERATOR
// ─────────────────────────────────────────────────────────────
class DietGenerator {
  static final _random = Random();

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

    final double dailyBudget =
        user.monthlyBudget > 0 ? (user.monthlyBudget / 30) : 150.0;

    final allowedDietTags = _getAllowedDietTags(user.dietPreference);
    final goalTag = _getGoalTag(user.primaryGoal);
    final allergies = user.allergies.toLowerCase();

    final meals = _buildMeals(
      user: user,
      dailyBudget: dailyBudget,
      targetCalories: targetCalories.toDouble(),
      targetProtein: targetProtein.toDouble(),
      targetCarbs: targetCarbs.toDouble(),
      targetFat: targetFat.toDouble(),
      allowedDietTags: allowedDietTags,
      goalTag: goalTag,
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

  // ── Goal tag mapping ───────────────────────────────────────
  static String _getGoalTag(String goal) {
    switch (goal.toLowerCase()) {
      case 'bulking':
        return 'bulking';
      case 'cutting':
        return 'cutting';
      case 'weight loss':
        return 'weight_loss';
      case 'lean muscle':
        return 'lean_muscle';
      default:
        return 'maintenance';
    }
  }

  // ── Diet tag filtering ─────────────────────────────────────
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
        return ['veg'];
    }
  }

  // ── Meal slots ─────────────────────────────────────────────
  static List<Map<String, dynamic>> _mealSlots(String goal, String timing) {
    final isMorningWorkout = timing.toLowerCase().contains('morning');
    final isBulking = goal.toLowerCase() == 'bulking';
    final isCutting = goal.toLowerCase().contains('cut') ||
        goal.toLowerCase().contains('loss');

    return [
      {
        'id': 'breakfast',
        'title': 'Breakfast',
        'time': isMorningWorkout ? '7:00 AM' : '8:00 AM',
        'emoji': '☀️',
        'budgetPct': 0.22,
        'proteinPct': isBulking ? 0.28 : 0.25,
        'caloriePct': isBulking ? 0.28 : 0.25,
      },
      {
        'id': 'lunch',
        'title': 'Lunch',
        'time': '1:00 PM',
        'emoji': '🌤',
        'budgetPct': isBulking ? 0.35 : 0.32,
        'proteinPct': isBulking ? 0.35 : 0.32,
        'caloriePct': isBulking ? 0.35 : 0.32,
      },
      {
        'id': 'snack',
        'title': isMorningWorkout ? 'Post-Workout Snack' : 'Pre-Workout Snack',
        'time': isMorningWorkout ? '10:30 AM' : '5:00 PM',
        'emoji': '⚡',
        'budgetPct': isCutting ? 0.12 : 0.15,
        'proteinPct': isCutting ? 0.18 : 0.15,
        'caloriePct': isCutting ? 0.12 : 0.15,
      },
      {
        'id': 'dinner',
        'title': 'Dinner',
        'time': '8:30 PM',
        'emoji': '🌙',
        'budgetPct': 0.28,
        'proteinPct': isCutting ? 0.28 : 0.28,
        'caloriePct': isCutting ? 0.26 : 0.28,
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
    required String goalTag,
    required String allergies,
  }) {
    // Filter foods: must match diet tag AND not contain allergen
    final allowed = indianFoodDB.where((f) {
      final hasDietTag = f.tags.any((t) => allowedDietTags.contains(t));
      final hasAllergen = allergies.isNotEmpty &&
          f.allergen != null &&
          allergies.contains(f.allergen!.toLowerCase());
      return hasDietTag && !hasAllergen;
    }).toList();

    final slots = _mealSlots(user.primaryGoal, user.workoutTiming);
    final usedFoodNames = <String>{};

    return slots.map((slot) {
      final id = slot['id'] as String;
      final meal = _buildMeal(
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
        goalTag: goalTag,
        dietPref: user.dietPreference.toLowerCase(),
        usedFoodNames: usedFoodNames,
      );
      // Track used foods for variety
      for (final item in meal.foodItems) {
        usedFoodNames.add(item.name);
      }
      return meal;
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
    required String goalTag,
    required String dietPref,
    required Set<String> usedFoodNames,
  }) {
    // Get candidates for this meal slot
    var candidates = allowedFoods
        .where((f) => f.tags.contains(mealTag))
        .toList();

    if (candidates.isEmpty) {
      return MealModel(id: id, title: title, time: time, emoji: emoji);
    }

    // Score foods based on goal + diet preference
    candidates.sort((a, b) {
      double scoreA = _scoreFood(a, goal, goalTag, id, dietPref, usedFoodNames, budget);
      double scoreB = _scoreFood(b, goal, goalTag, id, dietPref, usedFoodNames, budget);
      return scoreB.compareTo(scoreA);
    });

    // Add randomization — shuffle top candidates a bit for variety
    final topCount = min(candidates.length, 10);
    final topCandidates = candidates.sublist(0, topCount);
    topCandidates.shuffle(_random);
    // Re-sort with slight randomization weight
    topCandidates.sort((a, b) {
      double scoreA = _scoreFood(a, goal, goalTag, id, dietPref, usedFoodNames, budget);
      double scoreB = _scoreFood(b, goal, goalTag, id, dietPref, usedFoodNames, budget);
      // Add small random noise to prevent same order every time
      scoreA += _random.nextDouble() * 0.15;
      scoreB += _random.nextDouble() * 0.15;
      return scoreB.compareTo(scoreA);
    });
    candidates = [...topCandidates, ...candidates.sublist(topCount)];

    // Greedy selection within budget
    final selected = <FoodItem>[];
    double usedBudget = 0;
    double usedProtein = 0;
    double usedCalories = 0;
    double usedCarbs = 0;
    double usedFat = 0;

    final maxItems = _maxItemsForMeal(id, goal);

    for (final food in candidates) {
      if (selected.length >= maxItems) break;
      // Skip already used foods for variety
      if (usedFoodNames.contains(food.name)) continue;
      final budgetOk = usedBudget + food.costPerServing <= budget + 15;
      if (budgetOk) {
        selected.add(food);
        usedBudget += food.costPerServing;
        usedProtein += food.protein;
        usedCalories += food.calories;
        usedCarbs += food.carbs;
        usedFat += food.fat;
        if (selected.length >= 1 &&
            usedProtein >= proteinTarget * 0.85 &&
            usedCalories >= calorieTarget * 0.80) break;
      }
    }

    // Fallback: if nothing selected, pick first affordable item ignoring used
    if (selected.isEmpty) {
      for (final food in candidates) {
        if (food.costPerServing <= budget + 20) {
          selected.add(food);
          usedBudget = food.costPerServing;
          usedProtein = food.protein;
          usedCalories = food.calories.toDouble();
          usedCarbs = food.carbs;
          usedFat = food.fat;
          break;
        }
      }
      if (selected.isEmpty && candidates.isNotEmpty) {
        final food = candidates.first;
        selected.add(food);
        usedBudget = food.costPerServing;
        usedProtein = food.protein;
        usedCalories = food.calories.toDouble();
        usedCarbs = food.carbs;
        usedFat = food.fat;
      }
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

  // ── Smart food scorer ──────────────────────────────────────
  static double _scoreFood(
    FoodItem food,
    String goal,
    String goalTag,
    String mealId,
    String dietPref,
    Set<String> usedFoodNames,
    double mealBudget,
  ) {
    double score = 0;

    // 1. Goal-tag match bonus
    if (food.tags.contains(goalTag)) score += 3.0;

    // 2. Goal-specific scoring
    switch (goal.toLowerCase()) {
      case 'bulking':
        // High calories + high protein per rupee
        score += (food.calories / 100) * 0.5;
        score += (food.protein / (food.costPerServing + 1)) * 1.5;
        break;
      case 'cutting':
      case 'weight loss':
        // Max protein, min calories, min fat
        score += (food.protein / (food.calories + 1)) * 10;
        score -= (food.fat / 10) * 0.5;
        score += food.calories < 200 ? 1.0 : 0;
        break;
      case 'lean muscle':
        // Balanced protein density
        score += (food.protein / (food.calories + 1)) * 7;
        score += (food.protein / (food.costPerServing + 1)) * 1.0;
        break;
      default:
        // Balanced
        score += food.protein * 0.5;
        score -= (food.calories / 200) * 0.2;
    }

    // 3. Diet preference: strongly boost preferred protein sources
    if ((dietPref.contains('non') || dietPref.contains('egg')) &&
        (mealId == 'lunch' || mealId == 'dinner' || mealId == 'snack')) {
      if (dietPref.contains('non') && food.tags.contains('nonveg')) score += 8.0;
      if (dietPref.contains('egg') && food.tags.contains('egg')) score += 6.0;
    }

    // 4. Budget fit
    if (food.costPerServing <= mealBudget) score += 1.0;
    if (food.costPerServing > mealBudget * 1.5) score -= 2.0;

    // 5. Penalty for already-used foods (variety)
    if (usedFoodNames.contains(food.name)) score -= 10.0;

    return score;
  }

  // ── Max items per meal based on goal ──────────────────────
  static int _maxItemsForMeal(String mealId, String goal) {
    if (mealId == 'snack') return 2;
    switch (goal.toLowerCase()) {
      case 'bulking':
        return 3;
      case 'cutting':
      case 'weight loss':
        return 2;
      default:
        return 3;
    }
  }
}