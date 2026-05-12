import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/diet_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../models/diet_model.dart';

class DietPlanScreen extends StatefulWidget {
  const DietPlanScreen({super.key});

  @override
  State<DietPlanScreen> createState() => _DietPlanScreenState();
}

class _DietPlanScreenState extends State<DietPlanScreen> {
  int _expandedIdx = 0;

  Widget _tagDot(Color color) => Container(
        width: 5,
        height: 5,
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  @override
  Widget build(BuildContext context) {
    final dietProvider = context.watch<DietProvider>();
    final diet = dietProvider.currentDietPlan;
    final user = context.watch<UserProvider>().currentUser;

    // ── AI Loading Screen ─────────────────────────────────────
    if (diet == null || dietProvider.isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5FF00).withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE5FF00).withOpacity(0.4), width: 2),
                ),
                child: const Icon(Icons.auto_awesome, color: Color(0xFFE5FF00), size: 36),
              ),
              const SizedBox(height: 24),
              Text('GainIQ AI', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 8),
              Text(
                dietProvider.statusMessage.isNotEmpty
                    ? dietProvider.statusMessage
                    : '✨ Crafting your personalized diet plan...',
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5), fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              const SizedBox(
                width: 180,
                child: LinearProgressIndicator(
                  color: Color(0xFFE5FF00),
                  backgroundColor: Colors.white10,
                  minHeight: 3,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final int totalCals = diet.meals.fold(0, (int s, m) => s + (m.calories));
    final int totalProtein = diet.meals.fold(0, (int s, m) => s + (m.proteinGrams));
    final int totalCarbs = diet.meals.fold(0, (int s, m) => s + (m.carbsGrams));
    final int totalFat = diet.meals.fold(0, (int s, m) => s + (m.fatGrams));
    final double totalCost = diet.meals.fold(0.0, (double s, m) => s + (m.cost));


    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── HEADER ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('Your Diet Plan',
                                      style: TextStyle(
                                          color: Theme.of(context).textTheme.bodyLarge?.color,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.5,
                                          fontSize: 26)),
                                  if (dietProvider.isAIGenerated) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE5FF00).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text('✨ GainIQ AI', style: TextStyle(color: Color(0xFFE5FF00), fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                user != null
                                    ? '${user.primaryGoal} • ${user.dietPreference}'
                                    : 'Personalised for you',
                                style: TextStyle(
                                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5), fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        // Regenerate button (small)
                        if (user != null)
                          IconButton(
                            onPressed: () => context.read<DietProvider>().regenerate(user),
                            icon: const Icon(Icons.refresh_rounded, color: Color(0xFFE5FF00)),
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFFE5FF00).withOpacity(0.1),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── MACRO SUMMARY CARD ─────────────────────────────
                    _MacroSummaryCard(
                      totalCals: totalCals,
                      targetCals: diet.targetCalories,
                      protein: totalProtein,
                      targetProtein: diet.targetProtein,
                      carbs: totalCarbs,
                      targetCarbs: diet.targetCarbs,
                      fat: totalFat,
                      targetFat: diet.targetFat,
                      estimatedCost: totalCost,
                    ),
                    const SizedBox(height: 32),
                    
                    Text('Today\'s Meals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ── MEAL CARDS ───────────────────────────────────────────
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: _MealCard(
                    meal: diet.meals[i],
                    index: i,
                  ),
                ),
                childCount: diet.meals.length,
              ),
            ),

            // ── TIPS ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
                child: _TipsCard(user: user),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// MACRO SUMMARY CARD
// ─────────────────────────────────────────────────────────────
class _MacroSummaryCard extends StatelessWidget {
  final int totalCals, targetCals, protein, targetProtein, carbs, targetCarbs, fat, targetFat;
  final double estimatedCost;
  const _MacroSummaryCard({
    required this.totalCals, required this.targetCals,
    required this.protein, required this.targetProtein,
    required this.carbs, required this.targetCarbs,
    required this.fat, required this.targetFat,
    required this.estimatedCost,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$totalCals', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: -1)),
              const SizedBox(width: 4),
              Text('kcal', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5), fontSize: 16, fontWeight: FontWeight.w600)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5FF00).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('₹${estimatedCost.toInt()} est.', style: const TextStyle(color: Color(0xFFE5FF00), fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _simpleMacro(context, 'Protein', protein, targetProtein, 'g', Colors.blueAccent),
              _simpleMacro(context, 'Carbs', carbs, targetCarbs, 'g', Colors.greenAccent),
              _simpleMacro(context, 'Fat', fat, targetFat, 'g', Colors.pinkAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _simpleMacro(BuildContext context, String label, int val, int target, String unit, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5), fontSize: 12)),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('$val', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20, fontWeight: FontWeight.bold)),
            Text(unit, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5), fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 60,
          child: LinearProgressIndicator(
            value: target > 0 ? (val / target).clamp(0.0, 1.0) : 0,
            backgroundColor: Theme.of(context).dividerColor.withOpacity(0.1),
            color: color,
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// MEAL CARD
// ─────────────────────────────────────────────────────────────
class _MealCard extends StatelessWidget {
  final MealModel meal;
  final int index;
  const _MealCard({required this.meal, required this.index});

  static const _mealColors = [Colors.amber, Colors.green, Colors.blueAccent, Colors.deepPurple];

  @override
  Widget build(BuildContext context) {
    final color = _mealColors[index % _mealColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal Header
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text(meal.emoji, style: const TextStyle(fontSize: 18))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(meal.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).textTheme.bodyLarge?.color)),
                    Text(meal.time, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5), fontSize: 13)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${meal.calories} kcal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Theme.of(context).textTheme.bodyLarge?.color)),
                  Text('₹${meal.cost.toInt()}', style: const TextStyle(color: Color(0xFFE5FF00), fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Food Items
          ...meal.foodItems.map((food) => _FoodItemRow(food: food, accentColor: color)),
          if (meal.foodItems.isEmpty)
             Text('No items generated', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.3), fontSize: 12)),
        ],
      ),
    );
  }
}

