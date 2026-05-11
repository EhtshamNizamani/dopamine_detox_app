import 'package:dopamine_detox_app/core/constants/app_constants.dart';
import 'package:dopamine_detox_app/core/di/injection.dart';
import 'package:dopamine_detox_app/features/settings/presentation/viewmodels/settings_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SettingsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<SettingsViewModel>();
    _viewModel.loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer<SettingsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.settings == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            children: [
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Enable Notifications'),
                subtitle: const Text('Get daily reminders and streak alerts'),
                value: viewModel.settings?.notificationsEnabled ?? true,
                onChanged: (value) async {
                  await viewModel.toggleNotifications(value);
                  // If enabling, request permission and schedule notifications
                  if (value) {
                    // We'll integrate notification service later
                  }
                },
                secondary: const Icon(Icons.notifications_active),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete_sweep, color: Colors.red),
                title: const Text('Reset All Data'),
                subtitle: const Text('Delete all logs and reset onboarding'),
                onTap: () => _showResetDialog(context, viewModel),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Version'),
                subtitle: Text(AppConstants.appVersion),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showResetDialog(BuildContext context, SettingsViewModel viewModel) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset All Data?'),
        content: const Text('This will delete all your activity logs and reset your settings. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await viewModel.resetData();
              if (success && context.mounted) {
                // Show snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data reset successfully')),
                );
                // Optionally navigate to onboarding
                context.go('/onboarding');
              }
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}