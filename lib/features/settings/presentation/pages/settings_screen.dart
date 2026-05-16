import 'package:dopamine_detox_app/core/constants/app_constants.dart';
import 'package:dopamine_detox_app/core/di/injection.dart';
import 'package:dopamine_detox_app/core/widgets/how_it_works_bottom_sheet.dart';
import 'package:dopamine_detox_app/features/settings/presentation/viewmodels/settings_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

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
    // 🛠️ FIX: Delay load until after first frame to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadSettings();
    });
  }

  Future<void> _launchPrivacyPolicy() async {
    final uri = Uri.parse(
      'https://ehtshamnizamani.github.io/dopamine-detox-privacy/',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        _showSnackBar('Could not open privacy policy');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      body: Consumer<SettingsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.settings == null) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.teal),
            );
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Header with Back Button ──
              SliverToBoxAdapter(child: _buildHeader(context)),

              // ── Settings Content ──
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Section: General
                    // const _SectionTitle(title: 'General', icon: Icons.tune),
                    // _SettingsCard(
                    //   children: [
                    //     // 🛠️ FIX: Notifications removed until service is implemented
                    //     // Instead show Coming Soon tile
                    //     _SettingsTile(
                    //       icon: Icons.notifications_active_rounded,
                    //       iconColor: Colors.teal,
                    //       title: 'Daily Reminders',
                    //       subtitle: 'Coming in next update',
                    //       trailing: Container(
                    //         padding: const EdgeInsets.symmetric(
                    //           horizontal: 8,
                    //           vertical: 4,
                    //         ),
                    //         decoration: BoxDecoration(
                    //           color: Colors.amber.withOpacity(0.15),
                    //           borderRadius: BorderRadius.circular(8),
                    //         ),
                    //         child: Text(
                    //           'SOON',
                    //           style: TextStyle(
                    //             fontSize: 10,
                    //             fontWeight: FontWeight.w700,
                    //             color: Colors.amber.shade400,
                    //           ),
                    //         ),
                    //       ),
                    //       onTap: () => _showSnackBar('Notifications coming soon!'),
                    //     ),
                    //   ],
                    // ),
                    const SizedBox(height: 24),

                    // Section: Data & Privacy
                    const _SectionTitle(
                      title: 'Data & Privacy',
                      icon: Icons.security,
                    ),
                    _SettingsCard(
                      children: [
                        _SettingsTile(
                          icon: Icons.delete_sweep_rounded,
                          iconColor: Colors.red.shade400,
                          title: 'Reset All Data',
                          subtitle: 'Clear logs, XP, badges, and streaks',
                          textColor: Colors.red.shade300,
                          onTap: () => _showResetDialog(context, viewModel),
                        ),
                        const Divider(height: 1, indent: 56),
                        _SettingsTile(
                          icon: Icons.description_outlined,
                          iconColor: Colors.blue.shade300,
                          title: 'Privacy Policy',
                          subtitle: 'How we handle your data',
                          onTap: _launchPrivacyPolicy,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Section: About
                    const _SectionTitle(
                      title: 'About',
                      icon: Icons.info_outline,
                    ),
                    _SettingsCard(
                      children: [
                        _SettingsTile(
                          icon: Icons.help_outline_rounded,
                          iconColor: Colors.teal,
                          title: 'How It Works',
                          subtitle: 'Rules, scoring, streaks & rewards',
                          onTap: () => HowItWorksBottomSheet.show(context),
                        ),

                        _SettingsTile(
                          icon: Icons.rocket_launch_outlined,
                          iconColor: Colors.amber,
                          title: 'App Version',
                          subtitle: AppConstants.appVersion,
                          showArrow: false,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Footer
                    Center(
                      child: Text(
                        'Dopamine Detox',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Break the loop. Reclaim your focus.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 48, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF203A43).withOpacity(0.5),
            const Color(0xFF0F2027),
          ],
        ),
      ),
      child: Row(
        children: [
          // 🛠️ FIX: Back Button
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
            tooltip: 'Back',
          ),
          const SizedBox(width: 8),
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, SettingsViewModel viewModel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2F3A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.red.withOpacity(0.3)),
        ),
        icon: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.warning_amber_rounded,
            color: Colors.red.shade400,
            size: 32,
          ),
        ),
        title: const Text(
          'Reset Everything?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This will permanently delete:',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            SizedBox(height: 12),
            _ResetItem(icon: Icons.history, text: 'All activity logs'),
            _ResetItem(icon: Icons.emoji_events, text: 'XP, levels & badges'),
            _ResetItem(
              icon: Icons.local_fire_department,
              text: 'Current streak',
            ),
            _ResetItem(icon: Icons.settings, text: 'App preferences'),
            SizedBox(height: 16),
            Text(
              'This action cannot be undone.',
              style: TextStyle(
                color: Colors.red,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white70,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              HapticFeedback.heavyImpact();
              final success = await viewModel.resetData();
              if (success && context.mounted) {
                _showSnackBar('All data reset successfully');
                context.go('/onboarding');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Reset Everything',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// REUSABLE WIDGETS
// ════════════════════════════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.teal.withOpacity(0.7)),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.teal.withOpacity(0.7),
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A2F3A).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color? textColor;
  final VoidCallback? onTap;
  final bool showArrow;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.textColor,
    this.onTap,
    this.showArrow = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.white.withOpacity(0.9),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
      ),
      trailing:
          trailing ??
          (showArrow
              ? Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white.withOpacity(0.3),
                )
              : null),
      onTap: onTap,
    );
  }
}

class _ResetItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ResetItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white38),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(color: Colors.white60, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
