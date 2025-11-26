import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/record_stats.dart';
import '../repositories/study_tracker_repository.dart';

class GetStats {
  final StudyTrackerRepository repository;

  GetStats(this.repository);

  Future<Either<Failure, RecordStats>> call() async {
    return await repository.getStats();
  }
}
