import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/study_record.dart';
import '../entities/record_stats.dart';
import '../entities/model_info.dart';
import '../entities/prediction.dart';

abstract class StudyTrackerRepository {
  Future<Either<Failure, List<StudyRecord>>> getRecords();
  Future<Either<Failure, StudyRecord>> addRecord(StudyRecord record);
  Future<Either<Failure, RecordStats>> getStats();
  Future<Either<Failure, ModelInfo>> trainModel();
  Future<Either<Failure, ModelInfo>> getModelInfo();
  Future<Either<Failure, Prediction>> predictScore(double hours, double attendance);
}
