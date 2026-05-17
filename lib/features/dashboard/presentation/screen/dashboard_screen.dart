import 'package:dopamine_detox_app/core/constants/app_constants.dart';
import 'package:dopamine_detox_app/core/di/injection.dart';
import 'package:dopamine_detox_app/core/widgets/how_it_works_bottom_sheet.dart';
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
  late final DashboardViewModel _dashboardVM;
  late final GamificationViewModel _gamificationVM;

  @override
  void initState() {
    super.initState();
    _dashboardVM = sl<DashboardViewModel>();
    _gamificationVM = sl<GamificationViewModel>();

    // Badge unlock listener
    _dashboardVM.addListener(_onDashboardUpdate);

WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) {
      _loadAllData();
    }
  });
  }

  void _loadAllData() {
    _dashboardVM.loadDashboardData();
    _gamificationVM.loadGamification();
  }

void _onDashboardUpdate() {
  // 1. Badge toast (already hai)
  if (_dashboardVM.newlyUnlockedBadges.isNotEmpty && mounted) {
    _showBadgeUnlocked(_dashboardVM.newlyUnlockedBadges);
    _dashboardVM.clearNewBadges();
  }

  // 🆕 2. XP Toast — jab streak update se XP mile
  if (_dashboardVM.lastXPAwarded > 0 && mounted) {
    _showXPAwarded(_dashboardVM.lastXPAwarded);
    _dashboardVM.clearLastXP();
  }
}

// 🆕 YE METHOD ADD KARO (baqi _showBadgeUnlocked ke saath)
void _showXPAwarded(int xp) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Colors.amber),
          const SizedBox(width: 8),
          Text(
            'Good Day! +$xp XP',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
      backgroundColor: Colors.teal.shade800,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

  void _showBadgeUnlocked(List<String> badges) {
    final names = badges
        .map((id) => AppConstants.badgeNames[id] ?? id)
        .join('\n• ');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 Badge Unlocked!\n• $names'),
        backgroundColor: Colors.amber.shade800,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _onRefresh() async {
    await _dashboardVM.loadDashboardData();
    await _gamificationVM.loadGamification();
  }


  @override
  void dispose() {
    _dashboardVM.removeListener(_onDashboardUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('running');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dopamine Detox'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Consumer<DashboardViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading && vm.todayLogs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Score Card ──
                _ScoreCard(
                  score: vm.dopamineScore,
                  label: vm.getScoreLabel(),
                  color: vm.getScoreColor(),
                ),
                const SizedBox(height: 16),

                // ── Streak Card ──
                _StreakCard(streak: vm.streak),
                const SizedBox(height: 16),

                // ── Gamification Card (Level + Badges) ──
                _GamificationCardWrapper(),
                const SizedBox(height: 24),

                // ── Recent Logs Header ──
                _SectionHeader(title: 'Recent Logs'),
                const SizedBox(height: 8),

                // ── Logs List ──
                if (vm.recentLogs.isEmpty)
                  const _EmptyLogsCard()
                else
                  ...vm.recentLogs.map((log) => _LogTile(log: log)),
              ],
            ),
          );
        },
      ),
floatingActionButton: Consumer<DashboardViewModel>(
  builder: (context, _viewModel, _) {
    return FloatingActionButton(
      onPressed: () async {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => const ActivityLogScreen()),
        );
        print(  'Returned from log screen with result: $result');
        // Agar log add hua to donon VMs refresh karo
        if (result == true) {
         await _viewModel.loadDashboardData();
        await  _gamificationVM.loadGamification();
        }
      },
      backgroundColor: Colors.teal,
      child: const Icon(Icons.add),
    );
  }
),);
  }
}

// ════════════════════════════════════════════════════════════
// WIDGETS (Clean Separation)
// ════════════════════════════════════════════════════════════

class _ScoreCard extends StatelessWidget {
  final int score;
  final String label;
  final Color color;

  const _ScoreCard({
    required this.score,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
                      Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),

              const Text(
                'Dopamine Score',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(width: 8),
              Spacer(),
              GestureDetector(
                onTap: () => HowItWorksBottomSheet.show(context),
                child: Icon(
                  Icons.help_outline,
                  size: 24,
                  color: Colors.teal.withOpacity(0.7),
                ),
              ),
            ],
          ),

            const SizedBox(height: 8),
            Text(
              '$score',
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: score / 100,
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 10,
              ),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_fire_department,
                color: Colors.orange,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Streak',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$streak ${streak == 1 ? 'day' : 'days'}',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (streak >= 3)
              Chip(
                label: const Text('🔥 On Fire'),
                backgroundColor: Colors.orange.shade900,
                labelStyle: const TextStyle(fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
}

/// Gamification card with its own Consumer (isolated rebuilds)
class _GamificationCardWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GamificationViewModel>(
      builder: (context, vm, _) {
        if (vm.gamification == null) {
          return const SizedBox.shrink();
        }
        return _GamificationCard(gamification: vm.gamification!);
      },
    );
  }
}

class _GamificationCard extends StatelessWidget {
  final GamificationEntity gamification;
  const _GamificationCard({required this.gamification});

  @override
  Widget build(BuildContext context) {
    final progress = gamification.currentLevelProgress;
    final needed = gamification.xpForNextLevel;
    final progressPercent = progress / needed;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.military_tech, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      'Level ${gamification.level}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${gamification.totalXP} XP',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progressPercent.clamp(0.0, 1.0),
                backgroundColor: Colors.grey[800],
                valueColor: const AlwaysStoppedAnimation(Colors.amber),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$progress / $needed XP to next level',
              style: const TextStyle(fontSize: 12, color: Colors.white60),
            ),
            const SizedBox(height: 16),
            const Text(
              'Badges',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _buildBadges(gamification.unlockedBadges),
          ],
        ),
      ),
    );
  }

  Widget _buildBadges(List<String> badgeIds) {
    if (badgeIds.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: const Text(
          'No badges yet. Keep going! 💪',
          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: badgeIds.map((id) {
        final name = AppConstants.badgeNames[id] ?? id;
        return Chip(
          avatar: const Icon(Icons.emoji_events, size: 18, color: Colors.amber),
          label: Text(name),
          backgroundColor: Colors.teal.shade900.withOpacity(0.6),
          side: BorderSide(color: Colors.teal.shade700),
        );
      }).toList(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _EmptyLogsCard extends StatelessWidget {
  const _EmptyLogsCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, color: Colors.grey[600]),
            const SizedBox(width: 8),
            const Text(
              'No logs yet. Tap "Log Trigger" to start.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  final LogEntryEntity log;
  const _LogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (log.intensity) {
      1 => ('Low', Colors.green),
      2 => ('Medium', Colors.orange),
      _ => ('High', Colors.red),
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(Icons.warning_amber, color: color, size: 20),
        ),
        title: Text(log.activityName),
        subtitle: Text(
          '$label • ${_timeAgo(log.timestamp)}',
          style: TextStyle(color: Colors.white60, fontSize: 13),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}