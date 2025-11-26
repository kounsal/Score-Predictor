import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/prediction_provider.dart';

class PredictScreen extends ConsumerStatefulWidget {
  const PredictScreen({super.key});

  @override
  ConsumerState<PredictScreen> createState() => _PredictScreenState();
}

class _PredictScreenState extends ConsumerState<PredictScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hoursController = TextEditingController();
  final _attendanceController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _hoursController.dispose();
    _attendanceController.dispose();
    super.dispose();
  }

  Future<void> _predictScore() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final hours = double.parse(_hoursController.text);
    final attendance = double.parse(_attendanceController.text);

    final success = await ref
        .read(predictionProvider.notifier)
        .predictScore(hours, attendance);

    setState(() => _isLoading = false);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to predict score. Make sure the model is trained.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final predictionAsync = ref.watch(predictionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Predict Score'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enter Study Details',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      TextFormField(
                        controller: _hoursController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Hours to Study',
                          prefixIcon: const Icon(Icons.access_time),
                          hintText: 'e.g., 5.5',
                          helperText: 'Enter the planned study hours',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter hours';
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
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Expected Attendance (%)',
                          prefixIcon: const Icon(Icons.event_available),
                          hintText: 'e.g., 85',
                          helperText: 'Enter expected attendance (0-100)',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter attendance';
                          }
                          final attendance = double.tryParse(value);
                          if (attendance == null ||
                              attendance < 0 ||
                              attendance > 100) {
                            return 'Attendance must be between 0 and 100';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _predictScore,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 20.h,
                                width: 20.h,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Predict Score',
                                style: TextStyle(fontSize: 16.sp),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Prediction Result
            predictionAsync.when(
              data: (prediction) {
                if (prediction == null) {
                  return Card(
                    color: AppColors.primary.withOpacity(0.05),
                    child: Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        children: [
                          Icon(
                            Icons.psychology_outlined,
                            size: 64.sp,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'Enter details above to predict your score',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Card(
                  color: AppColors.success.withOpacity(0.1),
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 64.sp,
                          color: AppColors.success,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Predicted Score',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          prediction.predictedScore.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 48.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Divider(color: AppColors.divider),
                        SizedBox(height: 16.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _InputDetail(
                              icon: Icons.access_time,
                              label: 'Hours',
                              value: prediction.hours.toStringAsFixed(1),
                            ),
                            _InputDetail(
                              icon: Icons.event_available,
                              label: 'Attendance',
                              value: '${prediction.attendance.toStringAsFixed(1)}%',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => Card(
                child: Padding(
                  padding: EdgeInsets.all(40.w),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, stack) => Card(
                color: AppColors.error.withOpacity(0.1),
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64.sp,
                        color: AppColors.error,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Prediction Failed',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InputDetail({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24.sp, color: AppColors.textSecondary),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
