import '../../models/workout_model.dart';
import '../../models/user_model.dart';

// ─────────────────────────────────────────────────────────────
//  EXERCISE DATABASE
// ─────────────────────────────────────────────────────────────
class ExerciseDB {
  // GYM exercises by muscle group
  static const Map<String, List<Map<String, String>>> gym = {
    'chest': [
      {'name': 'Barbell Bench Press', 'reps': '8-12', 'muscle': 'Chest'},
      {'name': 'Incline Dumbbell Press', 'reps': '10-12', 'muscle': 'Upper Chest'},
      {'name': 'Cable Crossover', 'reps': '12-15', 'muscle': 'Chest'},
      {'name': 'Dumbbell Flyes', 'reps': '12-15', 'muscle': 'Chest'},
    ],
    'back': [
      {'name': 'Barbell Deadlift', 'reps': '5-8', 'muscle': 'Back'},
      {'name': 'Pull-Ups', 'reps': '8-12', 'muscle': 'Lats'},
      {'name': 'Seated Cable Row', 'reps': '10-12', 'muscle': 'Back'},
      {'name': 'Lat Pulldown', 'reps': '10-12', 'muscle': 'Lats'},
      {'name': 'Dumbbell Row', 'reps': '10-12', 'muscle': 'Back'},
    ],
    'shoulders': [
      {'name': 'Overhead Press (Barbell)', 'reps': '8-10', 'muscle': 'Shoulders'},
      {'name': 'Dumbbell Lateral Raises', 'reps': '12-15', 'muscle': 'Side Delts'},
      {'name': 'Face Pulls', 'reps': '15-20', 'muscle': 'Rear Delts'},
      {'name': 'Arnold Press', 'reps': '10-12', 'muscle': 'Shoulders'},
    ],
    'triceps': [
      {'name': 'Triceps Pushdown (Cable)', 'reps': '12-15', 'muscle': 'Triceps'},
      {'name': 'Skull Crushers', 'reps': '10-12', 'muscle': 'Triceps'},
      {'name': 'Overhead Triceps Extension', 'reps': '12-15', 'muscle': 'Triceps'},
    ],
    'biceps': [
      {'name': 'Barbell Curl', 'reps': '10-12', 'muscle': 'Biceps'},
      {'name': 'Incline Dumbbell Curl', 'reps': '10-12', 'muscle': 'Biceps'},
      {'name': 'Hammer Curl', 'reps': '12-15', 'muscle': 'Biceps'},
      {'name': 'Cable Curl', 'reps': '12-15', 'muscle': 'Biceps'},
    ],
    'legs': [
      {'name': 'Barbell Squat', 'reps': '6-10', 'muscle': 'Quads'},
      {'name': 'Romanian Deadlift', 'reps': '8-12', 'muscle': 'Hamstrings'},
      {'name': 'Leg Press', 'reps': '10-15', 'muscle': 'Quads'},
      {'name': 'Leg Curl', 'reps': '10-15', 'muscle': 'Hamstrings'},
      {'name': 'Standing Calf Raise', 'reps': '15-20', 'muscle': 'Calves'},
      {'name': 'Leg Extension', 'reps': '12-15', 'muscle': 'Quads'},
    ],
    'core': [
      {'name': 'Hanging Leg Raises', 'reps': '12-15', 'muscle': 'Abs'},
      {'name': 'Cable Crunch', 'reps': '15-20', 'muscle': 'Abs'},
      {'name': 'Plank', 'reps': '60 sec', 'muscle': 'Core'},
    ],
  };

  // HOME exercises (bodyweight)
  static const Map<String, List<Map<String, String>>> home = {
    'chest': [
      {'name': 'Push-Ups', 'reps': '15-20', 'muscle': 'Chest'},
      {'name': 'Wide Push-Ups', 'reps': '15-20', 'muscle': 'Chest'},
      {'name': 'Diamond Push-Ups', 'reps': '12-15', 'muscle': 'Triceps/Chest'},
      {'name': 'Decline Push-Ups', 'reps': '12-15', 'muscle': 'Upper Chest'},
    ],
    'back': [
      {'name': 'Superman Hold', 'reps': '15-20', 'muscle': 'Lower Back'},
      {'name': 'Doorframe Rows', 'reps': '10-15', 'muscle': 'Back'},
      {'name': 'Reverse Snow Angels', 'reps': '15', 'muscle': 'Rear Delts'},
    ],
    'shoulders': [
      {'name': 'Pike Push-Ups', 'reps': '10-15', 'muscle': 'Shoulders'},
      {'name': 'Wall Handstand Hold', 'reps': '30 sec', 'muscle': 'Shoulders'},
      {'name': 'Lateral Raise (Water Bottles)', 'reps': '15-20', 'muscle': 'Side Delts'},
    ],
    'legs': [
      {'name': 'Bodyweight Squats', 'reps': '20-25', 'muscle': 'Quads'},
      {'name': 'Jump Squats', 'reps': '15-20', 'muscle': 'Quads'},
      {'name': 'Reverse Lunges', 'reps': '12 each leg', 'muscle': 'Legs'},
      {'name': 'Bulgarian Split Squats', 'reps': '10-12 each', 'muscle': 'Quads'},
      {'name': 'Glute Bridges', 'reps': '15-20', 'muscle': 'Glutes'},
      {'name': 'Calf Raises', 'reps': '25-30', 'muscle': 'Calves'},
    ],
    'core': [
      {'name': 'Crunches', 'reps': '20-25', 'muscle': 'Abs'},
      {'name': 'Leg Raises', 'reps': '15-20', 'muscle': 'Lower Abs'},
      {'name': 'Plank', 'reps': '60 sec', 'muscle': 'Core'},
      {'name': 'Mountain Climbers', 'reps': '30 sec', 'muscle': 'Core'},
      {'name': 'Bicycle Crunches', 'reps': '20 each side', 'muscle': 'Obliques'},
    ],
  };
}

