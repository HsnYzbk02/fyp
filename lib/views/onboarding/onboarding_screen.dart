import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../theme/app_theme.dart';
import '../home/main_nav_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      emoji: '💪',
      title: 'Smart Muscle Recovery',
      subtitle:
          'AI-powered recommendations personalized to your body and training history.',
      color: AppTheme.primaryBlue,
    ),
    _OnboardingPage(
      emoji: '⌚',
      title: 'Apple Watch Integration',
      subtitle:
          'We read your HRV, heart rate, sleep, and workout data directly from your Apple Watch.',
      color: AppTheme.accentGreen,
    ),
    _OnboardingPage(
      emoji: '🤖',
      title: 'AI-Powered Insights',
      subtitle:
          'Our AI analyzes your biometrics and tells you exactly when to train, rest, stretch, or hydrate.',
      color: const Color(0xFF9B59B6),
    ),
    _OnboardingPage(
      emoji: '🏃',
      title: 'Ready to Recover Smarter?',
      subtitle:
          'Set up your profile, grant HealthKit access, and get your first recovery score in seconds.',
      color: AppTheme.warningOrange,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Skip'),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => _pages[i],
              ),
            ),

            // Dots
            SmoothPageIndicator(
              controller: _controller,
              count: _pages.length,
              effect: WormEffect(
                activeDotColor: _pages[_currentPage].color,
                dotHeight: 8,
                dotWidth: 8,
              ),
            ),

            const SizedBox(height: 24),

            // Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _pages[_currentPage].color,
                  ),
                  onPressed: _currentPage < _pages.length - 1
                      ? () => _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          )
                      : _finish,
                  child: Text(
                    _currentPage < _pages.length - 1 ? 'Next' : "Let's Go!",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _finish() {
    Hive.box('settings').put('has_onboarded', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavScreen()),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;

  const _OnboardingPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 56)),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: const TextStyle(
                fontSize: 16, color: Colors.grey, height: 1.6),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
