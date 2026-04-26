import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutLogModel {
  final String id;
  final String planName;
  final int totalVolume; // total kg lifted
  final int durationSeconds;
  final DateTime date;

  WorkoutLogModel({
    required this.id,
    required this.planName,
    required this.totalVolume,
    required this.durationSeconds,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'planName': planName,
      'totalVolume': totalVolume,
      'durationSeconds': durationSeconds,
      'date': Timestamp.fromDate(date),
    };
  }

  factory WorkoutLogModel.fromJson(Map<String, dynamic> json) {
    return WorkoutLogModel(
      id: json['id']?.toString() ?? '',
      planName: json['planName']?.toString() ?? 'Workout',
      totalVolume: json['totalVolume'] as int? ?? 0,
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      date: (json['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
