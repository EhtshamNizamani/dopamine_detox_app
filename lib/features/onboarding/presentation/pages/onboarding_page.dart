import 'package:dopamine_detox_app/core/di/injection.dart';
import 'package:dopamine_detox_app/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  
  final List<OnboardingData> slides = [
    OnboardingData(
      title: 'Reclaim Your Focus',
      description: 'Dopamine detox helps you break free from addictive habits and regain control of your attention.',
      icon: Icons.remove_red_eye,
    ),
    OnboardingData(
      title: 'Track Triggers',
      description: 'Log activities that spike your dopamine: social media, gaming, junk food, and more.',
      icon: Icons.track_changes,
    ),
    OnboardingData(
      title: 'Build Healthy Streaks',
      description: 'Watch your dopamine score improve and maintain streaks for lasting change.',
      icon: Icons.bolt,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Builder(
      
      builder: (context) {

  return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.teal.shade900, Colors.black],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: slides.length,
                  onPageChanged: (index) {
                    context.read<OnboardingViewModel>().updatePage(index);
                  },
                  itemBuilder: (context, index) {
                    return OnboardingSlide(slide: slides[index]);
                  },
                ),
              ),
              _buildBottomSection(),
            ],
          ),
        ),
      );
      },
    );}

  Widget _buildBottomSection() {
    return Consumer<OnboardingViewModel>(
      builder: (context, viewModel, child) {
        return Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  slides.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: viewModel.currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: viewModel.currentPage == index
                          ? Colors.teal
                          : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    if (viewModel.currentPage == slides.length - 1) {
                      await viewModel.completeOnboarding();
                      if (context.mounted) {
                        context.go('/dashboard');
                      }
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    viewModel.currentPage == slides.length - 1
                        ? 'Get Started'
                        : 'Next',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  
  OnboardingData({required this.title, required this.description, required this.icon});
}

class OnboardingSlide extends StatelessWidget {
  final OnboardingData slide;
  
  const OnboardingSlide({super.key, required this.slide});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(slide.icon, size: 100, color: Colors.teal),
          const SizedBox(height: 40),
          Text(
            slide.title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            slide.description,
            style: const TextStyle(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}