import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/api_response.dart';
import '../models/study_record_model.dart';
import '../../domain/entities/record_stats.dart';
import '../../domain/entities/model_info.dart';
import '../../domain/entities/prediction.dart';

abstract class StudyTrackerRemoteDataSource {
  Future<List<StudyRecordModel>> getRecords();
  Future<StudyRecordModel> addRecord(StudyRecordModel record);
  Future<RecordStats> getStats();
  Future<ModelInfo> trainModel();
  Future<ModelInfo> getModelInfo();
  Future<Prediction> predictScore(double hours, double attendance);
}

class StudyTrackerRemoteDataSourceImpl implements StudyTrackerRemoteDataSource {
  final http.Client client;

  StudyTrackerRemoteDataSourceImpl({required this.client});

  @override
  Future<List<StudyRecordModel>> getRecords() async {
    try {
      AppLogger.i('Fetching records from ${ApiConstants.recordsUrl}');
      
      final response = await client
          .get(
            Uri.parse(ApiConstants.recordsUrl),
            headers: ApiConstants.headers,
          )
          .timeout(ApiConstants.timeout);

      AppLogger.d('Response status: ${response.statusCode}');
      AppLogger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        final apiResponse = ApiResponse.fromJson(jsonResponse, null);

        if (apiResponse.isSuccess) {
          final data = apiResponse.data as List<dynamic>;
          return data.map((json) => StudyRecordModel.fromJson(json)).toList();
        } else {
          throw ServerException(apiResponse.message ?? 'Failed to fetch records');
        }
      } else {
        throw ServerException('Server error: ${response.statusCode}');
      }
    } on SocketException {
      AppLogger.e('Network error: No internet connection');
      throw NetworkException('No internet connection');
    } catch (e) {
      AppLogger.e('Error fetching records', e);
      rethrow;
    }
  }

  @override
  Future<StudyRecordModel> addRecord(StudyRecordModel record) async {
    try {
      AppLogger.i('Adding record to ${ApiConstants.recordsUrl}');
      AppLogger.d('Record data: ${record.toJson()}');

      final response = await client
          .post(
            Uri.parse(ApiConstants.recordsUrl),
            headers: ApiConstants.headers,
            body: json.encode(record.toJson()),
          )
          .timeout(ApiConstants.timeout);

      AppLogger.d('Response status: ${response.statusCode}');
      AppLogger.d('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        final apiResponse = ApiResponse.fromJson(jsonResponse, null);

        if (apiResponse.isSuccess && apiResponse.data != null) {
          return StudyRecordModel.fromJson(apiResponse.data as Map<String, dynamic>);
        } else {
          throw ServerException(apiResponse.message ?? 'Failed to add record');
        }
      } else if (response.statusCode == 400) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        throw ValidationException(jsonResponse['message'] ?? 'Invalid data');
      } else {
        throw ServerException('Server error: ${response.statusCode}');
      }
    } on SocketException {
      AppLogger.e('Network error: No internet connection');
      throw NetworkException('No internet connection');
    } catch (e) {
      AppLogger.e('Error adding record', e);
      rethrow;
    }
  }

  @override
  Future<RecordStats> getStats() async {
    try {
      AppLogger.i('Fetching stats from ${ApiConstants.statsUrl}');

      final response = await client
          .get(
            Uri.parse(ApiConstants.statsUrl),
            headers: ApiConstants.headers,
          )
          .timeout(ApiConstants.timeout);

      AppLogger.d('Response status: ${response.statusCode}');
      AppLogger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        final apiResponse = ApiResponse.fromJson(jsonResponse, null);

        if (apiResponse.isSuccess && apiResponse.data != null) {
          return RecordStats.fromJson(apiResponse.data as Map<String, dynamic>);
        } else {
          throw ServerException(apiResponse.message ?? 'Failed to fetch stats');
        }
      } else {
        throw ServerException('Server error: ${response.statusCode}');
      }
    } on SocketException {
      AppLogger.e('Network error: No internet connection');
      throw NetworkException('No internet connection');
    } catch (e) {
      AppLogger.e('Error fetching stats', e);
      rethrow;
    }
  }

  @override
  Future<ModelInfo> trainModel() async {
    try {
      AppLogger.i('Training model at ${ApiConstants.trainModelUrl}');

      final response = await client
          .post(
            Uri.parse(ApiConstants.trainModelUrl),
            headers: ApiConstants.headers,
          )
          .timeout(ApiConstants.timeout);

      AppLogger.d('Response status: ${response.statusCode}');
      AppLogger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        final apiResponse = ApiResponse.fromJson(jsonResponse, null);

        if (apiResponse.isSuccess && apiResponse.data != null) {
          return ModelInfo.fromJson(apiResponse.data as Map<String, dynamic>);
        } else {
          throw ServerException(apiResponse.message ?? 'Failed to train model');
        }
      } else if (response.statusCode == 400) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        throw ValidationException(jsonResponse['message'] ?? 'Not enough data to train');
      } else {
        throw ServerException('Server error: ${response.statusCode}');
      }
    } on SocketException {
      AppLogger.e('Network error: No internet connection');
      throw NetworkException('No internet connection');
    } catch (e) {
      AppLogger.e('Error training model', e);
      rethrow;
    }
  }

  @override
  Future<ModelInfo> getModelInfo() async {
    try {
      AppLogger.i('Fetching model info from ${ApiConstants.modelInfoUrl}');

      final response = await client
          .get(
            Uri.parse(ApiConstants.modelInfoUrl),
            headers: ApiConstants.headers,
          )
          .timeout(ApiConstants.timeout);

      AppLogger.d('Response status: ${response.statusCode}');
      AppLogger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        final apiResponse = ApiResponse.fromJson(jsonResponse, null);

        if (apiResponse.isSuccess && apiResponse.data != null) {
          return ModelInfo.fromJson(apiResponse.data as Map<String, dynamic>);
        } else {
          throw ServerException(apiResponse.message ?? 'Failed to fetch model info');
        }
      } else if (response.statusCode == 404) {
        throw ServerException('No trained model found');
      } else {
        throw ServerException('Server error: ${response.statusCode}');
      }
    } on SocketException {
      AppLogger.e('Network error: No internet connection');
      throw NetworkException('No internet connection');
    } catch (e) {
      AppLogger.e('Error fetching model info', e);
      rethrow;
    }
  }

  @override
  Future<Prediction> predictScore(double hours, double attendance) async {
    try {
      AppLogger.i('Predicting score at ${ApiConstants.predictUrl}');
      
      final requestBody = {
        'hours': hours,
        'attendance': attendance,
      };
      
      AppLogger.d('Request body: $requestBody');

      final response = await client
          .post(
            Uri.parse(ApiConstants.predictUrl),
            headers: ApiConstants.headers,
            body: json.encode(requestBody),
          )
          .timeout(ApiConstants.timeout);

      AppLogger.d('Response status: ${response.statusCode}');
      AppLogger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        final apiResponse = ApiResponse.fromJson(jsonResponse, null);

        if (apiResponse.isSuccess && apiResponse.data != null) {
          return Prediction.fromJson(apiResponse.data as Map<String, dynamic>);
        } else {
          throw ServerException(apiResponse.message ?? 'Failed to predict score');
        }
      } else if (response.statusCode == 400) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        throw ValidationException(jsonResponse['message'] ?? 'Invalid input or model not trained');
      } else {
        throw ServerException('Server error: ${response.statusCode}');
      }
    } on SocketException {
      AppLogger.e('Network error: No internet connection');
      throw NetworkException('No internet connection');
    } catch (e) {
      AppLogger.e('Error predicting score', e);
      rethrow;
    }
  }
}
