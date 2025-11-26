import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/model_info.dart';
import '../repositories/study_tracker_repository.dart';

class GetModelInfo {
  final StudyTrackerRepository repository;

  GetModelInfo(this.repository);

  Future<Either<Failure, ModelInfo>> call() async {
    return await repository.getModelInfo();
  }
}
