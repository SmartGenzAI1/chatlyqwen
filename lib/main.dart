/// @file lib/main.dart
/// @brief Application entry point and global error handling setup
/// @author Chatly Development Team
/// @date 2025-12-08
///
/// This file initializes the entire Chatly application, sets up global error handling,
/// and configures the root providers. It serves as the central entry point for the app
/// and ensures proper error recovery and user experience even during critical failures.

import 'package:chatly/core/constants/route_constants.dart';
import 'package:chatly/core/errors/error_handler.dart';
import 'package:chatly/core/providers/auth_provider.dart';
import 'package:chatly/core/providers/theme_provider.dart';
import 'package:chatly/core/utils/handlers/error_catcher.dart';
import 'package:chatly/router/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global navigator key for navigation across the app
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize shared preferences
  await SharedPreferences.getInstance();
  
  // Set up global error handler
  ErrorCatcher.initialize();
  
  runApp(const ChatlyApp());
}

/// Main application widget that sets up the provider tree and theme
class ChatlyApp extends StatelessWidget {
  const ChatlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer2<AuthProvider, ThemeProvider>(
        builder: (context, authProvider, themeProvider, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Chatly',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.currentTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('hi', ''),
            ],
            home: const ErrorCatcher(
              child: AppRouter(),
            ),
            onGenerateRoute: RouteGenerator.generateRoute,
            // Global error handling for async errors
            navigatorObservers: [
              FirebaseAnalyticsObserver(),
            ],
          );
        },
      ),
    );
  }
}

/// Firebase Analytics observer for tracking navigation
class FirebaseAnalyticsObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    // Analytics tracking would go here in production
  }
}
