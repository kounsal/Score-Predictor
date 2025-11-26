import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../study_tracker/domain/entities/study_record.dart';
import '../../../study_tracker/presentation/providers/records_provider.dart';

class AddRecordScreen extends ConsumerStatefulWidget {
  const AddRecordScreen({super.key});

  @override
  ConsumerState<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends ConsumerState<AddRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hoursController = TextEditingController();
  final _attendanceController = TextEditingController();
  final _scoreController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _hoursController.dispose();
    _attendanceController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  Future<void> _addRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final record = StudyRecord(
      hours: double.parse(_hoursController.text),
      attendance: double.parse(_attendanceController.text),
      score: double.parse(_scoreController.text),
    );

    final success = await ref.read(recordsProvider.notifier).addRecord(record);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Record added successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add record'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Study Record'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Study Details',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      TextFormField(
                        controller: _hoursController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Hours Studied',
                          prefixIcon: const Icon(Icons.access_time),
                          hintText: 'e.g., 5.5',
                          helperText: 'Enter the number of hours studied',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter hours studied';
                          }
                          final hours = double.tryParse(value);
                          if (hours == null || hours < 0) {
                            return 'Please enter a valid positive number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),
                      TextFormField(
                        controller: _attendanceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Attendance (%)',
                          prefixIcon: const Icon(Icons.event_available),
                          hintText: 'e.g., 85',
                          helperText: 'Enter attendance percentage (0-100)',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter attendance';
                          }
                          final attendance = double.tryParse(value);
                          if (attendance == null || attendance < 0 || attendance > 100) {
                            return 'Attendance must be between 0 and 100';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),
                      TextFormField(
                        controller: _scoreController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Score',
                          prefixIcon: const Icon(Icons.grade),
                          hintText: 'e.g., 78',
                          helperText: 'Enter the actual score received (0-100)',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter score';
                          }
                          final score = double.tryParse(value);
                          if (score == null || score < 0 || score > 100) {
                            return 'Score must be between 0 and 100';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: _isLoading ? null : _addRecord,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20.h,
                        width: 20.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Add Record',
                        style: TextStyle(fontSize: 16.sp),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
