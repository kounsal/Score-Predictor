import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/stats_provider.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(statsProvider.notifier).loadStats());
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(statsProvider.notifier).loadStats(),
          ),
        ],
      ),
      body: statsAsync.when(
        data: (stats) {
          if (stats == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 80.sp,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No statistics available',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Add some records to see statistics',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Summary Card
                Card(
                  color: AppColors.primary.withOpacity(0.1),
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      children: [
                        Icon(
                          Icons.assessment,
                          size: 48.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Total Records',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          stats.totalRecords.toString(),
                          style: TextStyle(
                            fontSize: 36.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // Hours Statistics
                _StatCard(
                  title: 'Study Hours',
                  icon: Icons.access_time,
                  color: AppColors.primary,
                  min: stats.hours.min,
                  max: stats.hours.max,
                  avg: stats.hours.avg,
                ),
                SizedBox(height: 12.h),

                // Attendance Statistics
                _StatCard(
                  title: 'Attendance',
                  icon: Icons.event_available,
                  color: AppColors.secondary,
                  min: stats.attendance.min,
                  max: stats.attendance.max,
                  avg: stats.attendance.avg,
                  isPercentage: true,
                ),
                SizedBox(height: 12.h),

                // Scores Statistics
                _StatCard(
                  title: 'Scores',
                  icon: Icons.grade,
                  color: AppColors.warning,
                  min: stats.scores.min,
                  max: stats.scores.max,
                  avg: stats.scores.avg,
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64.sp,
                color: AppColors.error,
              ),
              SizedBox(height: 16.h),
              Text(
                'Error loading statistics',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton.icon(
                onPressed: () => ref.read(statsProvider.notifier).loadStats(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final double min;
  final double max;
  final double avg;
  final bool isPercentage;

  const _StatCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.min,
    required this.max,
    required this.avg,
    this.isPercentage = false,
  });

  String _formatValue(double value) {
    final formatted = value.toStringAsFixed(1);
    return isPercentage ? '$formatted%' : formatted;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24.sp),
                ),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatDetail(
                  label: 'Min',
                  value: _formatValue(min),
                  color: color,
                ),
                _StatDetail(
                  label: 'Avg',
                  value: _formatValue(avg),
                  color: color,
                ),
                _StatDetail(
                  label: 'Max',
                  value: _formatValue(max),
                  color: color,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatDetail extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatDetail({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
