import 'package:dopamine_detox_app/core/di/injection.dart';
import 'package:dopamine_detox_app/features/activity_log/domain/entities/log_entry_entity.dart';
import 'package:dopamine_detox_app/features/activity_log/presentation/screen/activity_log_screen.dart';
import 'package:dopamine_detox_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:dopamine_detox_app/features/gamification/domain/entities/gamification.dart';
import 'package:dopamine_detox_app/features/gamification/presentation/providers/gamification_provider.dart';
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
  late GamificationViewModel _gamificationVM;
  @override
  void initState() {
    super.initState();
    _viewModel = sl<DashboardViewModel>();
      _gamificationVM = sl<GamificationViewModel>();
  _gamificationVM.loadGamification();

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
// Inside the Column after _StreakCard
const SizedBox(height: 16),
Consumer<GamificationViewModel>(
  builder: (context, gamificationVM, child) {
    if (gamificationVM.gamification == null) {
      return const SizedBox.shrink();
    }
    return _GamificationCard(gamification: gamificationVM.gamification!);
  },
),
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

class _GamificationCard extends StatelessWidget {
  final GamificationEntity gamification;
  const _GamificationCard({required this.gamification});

  @override
  Widget build(BuildContext context) {
    int currentProgress = gamification.currentLevelProgress;
    int needed = gamification.xpForNextLevel - ((gamification.level - 1) * 100);
    double progress = currentProgress / needed;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Level ${gamification.level}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
                Text('${gamification.totalXP} XP', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress, backgroundColor: Colors.grey[800], valueColor: const AlwaysStoppedAnimation(Colors.orange)),
            const SizedBox(height: 8),
            Text('$currentProgress / $needed XP to next level', style: const TextStyle(fontSize: 12, color: Colors.white70)),
            const SizedBox(height: 12),
            const Text('Badges:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                if (gamification.unlockedBadges.contains('First Log')) _badgeChip('🏅 First Log'),
                if (gamification.unlockedBadges.contains('3-Day Streak')) _badgeChip('🔥 3-Day Streak'),
                if (gamification.unlockedBadges.contains('7-Day Streak')) _badgeChip('🏆 7-Day Streak'),
                if (gamification.unlockedBadges.contains('Level 5')) _badgeChip('⭐ Level 5'),
                if (gamification.unlockedBadges.isEmpty) const Text('No badges yet', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _badgeChip(String label) {
    return Chip(label: Text(label), backgroundColor: Colors.teal.shade800);
  }
}