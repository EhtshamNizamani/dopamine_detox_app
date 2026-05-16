import 'package:dopamine_detox_app/core/constants/app_constants.dart';
import 'package:dopamine_detox_app/features/activity_log/presentation/providers/activity_log_viewmodel.dart';
import 'package:dopamine_detox_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  final List<String> activities = [
    'Social Media', 'Gaming', 'Junk Food',
    'YouTube', 'Porn', 'News Binge', 'Online Shopping'
  ];
  int? selectedIntensity;
  String? selectedActivity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log a Trigger')),
      body: Consumer<ActivityLogViewModel>(
        builder: (context, viewModel, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Activity:', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: activities.map((activity) {
                    return ChoiceChip(
                      label: Text(activity),
                      selected: selectedActivity == activity,
                      onSelected: (selected) {
                        setState(() {
                          selectedActivity = selected ? activity : null;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                const Text('Intensity:', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _intensityChip(1, 'Low', Colors.green),
                    _intensityChip(2, 'Medium', Colors.orange),
                    _intensityChip(3, 'High', Colors.red),
                  ],
                ),
                const Spacer(),
                if (viewModel.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      viewModel.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: viewModel.isLoading ||
                            selectedActivity == null ||
                            selectedIntensity == null
                        ? null
                        : () => _onSavePressed(viewModel),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                    child: viewModel.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save Log', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _onSavePressed(ActivityLogViewModel viewModel) async {
    if (selectedActivity == null || selectedIntensity == null) return;

    // 1. Calculate projected score
    final (currentScore, projectedScore) =
        await viewModel.calculateProjectedScore(selectedIntensity!);

    // 2. Get current streak from dashboard
    final dashboardVM = context.read<DashboardViewModel>();
    final currentStreak = dashboardVM.streak;

    // 3. Check if this log will break an ACTIVE streak
    // Conditions: streak > 0 AND current score >= 80 AND projected < 80
    final willBreakStreak = currentStreak > 0 &&
        currentScore >= AppConstants.streakThreshold &&
        projectedScore < AppConstants.streakThreshold;

    if (willBreakStreak && mounted) {
      // Show warning dialog
      final shouldProceed = await _showStreakBreakWarning(
        context: context,
        currentScore: currentScore,
        projectedScore: projectedScore,
        streakDays: currentStreak,
        activityName: selectedActivity!,
      );

      if (!shouldProceed) return; // User cancelled
    }

    // 4. Proceed to log
    final success = await viewModel.logActivity(
      selectedActivity!,
      selectedIntensity!,
    );

    if (success && mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<bool> _showStreakBreakWarning({
    required BuildContext context,
    required int currentScore,
    required int projectedScore,
    required int streakDays,
    required String activityName,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 40),
        title: const Text('Streak Break Warning!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Logging "$activityName" will drop your score from $currentScore to $projectedScore.',
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your $streakDays-day streak will break!',
                      style: TextStyle(
                        color: Colors.orange.shade300,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Are you sure you want to log this?',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade800,
            ),
            child: const Text('Yes, Log Anyway'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Widget _intensityChip(int value, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selectedIntensity == value,
        onSelected: (selected) {
          setState(() {
            selectedIntensity = selected ? value : null;
          });
        },
        selectedColor: color,
        backgroundColor: Colors.grey[800],
      ),
    );
  }
}

