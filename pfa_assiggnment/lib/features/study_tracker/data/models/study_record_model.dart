import '../entities/study_record.dart';

class StudyRecordModel extends StudyRecord {
  const StudyRecordModel({
    required super.hours,
    required super.attendance,
    required super.score,
  });

  factory StudyRecordModel.fromJson(Map<String, dynamic> json) {
    return StudyRecordModel(
      hours: (json['hours'] as num).toDouble(),
      attendance: (json['attendance'] as num).toDouble(),
      score: (json['score'] as num).toDouble(),
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
