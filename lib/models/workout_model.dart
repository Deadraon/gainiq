class ExerciseModel {
  final String id;
  final String name;
  final int sets;
  final String reps;
  final int completedSets;
  final String targetMuscle;
  final String instructions;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    this.completedSets = 0,
    this.targetMuscle = '',
    this.instructions = '',
  });

  ExerciseModel copyWith({
    String? name,
    int? sets,
    String? reps,
    String? targetMuscle,
  }) {
    return ExerciseModel(
      id: id,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      completedSets: completedSets,
      targetMuscle: targetMuscle ?? this.targetMuscle,
      instructions: instructions,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sets': sets,
        'reps': reps,
        'targetMuscle': targetMuscle,
      };

  factory ExerciseModel.fromJson(Map<String, dynamic> j) => ExerciseModel(
        id: j['id'] ?? '',
        name: j['name'] ?? '',
        sets: j['sets'] ?? 3,
        reps: j['reps'] ?? '10-12',
        targetMuscle: j['targetMuscle'] ?? '',
      );
}

class WorkoutPlanModel {
  final String id;
  final String title;
  final String subtitle;
  final String imagePath;
  final bool isActive;
  final List<ExerciseModel> exercises;

  WorkoutPlanModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    this.isActive = false,
    this.exercises = const [],
  });

  WorkoutPlanModel copyWith({
    String? title,
    String? subtitle,
    List<ExerciseModel>? exercises,
    bool? isActive,
  }) {
    return WorkoutPlanModel(
      id: id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imagePath: imagePath,
      isActive: isActive ?? this.isActive,
      exercises: exercises ?? this.exercises,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'isActive': isActive,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };

  factory WorkoutPlanModel.fromJson(Map<String, dynamic> j) => WorkoutPlanModel(
        id: j['id'] ?? '',
        title: j['title'] ?? '',
        subtitle: j['subtitle'] ?? '',
        imagePath: '',
        isActive: j['isActive'] ?? false,
        exercises: (j['exercises'] as List<dynamic>? ?? [])
            .map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
