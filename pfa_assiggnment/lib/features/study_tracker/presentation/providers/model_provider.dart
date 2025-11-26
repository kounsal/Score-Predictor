import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/model_info.dart';
import 'dependency_injection.dart';

final modelProvider =
    StateNotifierProvider<ModelNotifier, AsyncValue<ModelInfo?>>(
  (ref) => ModelNotifier(ref),
);

class ModelNotifier extends StateNotifier<AsyncValue<ModelInfo?>> {
  final Ref ref;

  ModelNotifier(this.ref) : super(const AsyncValue.data(null)) {
    loadModelInfo();
  }

  Future<void> loadModelInfo() async {
    final getModelInfo = ref.read(getModelInfoUseCaseProvider);
    final result = await getModelInfo();

    result.fold(
      (failure) => state = const AsyncValue.data(null),
      (modelInfo) => state = AsyncValue.data(modelInfo),
    );
  }

  Future<bool> trainModel() async {
    state = const AsyncValue.loading();
    
    final trainModel = ref.read(trainModelUseCaseProvider);
    final result = await trainModel();

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (modelInfo) {
        state = AsyncValue.data(modelInfo);
        return true;
      },
    );
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}