class _FoodItemRow extends StatelessWidget {
  final FoodItemDetail food;
  final Color accentColor;
  const _FoodItemRow({required this.food, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(food.name, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Text(food.serving, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6), fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${food.calories} kcal', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text('${food.protein.toInt()}g P', style: const TextStyle(color: Colors.blueAccent, fontSize: 11)),
                  const SizedBox(width: 8),
                  Text('₹${food.cost.toInt()}', style: const TextStyle(color: Color(0xFFE5FF00), fontSize: 11)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────
// TIPS CARD
// ─────────────────────────────────────────────────────────────
class _TipsCard extends StatelessWidget {
  final dynamic user;
  const _TipsCard({this.user});

  List<String> _getTips() {
    final goal = (user?.primaryGoal ?? '').toLowerCase();
    final diet = (user?.dietPreference ?? '').toLowerCase();

    // Diet-specific base tips
    final dietTips = diet.contains('veg') && !diet.contains('egg') && !diet.contains('non')
        ? ['🌱 Combine dal + rice or roti for complete protein', '🧀 Use paneer/tofu/soya as your primary protein source']
        : diet.contains('egg')
            ? ['🥚 Eggs are a complete protein — aim for 3–4 eggs/day', '🥛 Pair eggs with milk or curd for better amino acid profile']
            : ['🍗 Lean chicken breast has ~31g protein per 100g', '🐟 Include fish 3x/week for omega-3 & protein'];

    // Goal-specific tips
    final goalTips = goal == 'bulking'
        ? ['⏰ Eat every 3–4 hours to maximise protein synthesis', '🌙 Have curd/paneer before bed — slow-digesting protein', '💪 If not gaining in 2 weeks, add 200 kcal more per day']
        : goal.contains('cut') || goal.contains('loss')
            ? ['🥦 Fill half your plate with low-cal vegetables', '🥤 Drink water before meals to reduce appetite', '⚖️ Weigh weekly (same time) to track progress']
            : goal == 'lean muscle'
                ? ['🔄 Rotate protein sources daily for full amino coverage', '⏳ Eat within 30 min post-workout for recovery', '😴 Sleep 8h — growth hormone peaks during deep sleep']
                : ['🥛 Drink 2.5–3L water daily', '⏰ Don\'t skip meals — consistency is key', '🌿 Eat a rainbow of veggies for micronutrients'];

    return [...dietTips, ...goalTips];
  }

  @override
  Widget build(BuildContext context) {
    final tips = _getTips();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5FF00).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_rounded, color: Color(0xFFE5FF00), size: 18),
              SizedBox(width: 8),
              Text('Nutrition Tips',
                  style: TextStyle(
                      color: Color(0xFFE5FF00), fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 12),
          ...tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(tip,
                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13, height: 1.4)),
              )),
        ],
      ),
    );
  }
}
