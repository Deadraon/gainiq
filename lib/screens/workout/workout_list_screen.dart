import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/workout_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../models/workout_model.dart';
import 'live_workout_screen.dart';
import 'edit_workout_screen.dart';

class WorkoutListScreen extends StatelessWidget {
  const WorkoutListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workoutProvider = context.watch<WorkoutProvider>();
    final user = context.watch<UserProvider>().currentUser;
    final plans = workoutProvider.availablePlans;
    final activePlan = workoutProvider.activePlan;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your Workouts',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 24)),
                      const SizedBox(height: 4),
                      Text(
                        user != null
                            ? '${user.experienceLevel} • ${user.workoutLocation}'
                            : 'AI Generated',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Theme.of(context).primaryColor, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'AI Plan',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Today's active workout CTA
              if (activePlan != null) ...[
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LiveWorkoutScreen()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor.withOpacity(0.85),
                          Theme.of(context).primaryColor.withOpacity(0.4),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('▶  Start Today\'s Workout',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17)),
                              const SizedBox(height: 4),
                              Text(
                                activePlan.title,
                                style: TextStyle(
                                    color: Colors.black.withOpacity(0.7), fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${activePlan.exercises.length} exercises',
                                style: TextStyle(
                                    color: Colors.black.withOpacity(0.6), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.play_circle_fill, color: Colors.black, size: 48),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // All Plans
              Text('All Plans',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),

              if (plans.isEmpty)
                const Center(child: CircularProgressIndicator())
              else
                ...plans.map((plan) => _buildPlanCard(context, plan, workoutProvider)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(
      BuildContext context, WorkoutPlanModel plan, WorkoutProvider workoutProvider) {
    final isActive = workoutProvider.activePlan?.id == plan.id;
    final totalExercises = plan.exercises.length;

    // Derive muscle groups summary
    final muscles = plan.exercises
        .map((e) => e.targetMuscle)
        .toSet()
        .take(3)
        .join(' • ');

    return GestureDetector(
      onTap: () => workoutProvider.setActivePlan(plan.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Icon box
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isActive
                    ? Theme.of(context).primaryColor.withOpacity(0.15)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.fitness_center,
                color: isActive ? Theme.of(context).primaryColor : Colors.grey,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(plan.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isActive
                                ? Theme.of(context).primaryColor
                                : Colors.white,
                          )),
                      if (isActive) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Active',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(plan.subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
                  if (muscles.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(muscles,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontSize: 11, color: Colors.white38)),
                  ],
                ],
              ),
            ),
            // Exercise count + Edit button
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('$totalExercises',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: isActive
                            ? Theme.of(context).primaryColor
                            : Colors.white70)),
                Text('exs', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => EditWorkoutScreen(plan: plan)),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_rounded, size: 12, color: Colors.white54),
                        SizedBox(width: 4),
                        Text('Edit', style: TextStyle(color: Colors.white54, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
