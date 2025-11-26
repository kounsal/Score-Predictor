import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../study_tracker/presentation/providers/records_provider.dart';
import '../../../study_tracker/presentation/providers/model_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(recordsProvider);
    final modelAsync = ref.watch(modelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Score Tracker'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(recordsProvider.notifier).loadRecords();
          ref.read(modelProvider.notifier).loadModelInfo();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Card
              Card(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome! 👋',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Track your study hours and predict your scores',
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

              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.book_outlined,
                      title: 'Records',
                      value: recordsAsync.when(
                        data: (records) => records.length.toString(),
                        loading: () => '...',
                        error: (_, __) => '0',
                      ),
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.model_training_outlined,
                      title: 'Model',
                      value: modelAsync.when(
                        data: (model) => model?.isValid ?? false ? 'Trained' : 'Not Trained',
                        loading: () => '...',
                        error: (_, __) => 'Error',
                      ),
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Action Buttons
              _ActionButton(
                icon: Icons.add_circle_outline,
                title: 'Add Record',
                subtitle: 'Add new study data',
                color: AppColors.primary,
                onTap: () => context.push('/add-record'),
              ),
              SizedBox(height: 12.h),
              _ActionButton(
                icon: Icons.list_alt_outlined,
                title: 'View Records',
                subtitle: 'See all your study records',
                color: AppColors.secondary,
                onTap: () => context.push('/records'),
              ),
              SizedBox(height: 12.h),
              _ActionButton(
                icon: Icons.analytics_outlined,
                title: 'Statistics',
                subtitle: 'View detailed statistics',
                color: AppColors.warning,
                onTap: () => context.push('/stats'),
              ),
              SizedBox(height: 12.h),
              _ActionButton(
                icon: Icons.psychology_outlined,
                title: 'Predict Score',
                subtitle: 'Get score predictions',
                color: Colors.purple,
                onTap: () => context.push('/predict'),
              ),
              SizedBox(height: 12.h),
              _ActionButton(
                icon: Icons.settings_suggest_outlined,
                title: 'Train Model',
                subtitle: 'Train the prediction model',
                color: Colors.orange,
                onTap: () => context.push('/train-model'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Icon(icon, size: 32.sp, color: color),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
