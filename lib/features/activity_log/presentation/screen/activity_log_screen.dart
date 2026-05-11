import 'package:dopamine_detox_app/features/activity_log/presentation/providers/activity_log_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/injection.dart';

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
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Activity:', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
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
                    child: Text(viewModel.error!, style: const TextStyle(color: Colors.red)),
                  ),
                ElevatedButton(
                  onPressed: (selectedActivity != null && selectedIntensity != null)
                      ? () async {
                          final success = await viewModel.logActivity(
                            selectedActivity!,
                            selectedIntensity!,
                          );
                          if (success && context.mounted) {
                            Navigator.pop(context);
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Save Log', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          );
        },
      ),
    );
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