/// @file lib/features/onboarding/presentation/screens/splash_screen.dart
/// @brief Splash screen shown during app initialization
/// @author Chatly Development Team
/// @date 2025-12-08
///
/// This file implements the splash screen that appears when the app launches.
/// It handles the initialization of Firebase, preference handlers, and other
/// core services before navigating to the appropriate screen based on
/// authentication state and onboarding completion.

import 'dart:async';
import 'package:chatly/core/constants/app_constants.dart';
import 'package:chatly/core/constants/route_constants.dart';
import 'package:chatly/core/providers/auth_provider.dart';
import 'package:chatly/core/providers/theme_provider.dart';
import 'package:chatly/core/utils/handlers/preference_handler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.animationDuration,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );
    
    _animationController.forward();
    
    // Start initialization process
    _initializeApp();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _initializeApp() async {
    try {
      // Initialize preference handler
      final preferenceHandler = PreferenceHandler();
      await preferenceHandler.init();
      
      // Initialize theme provider
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      await themeProvider.initialize();
      
      // Initialize auth provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.initialize();
      
      // Check if this is first launch
      final isFirstLaunch = await preferenceHandler.isFirstLaunch();
      
      // Navigate to appropriate screen after delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        if (authProvider.isAuthenticated) {
          // User is authenticated, check onboarding
          final isOnboardingComplete = await preferenceHandler.isOnboardingComplete();
          if (isOnboardingComplete) {
            Navigator.pushReplacementNamed(context, RouteConstants.home);
          } else {
            Navigator.pushReplacementNamed(context, RouteConstants.onboarding);
          }
        } else {
          // User not authenticated
          if (isFirstLaunch) {
            await preferenceHandler.markAsNotFirstLaunch();
            Navigator.pushReplacementNamed(context, RouteConstants.onboarding);
          } else {
            Navigator.pushReplacementNamed(context, RouteConstants.login);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pushReplacementNamed(
          context, 
          RouteConstants.error,
          arguments: 'Failed to initialize app: ${e.toString()}',
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo with animation
            ScaleTransition(
              scale: _scaleAnimation,
              child: Icon(
                Icons.chat,
                size: 120,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            
            // App name
            Text(
              'Chatly',
              style: theme.textTheme.displayLarge!.copyWith(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Tagline
            Text(
              'Smart. Private. Connected.',
              style: theme.textTheme.headlineMedium!.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 32),
            
            // Loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
