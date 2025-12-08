/// @file lib/core/services/subscription_service.dart
/// @brief Subscription management service using RevenueCat
/// @author Chatly Development Team
/// @date 2025-12-08
///
/// This file implements the subscription management service that handles
/// in-app purchases, subscription validation, and premium feature unlocks.
/// It integrates with RevenueCat for payment processing and maintains
/// subscription state across the application. The service handles trial periods,
/// grace periods, and subscription restoration.

import 'dart:async';
import 'package:chatly/core/constants/app_constants.dart';
import 'package:chatly/core/providers/auth_provider.dart';
import 'package:chatly/core/utils/handlers/preference_handler.dart';
import 'package:chatly/core/utils/handlers/toast_handler.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:revenuecat/revenuecat.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  late RevenueCat _revenueCat;
  final PreferenceHandler _preferenceHandler = PreferenceHandler();
  StreamController<CustomerInfo> _subscriptionStreamController = StreamController<CustomerInfo>.broadcast();
  
  factory SubscriptionService() {
    return _instance;
  }
  
  SubscriptionService._internal();

  Future<void> init(String apiKey, String? appUserID) async {
    _revenueCat = RevenueCat();
    
    try {
      await _revenueCat.setup(apiKey, appUserID: appUserID);
      
      // Listen for subscription changes
      _revenueCat.customerInfoStream.listen((customerInfo) {
        _subscriptionStreamController.add(customerInfo);
        _handleSubscriptionChange(customerInfo);
      });
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      if (kDebugMode) {
        print('Failed to initialize RevenueCat: $e');
      }
    }
  }

  Stream<CustomerInfo> get subscriptionStream {
    return _subscriptionStreamController.stream;
  }

  Future<void> _handleSubscriptionChange(CustomerInfo customerInfo) async {
    final authProvider = Provider.of<AuthProvider>(GlobalKey<NavigatorState>().currentContext!, listen: false);
    final currentUser = authProvider.userProfile;
    
    if (currentUser == null) return;
    
    String newTier = 'free';
    
    if (customerInfo.entitlements.all['plus']?.isActive ?? false) {
      newTier = 'plus';
    } else if (customerInfo.entitlements.all['pro']?.isActive ?? false) {
      newTier = 'pro';
    }
    
    if (currentUser.tier != newTier) {
      final updatedProfile = currentUser.copyWith(
        tier: newTier,
        settings: {
          ...currentUser.settings,
          'subscriptionExpiry': customerInfo.entitlements.all[newTier]?.expirationDate?.toIso8601String() ?? '',
        }
      );
      
      await authProvider.updateUserProfile(updatedProfile);
      
      // Show tier change notification
      if (newTier != 'free') {
        ToastHandler.showSuccess(
          GlobalKey<NavigatorState>().currentContext!,
          '🎉 You are now ${newTier.toUpperCase()}! All premium features unlocked',
        );
      }
    }
  }

  Future<bool> purchaseSubscription(String tier) async {
    try {
      Package? package;
      
      if (tier == 'plus') {
        package = await _getPackage('plus_annual');
      } else if (tier == 'pro') {
        package = await _getPackage('pro_annual');
      }
      
      if (package == null) {
        throw Exception('Subscription package not found');
      }
      
      final customerInfo = await _revenueCat.purchasePackage(package);
      
      // Verify purchase
      if (tier == 'plus' && (customerInfo.entitlements.all['plus']?.isActive ?? false)) {
        return true;
      } else if (tier == 'pro' && (customerInfo.entitlements.all['pro']?.isActive ?? false)) {
        return true;
      }
      
      throw Exception('Subscription purchase failed verification');
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<Package?> _getPackage(String identifier) async {
    try {
      final offerings = await _revenueCat.getOfferings();
      if (offerings.current == null) return null;
      
      return offerings.current!.availablePackages.firstWhere(
        (p) => p.identifier == identifier,
        orElse: () => offerings.current!.availablePackages.first,
      );
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      return null;
    }
  }

  Future<bool> restorePurchases() async {
    try {
      final customerInfo = await _revenueCat.restorePurchases();
      return customerInfo.entitlements.all.isNotEmpty;
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> isSubscribed(String tier) async {
    try {
      final customerInfo = await _revenueCat.getCustomerInfo();
      
      if (tier == 'plus') {
        return customerInfo.entitlements.all['plus']?.isActive ?? false;
      } else if (tier == 'pro') {
        return customerInfo.entitlements.all['pro']?.isActive ?? false;
      }
      
      return false;
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      return false;
    }
  }

  Future<void> cancelSubscription() async {
    // In RevenueCat, subscriptions are cancelled through the platform
    // This method would handle local state updates
    try {
      final authProvider = Provider.of<AuthProvider>(GlobalKey<NavigatorState>().currentContext!, listen: false);
      final currentUser = authProvider.userProfile;
      
      if (currentUser == null) return;
      
      // Update local state
      final updatedProfile = currentUser.copyWith(
        tier: 'free',
        settings: {
          ...currentUser.settings,
          'subscriptionExpiry': '',
        }
      );
      
      await authProvider.updateUserProfile(updatedProfile);
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
    }
  }

  Future<Map<String, dynamic>> getSubscriptionDetails() async {
    try {
      final customerInfo = await _revenueCat.getCustomerInfo();
      final offerings = await _revenueCat.getOfferings();
      
      return {
        'currentTier': _getCurrentTier(customerInfo),
        'expiryDate': _getExpiryDate(customerInfo),
        'isTrial': _isTrialPeriod(customerInfo),
        'availablePackages': _getAvailablePackages(offerings),
        'managementURL': customerInfo.managementURL?.toString() ?? '',
      };
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      return {
        'currentTier': 'free',
        'expiryDate': null,
        'isTrial': false,
        'availablePackages': [],
        'managementURL': '',
      };
    }
  }

  String _getCurrentTier(CustomerInfo customerInfo) {
    if (customerInfo.entitlements.all['pro']?.isActive ?? false) {
      return 'pro';
    } else if (customerInfo.entitlements.all['plus']?.isActive ?? false) {
      return 'plus';
    }
    return 'free';
  }

  DateTime? _getExpiryDate(CustomerInfo customerInfo) {
    final tier = _getCurrentTier(customerInfo);
    return customerInfo.entitlements.all[tier]?.expirationDate;
  }

  bool _isTrialPeriod(CustomerInfo customerInfo) {
    final tier = _getCurrentTier(customerInfo);
    final entitlement = customerInfo.entitlements.all[tier];
    return entitlement?.isInIntroOfferPeriod ?? false;
  }

  List<Map<String, dynamic>> _getAvailablePackages(Offerings offerings) {
    if (offerings.current == null) return [];
    
    return offerings.current!.availablePackages.map((package) {
      return {
        'identifier': package.identifier,
        'productIdentifier': package.product.identifier,
        'price': package.product.price,
        'currency': package.product.currencyCode,
        'period': _getPeriod(package.product),
        'tier': _getTierFromPackage(package),
      };
    }).toList();
  }

  String _getPeriod(StoreProduct product) {
    return product.subscriptionPeriod?.iso8601 ?? 'annual';
  }

  String _getTierFromPackage(Package package) {
    if (package.identifier.contains('pro')) return 'pro';
    if (package.identifier.contains('plus')) return 'plus';
    return 'free';
  }

  Future<bool> hasFreeTrial(String tier) async {
    try {
      final offerings = await _revenueCat.getOfferings();
      if (offerings.current == null) return false;
      
      final package = tier == 'plus'
          ? offerings.current!.availablePackages.firstWhere((p) => p.identifier.contains('plus'))
          : offerings.current!.availablePackages.firstWhere((p) => p.identifier.contains('pro'));
      
      return package.product.introductoryPrice != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> startFreeTrial(String tier) async {
    await purchaseSubscription(tier);
  }

  Future<bool> isWithinGracePeriod() async {
    final expiryString = await _preferenceHandler.getSubscriptionExpiry();
    if (expiryString == null) return false;
    
    try {
      final expiryDate = DateTime.parse(expiryString);
      final now = DateTime.now();
      final gracePeriodEnd = expiryDate.add(const Duration(days: 3));
      
      return now.isAfter(expiryDate) && now.isBefore(gracePeriodEnd);
    } catch (e) {
      return false;
    }
  }

  Future<void> handleGracePeriod() async {
    if (await isWithinGracePeriod()) {
      ToastHandler.showInfo(
        GlobalKey<NavigatorState>().currentContext!,
        'Your subscription has expired. You have 3 days remaining to renew and keep your data.',
      );
    }
  }

  /// TODO: Implement subscription status polling for better reliability
  /// TODO: Add support for family sharing and group subscriptions
  /// TODO: Implement subscription gifting feature
  /// WARNING: Always verify subscription status on the server-side for critical features
}
