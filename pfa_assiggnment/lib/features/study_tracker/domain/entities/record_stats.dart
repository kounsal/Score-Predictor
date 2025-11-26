import 'package:equatable/equatable.dart';

class RecordStats extends Equatable {
  final int totalRecords;
  final StatDetails hours;
  final StatDetails attendance;
  final StatDetails scores;

  const RecordStats({
    required this.totalRecords,
    required this.hours,
    required this.attendance,
    required this.scores,
  });

  @override
  List<Object?> get props => [totalRecords, hours, attendance, scores];

  factory RecordStats.fromJson(Map<String, dynamic> json) {
    return RecordStats(
      totalRecords: json['total_records'] as int,
      hours: StatDetails.fromJson(json['hours'] as Map<String, dynamic>),
      attendance: StatDetails.fromJson(json['attendance'] as Map<String, dynamic>),
      scores: StatDetails.fromJson(json['scores'] as Map<String, dynamic>),
    );
  }
}

class StatDetails extends Equatable {
  final double min;
  final double max;
  final double avg;

  const StatDetails({
    required this.min,
    required this.max,
    required this.avg,
  });

  @override
  List<Object?> get props => [min, max, avg];

  factory StatDetails.fromJson(Map<String, dynamic> json) {
    return StatDetails(
      min: (json['min'] as num).toDouble(),
      max: (json['max'] as num).toDouble(),
      avg: (json['avg'] as num).toDouble(),
    );
  }
}
