class UserModel {
  final String id;
  final String name;
  final int age;
  final String gender;
  final double height;
  final double weight;
  final String bodyType;
  final String primaryGoal;
  final String experienceLevel;
  final String workoutLocation;
  final String workoutTiming;
  final String dietPreference;
  final double monthlyBudget;
  final String allergies;
  final int streak;

  UserModel({
    required this.id,
    this.name = '',
    this.age = 0,
    this.gender = '',
    this.height = 0,
    this.weight = 0,
    this.bodyType = '',
    this.primaryGoal = '',
    this.experienceLevel = '',
    this.workoutLocation = '',
    this.workoutTiming = '',
    this.dietPreference = '',
    this.monthlyBudget = 0,
    this.allergies = '',
    this.streak = 0,
  });

  bool get isProfileComplete =>
      name.isNotEmpty && weight > 0 && height > 0 && primaryGoal.isNotEmpty;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      age: _parseInt(json['age']),
      gender: (json['gender'] ?? '').toString(),
      height: _parseDouble(json['height']),
      weight: _parseDouble(json['weight']),
      bodyType: (json['bodyType'] ?? '').toString(),
      primaryGoal: (json['primaryGoal'] ?? '').toString(),
      experienceLevel: (json['experienceLevel'] ?? '').toString(),
      workoutLocation: (json['workoutLocation'] ?? '').toString(),
      workoutTiming: (json['workoutTiming'] ?? '').toString(),
      dietPreference: (json['dietPreference'] ?? '').toString(),
      monthlyBudget: _parseDouble(json['monthlyBudget']),
      allergies: (json['allergies'] ?? '').toString(),
      streak: _parseInt(json['streak']),
    );
  }

  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is double) return val.toInt();
    return int.tryParse(val.toString()) ?? 0;
  }

  static double _parseDouble(dynamic val) {
    if (val == null) return 0;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'bodyType': bodyType,
      'primaryGoal': primaryGoal,
      'experienceLevel': experienceLevel,
      'workoutLocation': workoutLocation,
      'workoutTiming': workoutTiming,
      'dietPreference': dietPreference,
      'monthlyBudget': monthlyBudget,
      'allergies': allergies,
      'streak': streak,
    };
  }

  UserModel copyWith({
    String? name,
    int? age,
    String? gender,
    double? height,
    double? weight,
    String? bodyType,
    String? primaryGoal,
    String? experienceLevel,
    String? workoutLocation,
    String? workoutTiming,
    String? dietPreference,
    double? monthlyBudget,
    String? allergies,
    int? streak,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      bodyType: bodyType ?? this.bodyType,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      workoutLocation: workoutLocation ?? this.workoutLocation,
      workoutTiming: workoutTiming ?? this.workoutTiming,
      dietPreference: dietPreference ?? this.dietPreference,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      allergies: allergies ?? this.allergies,
      streak: streak ?? this.streak,
    );
  }
}
