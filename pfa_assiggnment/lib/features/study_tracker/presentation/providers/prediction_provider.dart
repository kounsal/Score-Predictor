import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/prediction.dart';
import 'dependency_injection.dart';

final predictionProvider =
    StateNotifierProvider<PredictionNotifier, AsyncValue<Prediction?>>(
  (ref) => PredictionNotifier(ref),
);

class PredictionNotifier extends StateNotifier<AsyncValue<Prediction?>> {
  final Ref ref;

  PredictionNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<bool> predictScore(double hours, double attendance) async {
    state = const AsyncValue.loading();
    
    final predictScore = ref.read(predictScoreUseCaseProvider);
    final result = await predictScore(hours, attendance);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (prediction) {
        state = AsyncValue.data(prediction);
        return true;
      },
    );
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}
