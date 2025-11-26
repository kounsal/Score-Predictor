import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/model_info.dart';
import '../../domain/entities/prediction.dart';
import '../../domain/entities/record_stats.dart';
import '../../domain/entities/study_record.dart';
import '../../domain/repositories/study_tracker_repository.dart';
import '../datasources/study_tracker_remote_data_source.dart';
import '../models/study_record_model.dart';

class StudyTrackerRepositoryImpl implements StudyTrackerRepository {
  final StudyTrackerRemoteDataSource remoteDataSource;

  StudyTrackerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<StudyRecord>>> getRecords() async {
    try {
      final records = await remoteDataSource.getRecords();
      return Right(records);
    } on ServerException catch (e) {
      AppLogger.e('Server exception in getRecords', e);
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      AppLogger.e('Network exception in getRecords', e);
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      AppLogger.e('Unexpected error in getRecords', e);
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, StudyRecord>> addRecord(StudyRecord record) async {
    try {
      final recordModel = StudyRecordModel.fromEntity(record);
      final addedRecord = await remoteDataSource.addRecord(recordModel);
      return Right(addedRecord);
    } on ValidationException catch (e) {
      AppLogger.e('Validation exception in addRecord', e);
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      AppLogger.e('Server exception in addRecord', e);
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      AppLogger.e('Network exception in addRecord', e);
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      AppLogger.e('Unexpected error in addRecord', e);
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, RecordStats>> getStats() async {
    try {
      final stats = await remoteDataSource.getStats();
      return Right(stats);
    } on ServerException catch (e) {
      AppLogger.e('Server exception in getStats', e);
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      AppLogger.e('Network exception in getStats', e);
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      AppLogger.e('Unexpected error in getStats', e);
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, ModelInfo>> trainModel() async {
    try {
      final modelInfo = await remoteDataSource.trainModel();
      return Right(modelInfo);
    } on ValidationException catch (e) {
      AppLogger.e('Validation exception in trainModel', e);
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      AppLogger.e('Server exception in trainModel', e);
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      AppLogger.e('Network exception in trainModel', e);
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      AppLogger.e('Unexpected error in trainModel', e);
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, ModelInfo>> getModelInfo() async {
    try {
      final modelInfo = await remoteDataSource.getModelInfo();
      return Right(modelInfo);
    } on ServerException catch (e) {
      AppLogger.e('Server exception in getModelInfo', e);
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      AppLogger.e('Network exception in getModelInfo', e);
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      AppLogger.e('Unexpected error in getModelInfo', e);
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, Prediction>> predictScore(
      double hours, double attendance) async {
    try {
      final prediction = await remoteDataSource.predictScore(hours, attendance);
      return Right(prediction);
    } on ValidationException catch (e) {
      AppLogger.e('Validation exception in predictScore', e);
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      AppLogger.e('Server exception in predictScore', e);
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      AppLogger.e('Network exception in predictScore', e);
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      AppLogger.e('Unexpected error in predictScore', e);
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }
}
