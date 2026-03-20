import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

class HowItWorksScreen extends StatefulWidget {
  const HowItWorksScreen({super.key});

  @override
  State<HowItWorksScreen> createState() => _HowItWorksScreenState();
}

class _HowItWorksScreenState extends State<HowItWorksScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _steps = [
    _Step(
      icon: Icons.camera_alt_outlined,
      color: AppColors.primaryBlue,
      title: 'Report an Issue',
      description:
          'Spot a problem in your district? Take a photo, record a voice note, or describe it in text. Pin it on the map so the right team knows exactly where to go.',
      badge: 'STEP 1',
    ),
    _Step(
      icon: Icons.person_pin_circle_outlined,
      color: AppColors.warning,
      title: 'Get Assigned Fast',
      description:
          'Your report is reviewed and automatically prioritised. A qualified field officer is assigned within 24–48 hours and you\'re notified immediately.',
      badge: 'STEP 2',
    ),
    _Step(
      icon: Icons.check_circle_outline,
      color: AppColors.success,
      title: 'Track & Confirm',
      description:
          'Follow your report\'s progress in real time. Once the issue is fixed, you confirm the resolution — your voice drives accountability in your community.',
      badge: 'STEP 3',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Skip',
                      style: AppTextStyles.link.copyWith(
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _steps.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, i) => _buildPage(_steps[i]),
              ),
            ),
            // Dots + button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  // Page dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_steps.length, (i) {
                      final active = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primaryBlue
                              : AppColors.inputBorder,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: AppColors.textWhite,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        _currentPage < _steps.length - 1
                            ? 'Next'
                            : 'Get Started',
                        style: AppTextStyles.button,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_Step step) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: step.color.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(step.icon, size: 80, color: step.color),
          ),
          const SizedBox(height: 32),
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: step.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              step.badge,
              style: AppTextStyles.badge.copyWith(
                color: step.color,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            step.title,
            style: AppTextStyles.h2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            step.description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.7,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Step {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final String badge;

  const _Step({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.badge,
  });
}
