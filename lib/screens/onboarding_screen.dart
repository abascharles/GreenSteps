import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

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
    return Scaffold(
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
                          color: Colors.green[100],
                          child: Center(
                            child: Icon(
                              Icons.eco,
                              size: 100,
                              color: Colors.green[700],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          page['title']!,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page['subtitle']!,
                          style: Theme.of(context).textTheme.titleMedium,
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
                        ? Colors.green
                        : Colors.green[200],
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
                      child: const Text('Login'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: const Text('Sign Up'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      // Skip onboarding, go to dashboard (for demo)
                      Navigator.pushReplacementNamed(context, '/dashboard');
                    },
                    child: const Text('Skip'),
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
