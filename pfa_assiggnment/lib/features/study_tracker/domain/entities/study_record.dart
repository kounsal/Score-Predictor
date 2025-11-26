import 'package:equatable/equatable.dart';

class StudyRecord extends Equatable {
  final double hours;
  final double attendance;
  final double score;

  const StudyRecord({
    required this.hours,
    required this.attendance,
    required this.score,
  });

  @override
  List<Object?> get props => [hours, attendance, score];

  Map<String, dynamic> toJson() {
    return {
      'hours': hours,
      'attendance': attendance,
      'score': score,
    };
  }

  factory StudyRecord.fromJson(Map<String, dynamic> json) {
    return StudyRecord(
      hours: (json['hours'] as num).toDouble(),
      attendance: (json['attendance'] as num).toDouble(),
      score: (json['score'] as num).toDouble(),
    );
  }

  StudyRecord copyWith({
    double? hours,
    double? attendance,
    double? score,
  }) {
    return StudyRecord(
      hours: hours ?? this.hours,
      attendance: attendance ?? this.attendance,
      score: score ?? this.score,
    );
  }
}
