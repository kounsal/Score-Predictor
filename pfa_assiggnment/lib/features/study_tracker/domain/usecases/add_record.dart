import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/study_record.dart';
import '../repositories/study_tracker_repository.dart';

class AddRecord {
  final StudyTrackerRepository repository;

  AddRecord(this.repository);

  Future<Either<Failure, StudyRecord>> call(StudyRecord record) async {
    // Validate input
    if (record.hours < 0) {
      return Left(ValidationFailure('Hours cannot be negative'));
    }
    if (record.attendance < 0 || record.attendance > 100) {
      return Left(ValidationFailure('Attendance must be between 0 and 100'));
    }
    if (record.score < 0 || record.score > 100) {
      return Left(ValidationFailure('Score must be between 0 and 100'));
    }

    return await repository.addRecord(record);
  }
}
