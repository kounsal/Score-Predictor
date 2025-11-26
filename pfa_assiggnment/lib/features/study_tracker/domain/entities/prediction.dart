import 'package:equatable/equatable.dart';

class Prediction extends Equatable {
  final double hours;
  final double attendance;
  final double predictedScore;

  const Prediction({
    required this.hours,
    required this.attendance,
    required this.predictedScore,
  });

  @override
  List<Object?> get props => [hours, attendance, predictedScore];

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      hours: (json['hours'] as num).toDouble(),
      attendance: (json['attendance'] as num).toDouble(),
      predictedScore: (json['predicted_score'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hours': hours,
      'attendance': attendance,
    };
  }
}
