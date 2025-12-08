/// @file lib/router/app_router.dart
/// @brief Main router widget that handles navigation based on authentication state
/// @author Chatly Development Team
/// @date 2025-12-08
///
/// This file implements the main router widget that determines which screens to show
/// based on the user's authentication state. It handles the flow from onboarding to
/// authenticated screens and manages route transitions.

import 'package:chatly/core/constants/route_constants.dart';
import 'package:chatly/core/providers/auth_provider.dart';
import 'package:chatly/features/auth/presentation/screens/login_screen.dart';
import 'package:chatly/features/auth/presentation/screens/signup_screen.dart';
import 'package:chatly/features/auth/presentation/screens/username_setup_screen.dart';
import 'package:chatly/features/auth/presentation/screens/verify_otp_screen.dart';
import 'package:chatly/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:chatly/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:chatly/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show splash screen while initializing
        if (authProvider.isLoading) {
          return const SplashScreen();
        }
        
        // If not authenticated, show onboarding/login flow
        if (!authProvider.isAuthenticated) {
          return const OnboardingScreen();
        }
        
        // If authenticated but no username set, show username setup
        if (authProvider.userProfile?.username.isEmpty ?? true) {
          return const UsernameSetupScreen();
        }
        
        // Show main app screens
        return const ChatListScreen();
      },
    );
  }
}
