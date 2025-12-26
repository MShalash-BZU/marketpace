import 'package:flutter/material.dart';
import '../../features/auth/domain/entities/user.dart';
import '../../features/customer/home/presentation/screens/customer_home_screen.dart';
import '../../features/store_owner/dashboard/presentation/screens/store_owner_dashboard_screen.dart';
// TODO: Import Admin screens when created
// import '../../features/admin/dashboard/presentation/screens/admin_dashboard_screen.dart';

class NavigationHelper {
  /// Navigate to home screen based on user role
  static void navigateToHome(BuildContext context, UserRole role) {
    Widget targetScreen;

    switch (role) {
      case UserRole.customer:
        targetScreen = const CustomerHomeScreen();
        break;
      case UserRole.storeOwner:
      case UserRole.storeStaff:
        targetScreen = const StoreOwnerDashboardScreen();
        break;
      case UserRole.admin:
        // TODO: Navigate to Admin Dashboard when created
        targetScreen = const CustomerHomeScreen(); // Temporary
        break;
      case UserRole.courier:
        // TODO: Navigate to Courier Dashboard when created
        targetScreen = const CustomerHomeScreen(); // Temporary
        break;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => targetScreen),
      (route) => false,
    );
  }

  /// Get home screen widget based on user role
  static Widget getHomeScreen(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return const CustomerHomeScreen();
      case UserRole.storeOwner:
      case UserRole.storeStaff:
        return const StoreOwnerDashboardScreen();
      case UserRole.admin:
        // TODO: Return Admin Dashboard when created
        return const CustomerHomeScreen(); // Temporary
      case UserRole.courier:
        // TODO: Return Courier Dashboard when created
        return const CustomerHomeScreen(); // Temporary
    }
  }
}

