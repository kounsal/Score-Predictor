import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/study_record.dart';
import 'dependency_injection.dart';

final recordsProvider =
    StateNotifierProvider<RecordsNotifier, AsyncValue<List<StudyRecord>>>(
  (ref) => RecordsNotifier(ref),
);

class RecordsNotifier extends StateNotifier<AsyncValue<List<StudyRecord>>> {
  final Ref ref;

  RecordsNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadRecords();
  }

  Future<void> loadRecords() async {
    state = const AsyncValue.loading();
    
    final getRecords = ref.read(getRecordsUseCaseProvider);
    final result = await getRecords();

    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (records) => state = AsyncValue.data(records),
    );
  }

  Future<bool> addRecord(StudyRecord record) async {
    final addRecord = ref.read(addRecordUseCaseProvider);
    final result = await addRecord(record);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (addedRecord) {
        // Refresh records after adding
        loadRecords();
        return true;
      },
    );
  }
}
