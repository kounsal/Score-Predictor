import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/record_stats.dart';
import 'dependency_injection.dart';

final statsProvider =
    StateNotifierProvider<StatsNotifier, AsyncValue<RecordStats?>>(
  (ref) => StatsNotifier(ref),
);

class StatsNotifier extends StateNotifier<AsyncValue<RecordStats?>> {
  final Ref ref;

  StatsNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> loadStats() async {
    state = const AsyncValue.loading();
    
    final getStats = ref.read(getStatsUseCaseProvider);
    final result = await getStats();

    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (stats) => state = AsyncValue.data(stats),
    );
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}
