import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/model_provider.dart';

class TrainModelScreen extends ConsumerStatefulWidget {
  const TrainModelScreen({super.key});

  @override
  ConsumerState<TrainModelScreen> createState() => _TrainModelScreenState();
}

class _TrainModelScreenState extends ConsumerState<TrainModelScreen> {
  bool _isTraining = false;

  Future<void> _trainModel() async {
    setState(() => _isTraining = true);

    final success = await ref.read(modelProvider.notifier).trainModel();

    setState(() => _isTraining = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Model trained successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      final modelAsync = ref.read(modelProvider);
      modelAsync.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: AppColors.error,
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final modelAsync = ref.watch(modelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Train Model'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Card
            Card(
              color: AppColors.primary.withOpacity(0.05),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 48.sp,
                      color: AppColors.primary,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'About Model Training',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'The model uses linear regression to learn the relationship between study hours, attendance, and scores. Train the model with your existing records to enable score predictions.',
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
            SizedBox(height: 16.h),

            // Train Button
            Card(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Train New Model',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'This will train a new model using all your study records. Make sure you have at least 2 records before training.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    ElevatedButton.icon(
                      onPressed: _isTraining ? null : _trainModel,
                      icon: _isTraining
                          ? SizedBox(
                              height: 20.h,
                              width: 20.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.model_training),
                      label: Text(
                        _isTraining ? 'Training...' : 'Train Model',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Model Info
            modelAsync.when(
              data: (model) {
                if (model == null) {
                  return Card(
                    child: Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        children: [
                          Icon(
                            Icons.block,
                            size: 48.sp,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'No Model Trained',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Train a model to start making predictions',
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

                if (!model.isValid) {
                  return Card(
                    color: AppColors.warning.withOpacity(0.1),
                    child: Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        children: [
                          Icon(
                            Icons.warning_amber,
                            size: 48.sp,
                            color: AppColors.warning,
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'Model Information Unavailable',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
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
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                              size: 24.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Model Trained',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        _ModelDetail(
                          label: 'R² Score',
                          value: model.r2ScoreFormatted,
                          icon: Icons.trending_up,
                        ),
                        SizedBox(height: 12.h),
                        _ModelDetail(
                          label: 'Training Samples',
                          value: model.nSamples.toString(),
                          icon: Icons.dataset,
                        ),
                        if (model.coefficients.isNotEmpty) ...[
                          SizedBox(height: 12.h),
                          Text(
                            'Coefficients',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          ...model.coefficients.asMap().entries.map((entry) {
                            final labels = ['Intercept', 'Hours', 'Attendance'];
                            final label = entry.key < labels.length
                                ? labels[entry.key]
                                : 'Coef ${entry.key}';
                            return Padding(
                              padding: EdgeInsets.only(bottom: 4.h),
                              child: Text(
                                '$label: ${entry.value.toStringAsFixed(4)}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.textSecondary,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            );
                          }),
                        ],
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
                        size: 48.sp,
                        color: AppColors.error,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Error',
                        style: TextStyle(
                          fontSize: 16.sp,
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

class _ModelDetail extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ModelDetail({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: AppColors.textSecondary),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
