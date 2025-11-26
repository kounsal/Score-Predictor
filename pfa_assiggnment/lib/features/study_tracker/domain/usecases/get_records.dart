import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/study_record.dart';
import '../repositories/study_tracker_repository.dart';

class GetRecords {
  final StudyTrackerRepository repository;

  GetRecords(this.repository);

  Future<Either<Failure, List<StudyRecord>>> call() async {
    return await repository.getRecords();
  }
}
