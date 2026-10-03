import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zteel_user/screens/DealsScreen.dart';
import 'package:zteel_user/screens/home_discovery_view.dart';

const _restaurants = [
  HomeRestaurant(
    id: 'one',
    name: 'Spice Route',
    cuisine: 'North Indian · Biryani',
    rating: 4.6,
    reviewCount: 120,
    distance: '0.8 km',
    eta: '20–25 min',
    isOpen: true,
    offerLabel: '20% OFF',
  ),
  HomeRestaurant(
    id: 'two',
    name: 'Napoli Kitchen',
    cuisine: 'Italian · Pizza',
    rating: 4.5,
    reviewCount: 86,
    distance: '1.2 km',
    eta: '25–30 min',
    isOpen: true,
  ),
  HomeRestaurant(
    id: 'three',
    name: 'Green Bowl',
    cuisine: 'Healthy · Salads',
    rating: 4.4,
    reviewCount: 60,
    distance: '1.5 km',
    eta: '20–25 min',
    isOpen: true,
  ),
];

const _deals = [
  Deal(
    title: 'Lunch just got better',
    restaurant: 'Spice Route',
    distance: '0.8 km',
    discount: '25% OFF',
    timeLeft: '2h left',
    imageUrl: 'https://invalid.example/banner.png',
  ),
];

Widget _home({required VoidCallback onDeals}) => MaterialApp(
  home: Scaffold(
    body: HomeDiscoveryView(
      restaurants: _restaurants,
      deals: _deals,
      onSeeAllDeals: onDeals,
    ),
  ),
);

void main() {
  testWidgets('Home keeps the primary discovery sections in order', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_home(onDeals: () {}));

    expect(find.byKey(const ValueKey('home-discovery-feed')), findsOneWidget);
    expect(find.text('Search dishes or restaurants'), findsOneWidget);
    expect(find.text('What are you craving?'), findsOneWidget);
    expect(find.text('Popular near you'), findsOneWidget);
    expect(find.text('Spice Route'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Offers action uses the Home callback', (tester) async {
    var openedDeals = false;
    await tester.pumpWidget(_home(onDeals: () => openedDeals = true));

    await tester.tap(find.text('Offers'));
    expect(openedDeals, isTrue);
  });

  testWidgets('Home remains overflow-free on common phone widths', (
    tester,
  ) async {
    for (final size in const [Size(360, 800), Size(390, 844), Size(430, 932)]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(_home(onDeals: () {}));
      expect(tester.takeException(), isNull, reason: 'overflow at $size');
    }
    addTearDown(() => tester.binding.setSurfaceSize(null));
  });
}