// ─────────────────────────────────────────────────────────────
//  WORKOUT PLAN GENERATOR
// ─────────────────────────────────────────────────────────────
class WorkoutGenerator {
  static List<WorkoutPlanModel> generate(UserModel user) {
    final isGym = user.workoutLocation.toLowerCase() == 'gym';
    final db = isGym ? ExerciseDB.gym : ExerciseDB.home;

    switch (user.experienceLevel.toLowerCase()) {
      case 'beginner':
        return _fullBodySplit(db, isGym, user);
      case 'intermediate':
        return _pushPullLegsSplit(db, isGym, user);
      case 'advanced':
        return _broSplit(db, isGym, user);
      default:
        return _fullBodySplit(db, isGym, user);
    }
  }

  // ── BEGINNER: Full Body 3x/week ──
  static List<WorkoutPlanModel> _fullBodySplit(
      Map<String, List<Map<String, String>>> db, bool isGym, UserModel user) {
    return [
      _buildPlan(
        id: 'fb_a',
        title: 'Full Body A',
        subtitle: 'Beginner • Mon / Wed / Fri',
        muscles: ['chest', 'back', 'legs', 'core'],
        db: db,
        sets: 3,
        isGym: isGym,
        isActive: true,
      ),
    ];
  }

  // ── INTERMEDIATE: Push Pull Legs ──
  static List<WorkoutPlanModel> _pushPullLegsSplit(
      Map<String, List<Map<String, String>>> db, bool isGym, UserModel user) {
    return [
      _buildPlan(
        id: 'push_day',
        title: 'Push Day',
        subtitle: 'Intermediate • Chest, Shoulders, Triceps',
        muscles: ['chest', 'shoulders', 'triceps'],
        db: db,
        sets: 4,
        isGym: isGym,
        isActive: true,
      ),
      _buildPlan(
        id: 'pull_day',
        title: 'Pull Day',
        subtitle: 'Intermediate • Back, Biceps',
        muscles: ['back', 'biceps'],
        db: db,
        sets: 4,
        isGym: isGym,
        isActive: false,
      ),
      _buildPlan(
        id: 'leg_day',
        title: 'Leg Day',
        subtitle: 'Intermediate • Quads, Hamstrings, Calves',
        muscles: ['legs', 'core'],
        db: db,
        sets: 4,
        isGym: isGym,
        isActive: false,
      ),
    ];
  }

  // ── ADVANCED: Bro Split 5x/week ──
  static List<WorkoutPlanModel> _broSplit(
      Map<String, List<Map<String, String>>> db, bool isGym, UserModel user) {
    return [
      _buildPlan(
        id: 'bro_chest',
        title: 'Chest Day',
        subtitle: 'Advanced • Monday',
        muscles: ['chest', 'triceps'],
        db: db,
        sets: 5,
        isGym: isGym,
        isActive: true,
      ),
      _buildPlan(
        id: 'bro_back',
        title: 'Back Day',
        subtitle: 'Advanced • Tuesday',
        muscles: ['back', 'biceps'],
        db: db,
        sets: 5,
        isGym: isGym,
        isActive: false,
      ),
      _buildPlan(
        id: 'bro_shoulders',
        title: 'Shoulder Day',
        subtitle: 'Advanced • Wednesday',
        muscles: ['shoulders', 'core'],
        db: db,
        sets: 5,
        isGym: isGym,
        isActive: false,
      ),
      _buildPlan(
        id: 'bro_arms',
        title: 'Arms Day',
        subtitle: 'Advanced • Thursday',
        muscles: ['biceps', 'triceps'],
        db: db,
        sets: 5,
        isGym: isGym,
        isActive: false,
      ),
      _buildPlan(
        id: 'bro_legs',
        title: 'Leg Day',
        subtitle: 'Advanced • Friday',
        muscles: ['legs', 'core'],
        db: db,
        sets: 5,
        isGym: isGym,
        isActive: false,
      ),
    ];
  }

  // ── Build a single WorkoutPlanModel from selected muscle groups ──
  static WorkoutPlanModel _buildPlan({
    required String id,
    required String title,
    required String subtitle,
    required List<String> muscles,
    required Map<String, List<Map<String, String>>> db,
    required int sets,
    required bool isGym,
    bool isActive = false,
  }) {
    int exerciseIndex = 0;
    final exercises = <ExerciseModel>[];

    for (final muscle in muscles) {
      final available = db[muscle] ?? [];
      // Take top 2 exercises per muscle group (or fewer if not available)
      final take = available.take(2);
      for (final ex in take) {
        exercises.add(ExerciseModel(
          id: '${id}_ex_${exerciseIndex++}',
          name: ex['name']!,
          sets: sets,
          reps: ex['reps']!,
          targetMuscle: ex['muscle']!,
          completedSets: 0,
        ));
      }
    }

    return WorkoutPlanModel(
      id: id,
      title: title,
      subtitle: subtitle,
      imagePath: '',
      isActive: isActive,
      exercises: exercises,
    );
  }
}
