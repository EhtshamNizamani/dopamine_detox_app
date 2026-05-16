import 'package:flutter/material.dart';

class HowItWorksBottomSheet extends StatelessWidget {
  const HowItWorksBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const HowItWorksBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A2F3A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'How Dopamine Detox Works',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Understand your score, streaks, and rewards',
              style: TextStyle(fontSize: 14, color: Colors.white60),
            ),
            const SizedBox(height: 24),

            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: const [
                  _RuleCard(
                    icon: Icons.speed,
                    iconColor: Colors.teal,
                    title: 'Dopamine Score (0-100)',
                    description:
                        'Every day starts at 100. Logging triggers reduces your score based on intensity:\n'
                        '• Low = -3\n'
                        '• Medium = -7\n'
                        '• High = -15',
                  ),
                  _RuleCard(
                    icon: Icons.local_fire_department,
                    iconColor: Colors.orange,
                    title: 'Streak System',
                    description:
                        'A streak is a consecutive run of "Good Days."\n\n'
                        'If your daily score is 80 or above, your streak continues. '
                        'If it drops below 80, your streak resets to 0.',
                  ),
                  _RuleCard(
                    icon: Icons.star_rounded,
                    iconColor: Colors.amber,
                    title: 'XP & Levels',
                    description:
                        'XP is earned only for positive behavior:\n'
                        '• Good Day (Score ≥ 80) = +20 XP\n'
                        '• Perfect Day (Score = 100) = +50 XP\n'
                        '• Maintaining a streak = +10 XP\n'
                        '• Daily app open = +2 XP\n\n'
                        'Levels are permanent and never decrease.',
                  ),
                  _RuleCard(
                    icon: Icons.emoji_events,
                    iconColor: Colors.green,
                    title: 'Badges',
                    description:
                        'Unlock badges automatically by achieving milestones:\n'
                        '🏅 First Log\n'
                        '🔥 3-Day, 7-Day, 10-Day Streaks\n'
                        '⭐ Level 5 & Level 10\n'
                        '🧘 Perfect Day (Score = 100)',
                  ),
                  _RuleCard(
                    icon: Icons.warning_amber_rounded,
                    iconColor: Colors.red,
                    title: 'Streak Break Warning',
                    description:
                        'Before logging a trigger that would drop your score below 80 and break your active streak, '
                        'the app will warn you so you can make an informed choice.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Got it',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const _RuleCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}