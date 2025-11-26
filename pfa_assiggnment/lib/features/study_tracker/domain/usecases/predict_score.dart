import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/prediction.dart';
import '../repositories/study_tracker_repository.dart';

class PredictScore {
  final StudyTrackerRepository repository;

  PredictScore(this.repository);

  Future<Either<Failure, Prediction>> call(
      double hours, double attendance) async {
    // Validate input
    if (hours < 0) {
      return Left(ValidationFailure('Hours cannot be negative'));
    }
    if (attendance < 0 || attendance > 100) {
      return Left(ValidationFailure('Attendance must be between 0 and 100'));
    }

    return await repository.predictScore(hours, attendance);
  }
}
