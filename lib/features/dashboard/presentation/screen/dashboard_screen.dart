import 'package:dopamine_detox_app/core/di/injection.dart';
import 'package:dopamine_detox_app/features/activity_log/domain/entities/log_entry_entity.dart';
import 'package:dopamine_detox_app/features/activity_log/presentation/screen/activity_log_screen.dart';
import 'package:dopamine_detox_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DashboardViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<DashboardViewModel>();
    _viewModel.loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dopamine Detox'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Consumer<DashboardViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${viewModel.error}'),
                  ElevatedButton(
                    onPressed: () => viewModel.loadDashboardData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => viewModel.loadDashboardData(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _DopamineScoreCard(score: viewModel.dopamineScore),
                const SizedBox(height: 16),
                _StreakCard(streak: viewModel.streak),
                const SizedBox(height: 16),
                _RecentLogsSection(logs: viewModel.recentLogs),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ActivityLogScreen()),
          );
          if (result == true) {
            _viewModel.loadDashboardData(); // refresh after logging
          }
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _DopamineScoreCard extends StatelessWidget {
  final int score;
  const _DopamineScoreCard({required this.score});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Current Dopamine Score',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              '$score',
              style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.grey[800],
              valueColor: const AlwaysStoppedAnimation(Colors.teal),
              borderRadius: BorderRadius.circular(10),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final int streak;
  const _StreakCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.local_fire_department, color: Colors.orange, size: 40),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Current Streak', style: TextStyle(color: Colors.white70)),
                Text(
                  '$streak ${streak == 1 ? 'day' : 'days'}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentLogsSection extends StatelessWidget {
  final List<LogEntryEntity> logs;
  const _RecentLogsSection({required this.logs});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Logs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        if (logs.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: Text('No recent logs. Tap + to log a trigger.')),
            ),
          )
        else
          ...logs.map((log) => _LogTile(log: log)),
      ],
    );
  }
}

class _LogTile extends StatelessWidget {
  final LogEntryEntity log;
  const _LogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    String intensityText;
    Color intensityColor;
    switch (log.intensity) {
      case 1:
        intensityText = 'Low';
        intensityColor = Colors.green;
        break;
      case 2:
        intensityText = 'Medium';
        intensityColor = Colors.orange;
        break;
      case 3:
        intensityText = 'High';
        intensityColor = Colors.red;
        break;
      default:
        intensityText = 'Low';
        intensityColor = Colors.green;
    }
    return Card(
      child: ListTile(
        leading: const Icon(Icons.warning_amber, color: Colors.teal),
        title: Text(log.activityName),
        subtitle: Row(
          children: [
            Icon(Icons.straighten, size: 14, color: intensityColor),
            const SizedBox(width: 4),
            Text(intensityText),
            const SizedBox(width: 12),
            Icon(Icons.access_time, size: 14),
            const SizedBox(width: 4),
            Text(_formatTime(log.timestamp)),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}