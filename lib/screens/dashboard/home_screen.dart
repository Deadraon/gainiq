import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/workout_provider.dart';
import '../../core/providers/diet_provider.dart';
import '../workout/live_workout_screen.dart';
import '../workout/workout_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final workoutProvider = context.watch<WorkoutProvider>();
    final dietProvider = context.watch<DietProvider>();

    final user = userProvider.currentUser;
    final activePlan = workoutProvider.activePlan;
    final diet = dietProvider.currentDietPlan;

    final firstName = user?.name.split(' ').first ?? 'User';
    final initials = user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?';

    final totalCals = diet?.meals.fold(0, (sum, m) => sum + m.calories) ?? 0;
    final totalProtein = diet?.meals.fold(0, (sum, m) => sum + m.proteinGrams) ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── TOP HEADER ──────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('👋 ', style: TextStyle(fontSize: 18)),
                          Text(
                            'Hello, $firstName',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ready to crush today?',
                        style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 13),
                      ),
                    ],
                  ),
                  // Avatar → opens profile inline modal
                  GestureDetector(
                    onTap: () => _showProfilePanel(context),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFE5FF00),
                            const Color(0xFF9EBD00),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE5FF00).withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── STREAK + GOAL CARD ────────────────────────────────────
              _StreakCard(streak: user?.streak ?? 0, goal: user?.primaryGoal ?? 'Fitness'),
              const SizedBox(height: 20),

              // ── QUICK STATS ROW ──────────────────────────────────────
              Row(
                children: [
                  Expanded(child: _QuickStat(label: 'Goal', value: user?.primaryGoal ?? '–', icon: Icons.flag_rounded, color: const Color(0xFFE5FF00))),
                  const SizedBox(width: 10),
                  Expanded(child: _QuickStat(label: 'Level', value: user?.experienceLevel ?? '–', icon: Icons.trending_up_rounded, color: Colors.blueAccent)),
                  const SizedBox(width: 10),
                  Expanded(child: _QuickStat(label: 'Weight', value: user?.weight != null ? '${user!.weight.toInt()} kg' : '–', icon: Icons.monitor_weight_outlined, color: Colors.purpleAccent)),
                ],
              ),
              const SizedBox(height: 24),

              // ── TODAY'S WORKOUT ──────────────────────────────────────
              _SectionHeader(
                title: "Today's Workout",
                onSeeAll: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WorkoutListScreen())),
              ),
              const SizedBox(height: 12),
              if (activePlan != null)
                _WorkoutCard(
                  title: activePlan.title,
                  subtitle: activePlan.subtitle,
                  exerciseCount: activePlan.exercises.length,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LiveWorkoutScreen()),
                  ),
                )
              else
                _EmptyCard(label: 'No workout assigned yet'),
              const SizedBox(height: 24),

              // ── NUTRITION ───────────────────────────────────────────
              const _SectionHeader(title: 'Today\'s Nutrition'),
              const SizedBox(height: 12),
              _NutritionCard(
                consumed: totalCals,
                target: diet?.targetCalories ?? 2500,
                protein: totalProtein,
                targetProtein: diet?.targetProtein ?? 160,
                carbs: diet?.targetCarbs ?? 250,
                fat: diet?.targetFat ?? 60,
              ),
              const SizedBox(height: 24),

              // ── MEALS PREVIEW ────────────────────────────────────────
              if (diet != null && diet.meals.isNotEmpty) ...[
                const _SectionHeader(title: 'Meal Schedule'),
                const SizedBox(height: 12),
                ...diet.meals.take(2).map((m) => _MealPreviewTile(
                      title: m.title,
                      time: m.time,
                      calories: m.calories,
                      protein: m.proteinGrams,
                    )),
                const SizedBox(height: 8),
              ],

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showProfilePanel(BuildContext context) {
    final user = context.read<UserProvider>().currentUser;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProfilePanel(user: user),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STREAK CARD
// ─────────────────────────────────────────────────────────────────────────────
class _StreakCard extends StatelessWidget {
  final int streak;
  final String goal;
  const _StreakCard({required this.streak, required this.goal});

  static const _quotes = [
    '"Discipline is the bridge between goals and accomplishment."',
    '"Push yourself, because no one else is going to do it for you."',
    '"Every rep counts. Every day counts."',
    '"Success starts with self-discipline."',
    '"Your only limit is you."',
  ];

  @override
  Widget build(BuildContext context) {
    final quote = _quotes[streak % _quotes.length];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E2200), Color(0xFF2E3800)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFE5FF00).withOpacity(0.25), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      '$streak Day Streak',
                      style: const TextStyle(
                          color: Color(0xFFE5FF00),
                          fontWeight: FontWeight.bold,
                          fontSize: 17),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  quote,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontStyle: FontStyle.italic,
                    fontSize: 12.5,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Circular streak badge
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE5FF00).withOpacity(0.12),
              border: Border.all(color: const Color(0xFFE5FF00).withOpacity(0.4), width: 1.5),
            ),
            child: Center(
              child: Text(
                '$streak',
                style: const TextStyle(
                  color: Color(0xFFE5FF00),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QUICK STAT
// ─────────────────────────────────────────────────────────────────────────────
class _QuickStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _QuickStat({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION HEADER
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: const Text(
              'See All →',
              style: TextStyle(color: Color(0xFFE5FF00), fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WORKOUT CARD
// ─────────────────────────────────────────────────────────────────────────────
class _WorkoutCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int exerciseCount;
  final VoidCallback onTap;
  const _WorkoutCard({required this.title, required this.subtitle, required this.exerciseCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFE5FF00).withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5FF00).withOpacity(0.3)),
              ),
              child: const Icon(Icons.fitness_center_rounded, color: Color(0xFFE5FF00), size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 12)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$exerciseCount Exercises',
                          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFE5FF00),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NUTRITION CARD
// ─────────────────────────────────────────────────────────────────────────────
class _NutritionCard extends StatelessWidget {
  final int consumed, target, protein, targetProtein, carbs, fat;
  const _NutritionCard({
    required this.consumed,
    required this.target,
    required this.protein,
    required this.targetProtein,
    required this.carbs,
    required this.fat,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (consumed / target).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          // Calorie progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$consumed kcal',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text('of $target kcal target',
                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                ],
              ),
              // Ring
              SizedBox(
                width: 52,
                height: 52,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: pct,
                      backgroundColor: Colors.white10,
                      color: const Color(0xFFE5FF00),
                      strokeWidth: 5,
                    ),
                    Text(
                      '${(pct * 100).toInt()}%',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: Colors.white10,
              color: const Color(0xFFE5FF00),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 16),
          // Macro pills row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MacroPill(label: 'Protein', value: '${protein}g', color: Colors.blueAccent),
              _MacroPill(label: 'Carbs', value: '${carbs}g', color: Colors.greenAccent),
              _MacroPill(label: 'Fat', value: '${fat}g', color: Colors.pinkAccent),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroPill extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MacroPill({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MEAL PREVIEW TILE
// ─────────────────────────────────────────────────────────────────────────────
class _MealPreviewTile extends StatelessWidget {
  final String title, time;
  final int calories, protein;
  const _MealPreviewTile({required this.title, required this.time, required this.calories, required this.protein});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.restaurant_rounded, color: Colors.white54, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14)),
                const SizedBox(height: 2),
                Text(time, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$calories kcal', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE5FF00), fontSize: 13)),
              const SizedBox(height: 2),
              Text('${protein}g protein', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY CARD
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyCard extends StatelessWidget {
  final String label;
  const _EmptyCard({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Center(
        child: Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4))),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PROFILE PANEL (Bottom Sheet)
// ─────────────────────────────────────────────────────────────────────────────
class _ProfilePanel extends StatelessWidget {
  final dynamic user;
  const _ProfilePanel({this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Avatar
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFE5FF00), Color(0xFF9EBD00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                user?.name?.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user?.name ?? 'User',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 2),
          Text(
            user?.primaryGoal != null ? '${user!.primaryGoal} • ${user!.experienceLevel}' : '',
            style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 13),
          ),
          const SizedBox(height: 24),

          // Stats grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statItem('${user?.age ?? '–'}', 'Age'),
              _vDivider(),
              _statItem('${user?.weight?.toInt() ?? '–'} kg', 'Weight'),
              _vDivider(),
              _statItem('${user?.height?.toInt() ?? '–'} cm', 'Height'),
              _vDivider(),
              _statItem('${user?.streak ?? 0}🔥', 'Streak'),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white10),
          const SizedBox(height: 12),

          // Info rows
          _profileRow(Icons.flag_rounded, 'Goal', user?.primaryGoal ?? '–', Colors.amber),
          _profileRow(Icons.restaurant_rounded, 'Diet', user?.dietPreference ?? '–', Colors.green),
          _profileRow(Icons.currency_rupee_rounded, 'Budget', user?.monthlyBudget != null ? '₹${user!.monthlyBudget.toInt()}/mo' : '–', const Color(0xFFE5FF00)),
          _profileRow(Icons.location_on_rounded, 'Trains At', user?.workoutLocation ?? '–', Colors.blueAccent),
          const SizedBox(height: 16),

          // Edit note
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, color: Colors.white.withOpacity(0.3), size: 14),
              const SizedBox(width: 6),
              Text(
                'Profile editing coming soon',
                style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
      ],
    );
  }

  Widget _vDivider() => Container(height: 28, width: 1, color: Colors.white10);

  Widget _profileRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}
