import 'package:flutter/material.dart';
import '../theme.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Welcome to GreenSteps 🌱',
      'subtitle': 'Track, reduce, and share your carbon footprint!',
      'image': 'assets/onboarding1.png', // Placeholder
    },
    {
      'title': 'Log Eco Actions',
      'subtitle': 'Easily log daily eco-friendly actions and see your impact.',
      'image': 'assets/onboarding2.png', // Placeholder
    },
    {
      'title': 'Compete & Share',
      'subtitle':
          'Share progress and compete with friends for a greener world.',
      'image': 'assets/onboarding3.png', // Placeholder
    },
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color mainGreen = AppTheme.primaryGreen;
    final Color accentGreen = AppTheme.accentGreen;
    final double borderRadius = AppTheme.borderRadius;
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Placeholder for illustration
                        Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            color: mainGreen.withOpacity(0.13),
                            borderRadius: BorderRadius.circular(borderRadius),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.eco,
                              size: 100,
                              color: accentGreen,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          page['title']!,
                          style: GoogleFonts.nunito(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: accentGreen,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page['subtitle']!,
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            color: mainGreen,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 16,
                  ),
                  width: _currentPage == index ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? accentGreen
                        : mainGreen.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16,
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(borderRadius),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Login',
                        style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(borderRadius),
                        ),
                        side: BorderSide(color: mainGreen),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text('Sign Up', style: GoogleFonts.nunito()),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      // Skip onboarding, go to dashboard (for demo)
                      Navigator.pushReplacementNamed(context, '/dashboard');
                    },
                    child: Text(
                      'Skip',
                      style: GoogleFonts.nunito(color: accentGreen),
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
}
