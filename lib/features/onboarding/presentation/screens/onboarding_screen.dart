/// @file lib/features/onboarding/presentation/screens/onboarding_screen.dart
/// @brief Onboarding screen with multi-page introduction
/// @author Chatly Development Team
/// @date 2025-12-08
///
/// This file implements the onboarding screen that introduces new users to
/// Chatly's key features and value propositions. It includes a multi-page
/// slider with animations, feature highlights, and navigation controls.
/// The screen is only shown to first-time users and can be skipped.

import 'package:chatly/core/constants/app_constants.dart';
import 'package:chatly/core/constants/route_constants.dart';
import 'package:chatly/core/utils/handlers/preference_handler.dart';
import 'package:chatly/core/widgets/common/custom_button.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Private & Secure',
      subtitle: 'Your messages are encrypted and automatically deleted after 7 days',
      icon: Icons.lock,
      iconColor: Colors.blue,
      backgroundColor: Color(0xFF6366F1).withOpacity(0.1),
    ),
    OnboardingPage(
      title: 'Smart Notifications',
      subtitle: 'Get notified at the perfect time based on your activity patterns',
      icon: Icons.notifications_active,
      iconColor: Colors.green,
      backgroundColor: Color(0xFF10B981).withOpacity(0.1),
    ),
    OnboardingPage(
      title: 'Anonymous Connections',
      subtitle: 'Find like-minded people through interest-based anonymous chats',
      icon: Icons.masks,
      iconColor: Colors.orange,
      backgroundColor: Color(0xFFF59E0B).withOpacity(0.1),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppConstants.animationDuration,
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _skipOnboarding() async {
    final preferenceHandler = PreferenceHandler();
    await preferenceHandler.markOnboardingComplete();
    Navigator.pushReplacementNamed(context, RouteConstants.login);
  }

  Future<void> _finishOnboarding() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final preferenceHandler = PreferenceHandler();
      await preferenceHandler.markOnboardingComplete();
      
      Navigator.pushReplacementNamed(context, RouteConstants.login);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Stack(
        children: [
          // Page view with onboarding pages
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildPage(context, _pages[index], screenSize);
            },
          ),
          
          // Skip button
          Positioned(
            top: 40,
            right: 20,
            child: TextButton(
              onPressed: _skipOnboarding,
              child: Text(
                'Skip',
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          // Navigation indicators
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                return Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: _currentPage == index 
                      ? theme.primaryColor 
                      : theme.colorScheme.secondary.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
          
          // Navigation buttons
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: _currentPage == _pages.length - 1
              ? CustomButton(
                  text: _isLoading ? 'Setting up...' : 'Get Started',
                  onPressed: _isLoading ? null : _finishOnboarding,
                  isLoading: _isLoading,
                )
              : Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _skipOnboarding,
                        child: Text(
                          'Skip',
                          style: theme.textTheme.bodyLarge!.copyWith(
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: 'Next',
                        onPressed: _nextPage,
                      ),
                    ),
                  ],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(BuildContext context, OnboardingPage page, Size screenSize) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            page.backgroundColor,
            theme.scaffoldBackgroundColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon
          Container(
            width: screenSize.width * 0.6,
            height: screenSize.width * 0.6,
            decoration: BoxDecoration(
              color: page.iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: screenSize.width * 0.3,
              color: page.iconColor,
            ),
          ),
          const SizedBox(height: 40),
          
          // Title
          Text(
            page.title,
            style: theme.textTheme.displayMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: page.iconColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // Subtitle
          Text(
            page.subtitle,
            style: theme.textTheme.bodyLarge!.copyWith(
              color: theme.textTheme.bodyLarge!.color!.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  
  const OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });
}
