import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zteel_user/screens/DealsScreen.dart';
import 'package:zteel_user/screens/FoodTypeShopScreen.dart';
import 'package:zteel_user/screens/NotificationScreen.dart';
import 'package:zteel_user/screens/ProfileScreen.dart';
import 'package:zteel_user/screens/RestaurantListScreen.dart';
import 'package:zteel_user/screens/WishlistScreen.dart';
import 'package:zteel_user/screens/home_discovery_view.dart';

void main() {
  testWidgets('HomeDiscoveryView includes RefreshIndicator and invokes onRefresh', (
    tester,
  ) async {
    bool refreshed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeDiscoveryView(
            restaurants: const [],
            deals: const [],
            onSeeAllDeals: () {},
            onRefresh: () async {
              refreshed = true;
            },
          ),
        ),
      ),
    );
    await tester.pump();

    final indicatorFinder = find.byType(RefreshIndicator);
    expect(indicatorFinder, findsOneWidget);

    final RefreshIndicator indicator = tester.widget(indicatorFinder);
    await indicator.onRefresh();
    expect(refreshed, isTrue);
  });

  testWidgets('NearbyRestaurantsScreen includes RefreshIndicator and invokes onRefresh', (
    tester,
  ) async {
    bool refreshed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NearbyRestaurantsScreen(
            restaurants: const [],
            showBackButton: false,
            onRefresh: () async {
              refreshed = true;
            },
          ),
        ),
      ),
    );
    await tester.pump();

    final indicatorFinder = find.byType(RefreshIndicator);
    expect(indicatorFinder, findsOneWidget);

    final RefreshIndicator indicator = tester.widget(indicatorFinder);
    await indicator.onRefresh();
    expect(refreshed, isTrue);
  });

  testWidgets('ProfileScreen includes RefreshIndicator and invokes onRefresh', (
    tester,
  ) async {
    bool refreshed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileScreen(
            fullName: 'Jane Doe',
            phoneNumber: '+1234567890',
            onRefresh: () async {
              refreshed = true;
            },
          ),
        ),
      ),
    );
    await tester.pump();

    final indicatorFinder = find.byType(RefreshIndicator);
    expect(indicatorFinder, findsOneWidget);

    final RefreshIndicator indicator = tester.widget(indicatorFinder);
    await indicator.onRefresh();
    expect(refreshed, isTrue);
  });

  testWidgets('DealsScreen, FoodTypeShopScreen, WishlistScreen, and NotificationScreen have RefreshIndicators', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DealsScreen(),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(RefreshIndicator), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FoodTypeShopScreen(foodType: 'Pizza'),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(RefreshIndicator), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Wishlistscreen(),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(RefreshIndicator), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: NotificationsScreen(),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(RefreshIndicator), findsOneWidget);
  });
}
