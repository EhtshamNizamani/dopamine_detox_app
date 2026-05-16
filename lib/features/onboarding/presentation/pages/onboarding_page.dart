import 'package:dopamine_detox_app/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  double _demoScore = 100;

  late final AnimationController _pulseController;
  late final AnimationController _rocketController;

  bool _isRocketFlying = false;

  final List<OnboardingData> slides = [
    OnboardingData(
      title: 'Reclaim Your Focus',
      description:
          'Your brain is hijacked by cheap dopamine. Social media, junk food, endless scrolling — they steal your attention.',
      icon: Icons.bolt,
      color: Colors.teal,
    ),
    OnboardingData(
      title: 'Your Dopamine Score',
      description:
          'Start each day at 100. Every trigger you log reduces your score. Stay above 80 to keep your streak alive.',
      icon: Icons.speed,
      color: Colors.orange,
    ),
    OnboardingData(
      title: 'Build Streaks & Level Up',
      description:
          'Maintain control for consecutive days to unlock streaks, badges, and XP. Relapse is part of the journey — we help you see it.',
      icon: Icons.emoji_events,
      color: Colors.amber,
    ),
    OnboardingData(
      title: 'You\'re Ready',
      description:
          'Every log is a step toward awareness. Let\'s build your first streak together.',
      icon: Icons.rocket_launch,
      color: Colors.green,
    ),
  ];
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _rocketController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400), // Thora slow = cinematic
    );

    // Add status listener same rakho:
    _rocketController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _finishOnboarding();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    _rocketController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    context.read<OnboardingViewModel>().updatePage(index);
  }

  void _onNextPressed() {
    if (_currentPage == slides.length - 1) {
      setState(() => _isRocketFlying = true);
      _rocketController.forward(from: 0);
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    onPressed: () => _finishOnboarding(),
                    child: const Text(
                      'Skip',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  ),
                ),
              ),

              // Page View — Expanded so it takes available space
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: slides.length,
                  onPageChanged: _onPageChanged,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return _buildSlide(index);
                  },
                ),
              ),

              // Bottom Section — Fixed height, never overflows
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlide(int index) {
    final slide = slides[index];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxHeight < 600;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Visual Area — adaptive height
                _buildSlideVisual(index, isSmallScreen),
                SizedBox(height: isSmallScreen ? 24 : 40),

                // Title
                Text(
                  slide.title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 24 : 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  slide.description,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20), // Bottom padding for scroll
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSlideVisual(int index, bool isSmall) {
    switch (index) {
      case 0:
        return _buildPulseIcon(Icons.bolt, Colors.teal, isSmall);
      case 1:
        return _buildScoreDemo(isSmall);
      case 2:
        return _buildRewardsPreview(isSmall);
      case 3:
        return _buildReadyIcon(isSmall);
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Slide 0: Pulsing Icon ──
  Widget _buildPulseIcon(IconData icon, Color color, bool isSmall) {
    final size = isSmall ? 100.0 : 140.0;
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1 + (_pulseController.value * 0.15),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
              border: Border.all(
                color: color.withOpacity(0.3 + (_pulseController.value * 0.3)),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 30 + (_pulseController.value * 20),
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(icon, size: isSmall ? 45 : 60, color: color),
          ),
        );
      },
    );
  }

  // ── Slide 1: Interactive Score Demo ──
  Widget _buildScoreDemo(bool isSmall) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Score Card — compact on small screens
        Container(
          width: isSmall ? 170 : 200,
          padding: EdgeInsets.all(isSmall ? 14 : 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'DOPAMINE SCORE',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white54,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 6),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  '$_demoScore',
                  key: ValueKey<double>(_demoScore),
                  style: TextStyle(
                    fontSize: isSmall ? 36 : 48,
                    fontWeight: FontWeight.bold,
                    color: _demoScore >= 80
                        ? Colors.teal
                        : _demoScore >= 60
                        ? Colors.orange
                        : Colors.red,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _demoScore / 100,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation(
                    _demoScore >= 80 ? Colors.teal : Colors.orange,
                  ),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Demo Triggers — smaller on small screens
        Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: [
            _demoTriggerChip('Social Media', 1, -3, isSmall),
            _demoTriggerChip('Gaming', 2, -7, isSmall),
            _demoTriggerChip('Junk Food', 3, -15, isSmall),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Tap a trigger to see the score drop',
          style: TextStyle(fontSize: 11, color: Colors.white54),
        ),
      ],
    );
  }

  Widget _demoTriggerChip(
    String label,
    int intensity,
    int penalty,
    bool isSmall,
  ) {
    final colors = [Colors.green, Colors.orange, Colors.red];
    return ActionChip(
      padding: isSmall ? EdgeInsets.zero : null,
      labelPadding: isSmall ? const EdgeInsets.symmetric(horizontal: 6) : null,
      avatar: Icon(
        Icons.add,
        size: isSmall ? 14 : 16,
        color: colors[intensity - 1],
      ),
      label: Text(
        '$label (${penalty.abs()})',
        style: TextStyle(
          fontSize: isSmall ? 11 : 12,
          color: colors[intensity - 1],
        ),
      ),
      backgroundColor: colors[intensity - 1].withOpacity(0.1),
      side: BorderSide(color: colors[intensity - 1].withOpacity(0.3)),
      onPressed: () {
        setState(() {
          _demoScore = (_demoScore + penalty).clamp(0, 100).toDouble();
        });
      },
    );
  }

  // ── Slide 2: Rewards Preview ──
  Widget _buildRewardsPreview(bool isSmall) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Streak Card
        Container(
          width: isSmall ? 240 : 260,
          padding: EdgeInsets.all(isSmall ? 12 : 16),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.local_fire_department,
                color: Colors.orange,
                size: 30,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Current Streak',
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Text(
                          '7 days',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            '🔥 On Fire',
                            style: TextStyle(fontSize: 9, color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Badges Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _badgePreview('🏅', 'First Log', isSmall),
            const SizedBox(width: 6),
            _badgePreview('🔥', '3-Day', isSmall),
            const SizedBox(width: 6),
            _badgePreview('⭐', 'Level 5', isSmall),
            const SizedBox(width: 6),
            _badgePreview('🧘', 'Perfect', isSmall),
          ],
        ),
        const SizedBox(height: 12),

        // XP Bar
        SizedBox(
          width: isSmall ? 240 : 260,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Level 3',
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '250 XP',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: 0.6,
                  backgroundColor: Colors.grey[800],
                  valueColor: const AlwaysStoppedAnimation(Colors.amber),
                  minHeight: 5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _badgePreview(String emoji, String label, bool isSmall) {
    final size = isSmall ? 40.0 : 48.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.teal.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(emoji, style: TextStyle(fontSize: isSmall ? 18 : 22)),
          ),
        ),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.white54)),
      ],
    );
  }

  // ── Slide 3: Ready Icon ──
  Widget _buildReadyIcon(bool isSmall) {
    // Jab rocket fly mode on ho, usi icon ko animate karo
    if (_isRocketFlying) {
      return AnimatedBuilder(
        animation: _rocketController,
        builder: (context, child) {
          final screenW = MediaQuery.of(context).size.width;
          final screenH = MediaQuery.of(context).size.height;

          return Transform.translate(
            offset: Offset(
              _rocketController.value *
                  screenW *
                  0.4, // ← Right zyada (0.5 → 0.9)
              -_rocketController.value *
                  screenH *
                  0.6, // ← Up kam (0.45 → 0.15)
            ),
            child: Transform.rotate(
              angle: -0.3, // Rocket ka head up-right ki taraf tilt
              child: Transform.scale(
                scale: 1 + (_rocketController.value * 0.4),
                child: Icon(
                  Icons.rocket_launch,
                  size: isSmall ? 50 : 70,
                  color: Colors.green,
                ),
              ),
            ),
          );
        },
      );
    }

    // Normal state
    return Container(
      width: isSmall ? 100 : 140,
      height: isSmall ? 100 : 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.green.withOpacity(0.15),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Icon(
        Icons.rocket_launch,
        size: isSmall ? 50 : 70,
        color: Colors.green,
      ),
    );
  }

  // ── Bottom Section ──
  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🎯 Animated Progress Bar
          TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: 0,
              end: (_currentPage + 1) / slides.length,
            ),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOutCubic,
            builder: (context, value, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: value,
                  backgroundColor: Colors.white10,
                  valueColor: const AlwaysStoppedAnimation(Colors.teal),
                  minHeight: 4,
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              slides.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index ? Colors.teal : Colors.white24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isRocketFlying ? null : _onNextPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentPage == slides.length - 1
                    ? Colors.green
                    : Colors.teal,
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor:
                    (_currentPage == slides.length - 1
                            ? Colors.green
                            : Colors.teal)
                        .withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: _isRocketFlying
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _currentPage == slides.length - 1
                          ? 'Start My Journey 🚀'
                          : 'Next',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _finishOnboarding() async {
    await context.read<OnboardingViewModel>().completeOnboarding();
    if (context.mounted) {
      context.go('/dashboard');
    }
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
