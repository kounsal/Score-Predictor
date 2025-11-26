import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../data/datasources/study_tracker_remote_data_source.dart';
import '../../data/repositories/study_tracker_repository_impl.dart';
import '../../domain/repositories/study_tracker_repository.dart';
import '../../domain/usecases/add_record.dart';
import '../../domain/usecases/get_model_info.dart';
import '../../domain/usecases/get_records.dart';
import '../../domain/usecases/get_stats.dart';
import '../../domain/usecases/predict_score.dart';
import '../../domain/usecases/train_model.dart';

// HTTP Client Provider
final httpClientProvider = Provider<http.Client>((ref) {
  return http.Client();
});

// Data Source Provider
final studyTrackerRemoteDataSourceProvider =
    Provider<StudyTrackerRemoteDataSource>((ref) {
  final client = ref.watch(httpClientProvider);
  return StudyTrackerRemoteDataSourceImpl(client: client);
});

// Repository Provider
final studyTrackerRepositoryProvider = Provider<StudyTrackerRepository>((ref) {
  final remoteDataSource = ref.watch(studyTrackerRemoteDataSourceProvider);
  return StudyTrackerRepositoryImpl(remoteDataSource: remoteDataSource);
});

// Use Cases Providers
final getRecordsUseCaseProvider = Provider<GetRecords>((ref) {
  final repository = ref.watch(studyTrackerRepositoryProvider);
  return GetRecords(repository);
});

final addRecordUseCaseProvider = Provider<AddRecord>((ref) {
  final repository = ref.watch(studyTrackerRepositoryProvider);
  return AddRecord(repository);
});

final getStatsUseCaseProvider = Provider<GetStats>((ref) {
  final repository = ref.watch(studyTrackerRepositoryProvider);
  return GetStats(repository);
});

final trainModelUseCaseProvider = Provider<TrainModel>((ref) {
  final repository = ref.watch(studyTrackerRepositoryProvider);
  return TrainModel(repository);
});

final getModelInfoUseCaseProvider = Provider<GetModelInfo>((ref) {
  final repository = ref.watch(studyTrackerRepositoryProvider);
  return GetModelInfo(repository);
});

final predictScoreUseCaseProvider = Provider<PredictScore>((ref) {
  final repository = ref.watch(studyTrackerRepositoryProvider);
  return PredictScore(repository);
});
