import '../../domain/entities/study_record.dart';


class StudyRecordModel extends StudyRecord {
  const StudyRecordModel({
    required super.hours,
    required super.attendance,
    required super.score,
  });

  factory StudyRecordModel.fromJson(Map<String, dynamic> json) {
    return StudyRecordModel(
      hours: (json['hours'] ?? json['Study_Hours_per_Week'] ?? 0.0 as num).toDouble(),
      attendance:  (json['attendance'] ?? json['Attendance_Rate'] ?? 0.0  as num).toDouble(),
      score: (json['score'] ?? json['Final_Exam_Score'] ?? 0.0 as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'hours': hours,
      'attendance': attendance,
      'score': score,
    };
  }

  factory StudyRecordModel.fromEntity(StudyRecord record) {
    return StudyRecordModel(
      hours: record.hours,
      attendance: record.attendance,
      score: record.score,
    );
  }
}
