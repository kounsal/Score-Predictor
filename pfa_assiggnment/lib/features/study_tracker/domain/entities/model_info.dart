import 'package:equatable/equatable.dart';

class ModelInfo extends Equatable {
  final dynamic r2Score;
  final dynamic nSamples;
  final List<double> coefficients;

  const ModelInfo({
    required this.r2Score,
    required this.nSamples,
    required this.coefficients,
  });

  @override
  List<Object?> get props => [r2Score, nSamples, coefficients];

  factory ModelInfo.fromJson(Map<String, dynamic> json) {
    final coeffs = json['coefficients'];
    List<double> coefficientsList = [];
    
    if (coeffs is List) {
      coefficientsList = coeffs.map((c) => (c as num).toDouble()).toList();
    }

    return ModelInfo(
      r2Score: json['r2_score'],
      nSamples: json['n_samples'],
      coefficients: coefficientsList,
    );
  }

  String get r2ScoreFormatted {
    if (r2Score is num) {
      return r2Score.toStringAsFixed(4);
    }
    return r2Score.toString();
  }

  bool get isValid => r2Score is num && nSamples is num;
}
