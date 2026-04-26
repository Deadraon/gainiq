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
  int _expandedIdx = 0; // which meal card is open

  @override
  Widget build(BuildContext context) {
    final diet = context.watch<DietProvider>().currentDietPlan;
    final user = context.watch<UserProvider>().currentUser;

    if (diet == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFFE5FF00)),
              const SizedBox(height: 16),
              Text('Generating your diet plan...',
                  style: TextStyle(color: Colors.white.withOpacity(0.5))),
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
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── HEADER ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  children: [
                    // Title row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Your Diet Plan',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22)),
                            const SizedBox(height: 3),
                            Text(
                              user != null
                                  ? '${user.primaryGoal} • ${user.dietPreference}'
                                  : 'Personalised for you',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.45), fontSize: 13),
                            ),
                          ],
                        ),
                        // Budget pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5FF00).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE5FF00).withOpacity(0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.currency_rupee, color: Color(0xFFE5FF00), size: 14),
                              Text(
                                '${diet.dailyBudget.toInt()}/day',
                                style: const TextStyle(
                                    color: Color(0xFFE5FF00),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

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
                    const SizedBox(height: 20),

                    // ── AI badge ──────────────────────────────────────
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5FF00).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE5FF00).withOpacity(0.3)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.auto_awesome, color: Color(0xFFE5FF00), size: 13),
                              SizedBox(width: 5),
                              Text('AI-Generated  •  Indian Foods  •  Budget Optimised',
                                  style: TextStyle(
                                      color: Color(0xFFE5FF00), fontSize: 11, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ── MEAL CARDS ───────────────────────────────────────────
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                  child: _MealCard(
                    meal: diet.meals[i],
                    index: i,
                    isExpanded: _expandedIdx == i,
                    onToggle: () => setState(
                        () => _expandedIdx = _expandedIdx == i ? -1 : i),
                  ),
                ),
                childCount: diet.meals.length,
              ),
            ),

            // ── TIPS ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
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
    final calPct = (totalCals / targetCals).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        children: [
          // Calorie hero row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Daily Calories', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 3),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('$totalCals',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30)),
                      Text(' / $targetCals kcal',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.45), fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('≈ ₹${estimatedCost.toInt()} today',
                      style: const TextStyle(color: Color(0xFFE5FF00), fontSize: 12)),
                ],
              ),
              SizedBox(
                width: 68,
                height: 68,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: calPct,
                      backgroundColor: Colors.white10,
                      color: const Color(0xFFE5FF00),
                      strokeWidth: 6,
                    ),
                    Text(
                      '${(calPct * 100).toInt()}%',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: calPct,
              backgroundColor: Colors.white10,
              color: const Color(0xFFE5FF00),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 18),

          // Macro pills
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _macroPill('Protein', protein, targetProtein, 'g', Colors.blueAccent),
              _macroPill('Carbs', carbs, targetCarbs, 'g', Colors.greenAccent),
              _macroPill('Fat', fat, targetFat, 'g', Colors.pinkAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _macroPill(String label, int val, int target, String unit, Color color) {
    final pct = target > 0 ? (val / target).clamp(0.0, 1.0) : 0.0;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Text('$val$unit', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
              Text(' / $target$unit', style: TextStyle(color: color.withOpacity(0.5), fontSize: 11)),
            ],
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: 80,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: Colors.white10,
              color: color,
              minHeight: 3,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// MEAL CARD  (expandable)
// ─────────────────────────────────────────────────────────────
class _MealCard extends StatelessWidget {
  final MealModel meal;
  final int index;
  final bool isExpanded;
  final VoidCallback onToggle;
  const _MealCard({required this.meal, required this.index, required this.isExpanded, required this.onToggle});

  static const _mealColors = [Colors.amber, Colors.green, Colors.blueAccent, Colors.deepPurple];

  @override
  Widget build(BuildContext context) {
    final color = _mealColors[index % _mealColors.length];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isExpanded ? color.withOpacity(0.45) : Colors.white.withOpacity(0.06),
          width: isExpanded ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          // ── HEADER ──────────────────────────────────────────
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Emoji time badge
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(meal.emoji, style: const TextStyle(fontSize: 22)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(meal.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                        const SizedBox(height: 2),
                        Text(meal.time,
                            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                        const SizedBox(height: 5),
                        // Quick macro chips
                        Row(
                          children: [
                            _chip('${meal.calories} cal', Colors.orange),
                            const SizedBox(width: 6),
                            _chip('${meal.proteinGrams}g P', Colors.blueAccent),
                            const SizedBox(width: 6),
                            _chip('₹${meal.cost.toInt()}', const Color(0xFFE5FF00)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Chevron
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white.withOpacity(0.4),
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── EXPANDED CONTENT ─────────────────────────────────
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _ExpandedMealContent(meal: meal, color: color),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// EXPANDED MEAL CONTENT
// ─────────────────────────────────────────────────────────────
class _ExpandedMealContent extends StatelessWidget {
  final MealModel meal;
  final Color color;
  const _ExpandedMealContent({required this.meal, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(height: 1, color: Colors.white10),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Macros row
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _macroStat('${meal.calories}', 'kcal', Colors.orange),
                    _vDiv(),
                    _macroStat('${meal.proteinGrams}g', 'Protein', Colors.blueAccent),
                    _vDiv(),
                    _macroStat('${meal.carbsGrams}g', 'Carbs', Colors.greenAccent),
                    _vDiv(),
                    _macroStat('${meal.fatGrams}g', 'Fat', Colors.pinkAccent),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              const Text('What to eat:',
                  style: TextStyle(
                      color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w600,
                      letterSpacing: 0.5)),
              const SizedBox(height: 10),

              // Food items
              ...meal.foodItems.map((food) => _FoodItemRow(food: food, accentColor: color)),

              if (meal.foodItems.isEmpty)
                Text('No items generated — adjust your budget',
                    style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _macroStat(String val, String label, Color color) {
    return Column(
      children: [
        Text(val, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
      ],
    );
  }

  Widget _vDiv() => Container(height: 28, width: 1, color: Colors.white10);
}

// ─────────────────────────────────────────────────────────────
// FOOD ITEM ROW
// ─────────────────────────────────────────────────────────────
class _FoodItemRow extends StatelessWidget {
  final FoodItemDetail food;
  final Color accentColor;
  const _FoodItemRow({required this.food, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(food.name,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 2),
                Text(food.serving,
                    style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${food.calories} kcal',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w600)),
              Row(
                children: [
                  Text('${food.protein.toInt()}g P',
                      style: const TextStyle(color: Colors.blueAccent, fontSize: 10)),
                  const SizedBox(width: 6),
                  Text('₹${food.cost.toInt()}',
                      style: const TextStyle(color: Color(0xFFE5FF00), fontSize: 10)),
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
    if (goal == 'bulking') {
      return [
        '🥛 Drink 3–4L water daily',
        '⏰ Eat every 3–4 hours to keep protein synthesis high',
        '🌙 Have a casein-rich snack before bed (curd/paneer)',
        '💪 Add 5–10% more calories if not gaining weight in 2 weeks',
      ];
    } else if (goal.contains('cut') || goal.contains('loss')) {
      return [
        '🥦 Fill half your plate with vegetables',
        '🥤 Drink water before meals to reduce appetite',
        '⚖️ Weigh yourself weekly, same time each day',
        '🏃 Add 20 min light cardio on rest days for extra burn',
      ];
    }
    return [
      '🥛 Drink at least 2.5–3L water daily',
      '⏰ Don\'t skip meals — consistency is key',
      '🌿 Include a variety of colors in your meals',
      '😴 Sleep 7–8 hours — it affects metabolism',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tips = _getTips();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
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
                    style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 13, height: 1.4)),
              )),
        ],
      ),
    );
  }
}
