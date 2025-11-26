import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/study_tracker/presentation/screens/add_record_screen.dart';
import '../../features/study_tracker/presentation/screens/predict_screen.dart';
import '../../features/study_tracker/presentation/screens/records_screen.dart';
import '../../features/study_tracker/presentation/screens/stats_screen.dart';
import '../../features/study_tracker/presentation/screens/train_model_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/add-record',
        name: 'add-record',
        builder: (context, state) => const AddRecordScreen(),
      ),
      GoRoute(
        path: '/records',
        name: 'records',
        builder: (context, state) => const RecordsScreen(),
      ),
      GoRoute(
        path: '/stats',
        name: 'stats',
        builder: (context, state) => const StatsScreen(),
      ),
      GoRoute(
        path: '/predict',
        name: 'predict',
        builder: (context, state) => const PredictScreen(),
      ),
      GoRoute(
        path: '/train-model',
        name: 'train-model',
        builder: (context, state) => const TrainModelScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error.toString(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
